<?php
require_once 'db_config.php';
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(array("success" => false, "message" => "Verbindung fehlgeschlagen: " . $conn->connect_error)));
}

$data = json_decode(file_get_contents("php://input"), true);
if (empty($data)) {
    $username_post = isset($_POST['username']) ? $_POST['username'] : '';
    $password_post = isset($_POST['password']) ? $_POST['password'] : '';
} else {
    $username_post = $data['username'];
    $password_post = $data['password'];
}

$username = $conn->real_escape_string($username_post);
$password = $conn->real_escape_string($password_post);

// Schritt 1: Suchen des Benutzernamens in der "fieldowner"-Tabelle
$sql_fieldowner = "SELECT user_id FROM fieldowner WHERE name = '$username'";
$result_fieldowner = $conn->query($sql_fieldowner);

if ($result_fieldowner->num_rows > 0) {
    $row_fieldowner = $result_fieldowner->fetch_assoc();
    $user_id = $row_fieldowner['user_id'];

    // Schritt 2: Zugriff auf die "users"-Tabelle mit der user_id
    // Nur Benutzername und Passwort abfragen
    $sql_user = "SELECT username, password FROM users WHERE id = $user_id";
    $result_user = $conn->query($sql_user);

    if ($result_user->num_rows > 0) {
        $row_user = $result_user->fetch_assoc();
        
        // Schritt 3: Benutzernamen aus beiden Tabellen vergleichen
        if ($row_user['username'] == $username) {
            // Schritt 4: Passwort prüfen
            if (password_verify($password, $row_user['password'])) {
                // Login erfolgreich
                echo json_encode(array(
                    "success" => true,
                    "message" => "Anmeldung erfolgreich!",
                    "username" => $row_user['username']
                ));
            } else {
                // Passwort falsch
                echo json_encode(array("success" => false, "message" => "Falsches Passwort."));
            }
        } else {
            // Benutzernamen stimmen nicht überein
            echo json_encode(array("success" => false, "message" => "Benutzerdaten stimmen nicht überein."));
        }
    } else {
        // user_id wurde in der "users"-Tabelle nicht gefunden (unwahrscheinlicher Fehler)
        echo json_encode(array("success" => false, "message" => "Benutzerdaten konnten nicht gefunden werden."));
    }
} else {
    // Benutzername nicht in der "fieldowner"-Tabelle gefunden
    echo json_encode(array("success" => false, "message" => "Benutzername ist kein Field Owner."));
}

$conn->close();
?>