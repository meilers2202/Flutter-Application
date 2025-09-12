<?php
header("Content-Type: application/json; charset=UTF-8");
require_once 'db_config.php';

// Verbindung herstellen
$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Verbindungsfehler: " . $conn->connect_error]);
    exit();
}

if (isset($_POST['username']) && isset($_POST['password'])) {
    $inputUsername = $_POST['username'];
    $inputPassword = $_POST['password'];

    // NEU: Verwende LEFT JOIN, um den Teamnamen aus der groups-Tabelle zu erhalten
    $stmt = $conn->prepare("SELECT users.username, users.password, users.email, users.city, users.created_at, users.role, groups.name AS team FROM users LEFT JOIN groups ON users.group_id = groups.id WHERE users.username = ?");
    $stmt->bind_param("s", $inputUsername);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $hashedPassword = $row['password'];
        
        // Passwort verifizieren
        if (password_verify($inputPassword, $hashedPassword)) {
            // Login erfolgreich: Jetzt die benötigten Daten im JSON-Array zurückgeben
            echo json_encode([
                "success" => true, 
                "message" => "Login erfolgreich!",
                "username" => $row['username'],
                "email" => $row['email'],
                "city" => $row['city'],
                "team" => $row['team'], // Jetzt aus der 'groups' Tabelle
                "memberSince" => $row['created_at'],
                "role" => $row['role']
            ]);
        } else {
            echo json_encode(["success" => false, "message" => "Falsches Passwort."]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Benutzer existiert nicht."]);
    }
    
    $stmt->close();
} else {
    echo json_encode(["success" => false, "message" => "Unvollständige Daten."]);
}

$conn->close();
?>