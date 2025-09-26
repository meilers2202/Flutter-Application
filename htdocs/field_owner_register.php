<?php
require_once 'db_config.php';
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(array("success" => false, "message" => "Verbindung zur Datenbank fehlgeschlagen: " . $conn->connect_error)));
}

// Daten aus dem Flutter-Request entgegennehmen
$data = json_decode(file_get_contents("php://input"), true);
if (empty($data)) {
    $username_post = isset($_POST['username']) ? $_POST['username'] : '';
    $password_post = isset($_POST['password']) ? $_POST['password'] : '';
} else {
    $username_post = $data['username'] ?? '';
    $password_post = $data['password'] ?? '';
}

if (empty($username_post) || empty($password_post)) {
    die(json_encode(array("success" => false, "message" => "Benutzername und Passwort sind erforderlich.")));
}

$username = $conn->real_escape_string($username_post);
$password = $conn->real_escape_string($password_post);

// --- 1. PRÜFUNG: Existiert der Benutzer in der 'users'-Tabelle? ---
$check_user_sql = "SELECT id, password FROM users WHERE username = '$username'";
$check_user_result = $conn->query($check_user_sql);

if ($check_user_result->num_rows == 0) {
    echo json_encode(array("success" => false, "message" => "Benutzername existiert nicht. Bitte zuerst als Spieler registrieren."));
    $conn->close();
    exit;
}

$user_row = $check_user_result->fetch_assoc();
$user_id = $user_row['id'];
$hashed_password_from_db = $user_row['password'];

// --- 2. PRÜFUNG: Stimmt das Passwort überein? ---
if (!password_verify($password, $hashed_password_from_db)) {
    echo json_encode(array("success" => false, "message" => "Falsches Passwort."));
    $conn->close();
    exit;
}

// 🔥 NEUE PRÜFUNG: Ist der Benutzer bereits ein Field Owner?
// --- 3. PRÜFUNG: Ist der User bereits in 'fieldowner' eingetragen? ---
$check_fieldowner_sql = "SELECT user_id FROM fieldowner WHERE user_id = $user_id";
$check_fieldowner_result = $conn->query($check_fieldowner_sql);

if ($check_fieldowner_result->num_rows > 0) {
    // Benutzer ist bereits Field Owner
    echo json_encode(array("success" => false, "message" => "Dieser Benutzer existiert bereits."));
    $conn->close();
    exit;
}

// --- 4. AKTION: Eintrag in 'fieldowner'-Tabelle (Wenn alle Prüfungen erfolgreich) ---
// Hier wird NUR in die fieldowner-Tabelle geschrieben.
$insert_fieldowner_sql = "INSERT INTO fieldowner (user_id, name) VALUES ($user_id, '$username')";

if ($conn->query($insert_fieldowner_sql) === TRUE) {
    echo json_encode(array("success" => true, "message" => "Erfolgreich als Field Owner registriert. Sie können sich nun anmelden."));
} else {
    echo json_encode(array("success" => false, "message" => "Fehler bei der Field Owner Zuordnung: " . $conn->error));
}

$conn->close();
?>