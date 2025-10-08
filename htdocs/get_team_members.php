<?php
require_once 'db_service.php';

$teamName = $_POST['teamName'] ?? null;

if ($teamName === null || empty($teamName)) {
    echo json_encode(["success" => false, "message" => "Teamname fehlt."]);
    exit;
}

// 1. group_id basierend auf dem Teamnamen holen
$sql = "SELECT id FROM groups WHERE name = :teamName";
$stmt = $pdo->prepare($sql);
$stmt->execute(['teamName' => $teamName]);
$group = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$group) {
    echo json_encode(["success" => false, "message" => "Team nicht gefunden."]);
    exit;
}

$groupId = $group['id'];

// 2. Mitglieder abrufen
$sql = "SELECT username FROM users WHERE group_id = :groupId";
$stmt = $pdo->prepare($sql);
$stmt->execute(['groupId' => $groupId]);

$members = $stmt->fetchAll(PDO::FETCH_COLUMN);

echo json_encode([
    "success" => true,
    "teamName" => $teamName,
    "members" => $members
]);
?>
