<?php
require_once 'db_config.php';
header('Content-Type: application/json');

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Verbindungsfehler: " . $conn->connect_error]);
    exit();
}

$teamName = $_POST['teamName'] ?? null;

if ($teamName === null || empty($teamName)) {
    echo json_encode(["success" => false, "message" => "Teamname fehlt."]);
    $conn->close();
    exit();
}

// Zuerst die group_id des Teams finden
$stmt = $conn->prepare("SELECT id FROM groups WHERE name = ?");
$stmt->bind_param("s", $teamName);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(["success" => false, "message" => "Team nicht gefunden."]);
    $stmt->close();
    $conn->close();
    exit();
}

$row = $result->fetch_assoc();
$groupId = $row['id'];
$stmt->close();

// Setze die group_id aller Benutzer in diesem Team auf NULL
$stmt_update_users = $conn->prepare("UPDATE users SET group_id = NULL WHERE group_id = ?");
$stmt_update_users->bind_param("i", $groupId);
$stmt_update_users->execute();
$stmt_update_users->close();

// Lösche das Team
$stmt_delete_team = $conn->prepare("DELETE FROM groups WHERE id = ?");
$stmt_delete_team->bind_param("i", $groupId);

if ($stmt_delete_team->execute()) {
    echo json_encode(["success" => true, "message" => "Team erfolgreich gelöscht."]);
} else {
    echo json_encode(["success" => false, "message" => "Fehler beim Löschen des Teams: " . $stmt_delete_team->error]);
}

$stmt_delete_team->close();
$conn->close();
?>