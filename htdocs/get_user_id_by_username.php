<?php
header("Content-Type: application/json; charset=UTF-8");
require_once 'db_config.php';

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Verbindungsfehler: " . $conn->connect_error]);
    exit();
}

if (isset($_POST['username'])) {
    $inputUsername = $_POST['username'];

    $stmt = $conn->prepare("SELECT id FROM users WHERE username = ?");
    $stmt->bind_param("s", $inputUsername);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        echo json_encode(["success" => true, "userId" => (int)$row['id']]);
    } else {
        echo json_encode(["success" => false, "message" => "Benutzer nicht gefunden."]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Kein Benutzername angegeben."]);
}

$conn->close();
?>