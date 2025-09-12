<?php
require_once 'db_config.php';
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Verbindung herstellen
$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Verbindungsfehler: " . $conn->connect_error]));
}

// Prüfen, ob der Benutzername gesendet wurde
$username_to_fetch = $_POST['username'] ?? null;

if ($username_to_fetch === null) {
    echo json_encode(["success" => false, "message" => "Benutzername fehlt."]);
    exit();
}

// Verwende einen LEFT JOIN, um den Teamnamen zu erhalten
$stmt = $conn->prepare("SELECT users.username, users.email, users.city, users.created_at, groups.name AS team FROM users LEFT JOIN groups ON users.group_id = groups.id WHERE users.username = ?");
$stmt->bind_param("s", $username_to_fetch);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo json_encode([
        "success" => true,
        "username" => $row['username'],
        "email" => $row['email'],
        "city" => $row['city'],
        "team" => $row['team'],
        "memberSince" => $row['created_at'],
    ]);
} else {
    echo json_encode(["success" => false, "message" => "Benutzer nicht gefunden."]);
}

$stmt->close();
$conn->close();
?>