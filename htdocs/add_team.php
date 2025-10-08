<?php
require_once 'db_service.php';
header('Content-Type: application/json');

// Hole den Teamnamen aus dem POST-Request
$teamName = $_POST['teamName'] ?? null;

if (!$teamName) {
    echo json_encode(['success' => false, 'message' => 'Teamname nicht angegeben.']);
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
    $success = $stmt->execute(['teamName' => $teamName]);

    if ($success) {
        echo json_encode(['success' => true, 'message' => 'Team erfolgreich hinzugefügt.']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Fehler beim Hinzufügen des Teams.']);
    }

} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Fehler: ' . $e->getMessage()]);
}
