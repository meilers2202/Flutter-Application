<?php
require_once 'db_config.php';
header('Content-Type: application/json');

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Verbindungsfehler zur Datenbank: ' . $conn->connect_error]);
    exit();
}

$data = json_decode(file_get_contents('php://input'), true);

$username = $data['username'] ?? '';

if (empty($username)) {
    echo json_encode(['success' => false, 'message' => 'Benutzername fehlt.']);
    $conn->close();
    exit();
}

$stmt = $conn->prepare("SELECT username, email, city, team, member_since, group_id FROM users WHERE username = ?");
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();
    echo json_encode(['success' => true, 'user' => $user]);
} else {
    echo json_encode(['success' => false, 'message' => 'Benutzer nicht gefunden.']);
}

$stmt->close();
$conn->close();
?>