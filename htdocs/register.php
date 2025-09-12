<?php
require_once 'db_config.php';
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Verbindungsfehler: " . $conn->connect_error]);
    exit();
}

if (isset($_POST['username']) && isset($_POST['password']) && isset($_POST['email']) && isset($_POST['city']) && isset($_POST['group_id'])) {
    $inputUsername = $_POST['username'];
    $inputPassword = $_POST['password'];
    $inputEmail = $_POST['email'];
    $inputCity = $_POST['city'];
    $inputGroupId = $_POST['group_id'];

    // Prüfen, ob der Benutzername bereits existiert
    $stmt = $conn->prepare("SELECT id FROM users WHERE username = ?");
    $stmt->bind_param("s", $inputUsername);
    $stmt->execute();
    $stmt->store_result();

    if ($stmt->num_rows > 0) {
        echo json_encode(["success" => false, "message" => "Benutzername existiert bereits."]);
    } else {
        $hashedPassword = password_hash($inputPassword, PASSWORD_DEFAULT);
        
        $defaultRole = 'user';

        $stmt = $conn->prepare("INSERT INTO users (username, password, email, city, group_id, role) VALUES (?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("ssssss", $inputUsername, $hashedPassword, $inputEmail, $inputCity, $inputGroupId, $defaultRole);

        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Registrierung erfolgreich!"]);
        } else {
            echo json_encode(["success" => false, "message" => "Fehler bei der Registrierung."]);
        }
    }

    $stmt->close();
} else {
    echo json_encode(["success" => false, "message" => "Unvollständige Daten."]);
}

$conn->close();
?>