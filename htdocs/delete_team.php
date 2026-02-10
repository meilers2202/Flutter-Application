<?php
// Use the project's PDO DB service for a consistent connection
require_once 'db_service.php';

// db_service.php already sets JSON headers and creates $pdo or exits on failure

$teamName = $_POST['teamName'] ?? null;

if ($teamName === null || trim($teamName) === '') {
    echo json_encode(["success" => false, "message" => "Teamname fehlt."]); 
    exit();
}

try {
    // Start transaction to ensure consistency
    $pdo->beginTransaction();

    // Find group id
    $stmt = $pdo->prepare('SELECT id FROM groups WHERE name = :name');
    $stmt->execute([':name' => $teamName]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$row) {
        // No such team
        $pdo->rollBack();
        echo json_encode(["success" => false, "message" => "Team nicht gefunden."]); 
        exit();
    }

    $groupId = (int)$row['id'];

    // Clear group association for users in this group (also clear teamrole)
    $stmt = $pdo->prepare('UPDATE users SET group_id = NULL, teamrole = NULL WHERE group_id = :gid');
    $stmt->execute([':gid' => $groupId]);

    // Delete the group
    $stmt = $pdo->prepare('DELETE FROM groups WHERE id = :gid');
    $ok = $stmt->execute([':gid' => $groupId]);

    if ($ok) {
        $pdo->commit();
        echo json_encode(["success" => true, "message" => "Team erfolgreich gelöscht."]); 
    } else {
        $pdo->rollBack();
        http_response_code(500);
        echo json_encode(["success" => false, "message" => "Fehler beim Löschen des Teams."]); 
    }
} catch (Exception $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Server-Fehler: " . $e->getMessage()]);
}

?>