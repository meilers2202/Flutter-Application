<?php
require_once 'db_service.php';
header('Content-Type: application/json');

// Hole den Teamnamen und den Username aus dem POST-Request
$teamName = $_POST['teamName'] ?? null;
$username = $_POST['username'] ?? null;

if (!$teamName || !$username) {
    echo json_encode(['success' => false, 'message' => 'Teamname oder Username nicht angegeben.']);
    exit;
}

try {
    // Prüfe, ob das Team bereits existiert
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM groups WHERE name = :teamName");
    $stmt->execute(['teamName' => $teamName]);
    $count = $stmt->fetchColumn();

    if ($count > 0) {
        echo json_encode(['success' => false, 'message' => 'Team existiert bereits.']);
        exit;
    }

    // Füge das neue Team ein
    $stmt = $pdo->prepare("INSERT INTO groups (name) VALUES (:teamName)");
    $stmt->execute(['teamName' => $teamName]);

    // Hole die ID der gerade erstellten Gruppe
    $groupId = $pdo->lastInsertId();

    // Weise den User dieser Gruppe zu und setze den Rang auf Teamleader
    $stmt = $pdo->prepare("UPDATE users SET group_id = :groupId, teamrole = '2' WHERE username = :username");
    $stmt->execute(['groupId' => $groupId, 'username' => $username]);

    echo json_encode(['success' => true, 'message' => 'Team erfolgreich hinzugefügt und Benutzer als Teamleader gesetzt.']);

} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Fehler: ' . $e->getMessage()]);
}
