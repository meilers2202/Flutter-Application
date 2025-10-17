<?php
require_once 'db_service.php';
header('Content-Type: application/json');

// POST-Daten validieren
$username = $_POST['username'] ?? null;
$teamName = $_POST['teamName'] ?? null;

if (!$username || !$teamName) {
    echo json_encode(['success' => false, 'message' => 'Ungültige Anfrage. Benutzername oder Teamname fehlen.']);
    exit;
}

try {
    // 1. Team-ID anhand des Namens holen
    $stmt = $pdo->prepare("SELECT id FROM groups WHERE name = :teamName");
    $stmt->execute(['teamName' => $teamName]);
    $team = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$team) {
        echo json_encode(['success' => false, 'message' => 'Team nicht gefunden.']);
        exit;
    }

    $groupId = $team['id'];

    // 2. Benutzer updaten: group_id + teamrole (z. B. 2 = Mitglied)
    $stmt = $pdo->prepare("UPDATE users SET group_id = :groupId, teamrole = 1 WHERE username = :username");
    $success = $stmt->execute([
        'groupId' => $groupId,
        'username' => $username
    ]);

    if ($success && $stmt->rowCount() > 0) {
        echo json_encode(['success' => true, 'message' => 'Team erfolgreich beigetreten.']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Benutzer nicht gefunden oder bereits Mitglied.']);
    }

} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Fehler: ' . $e->getMessage()]);
}
