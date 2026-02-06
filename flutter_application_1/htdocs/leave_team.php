<?php
header('Content-Type: application/json; charset=utf-8');
require_once 'db_service.php';

if (!isset($_POST['username'])) {
    echo json_encode(['success' => false, 'message' => 'username fehlt.']);
    exit;
}

$username = $_POST['username'];

try {
    // 1) Hole user mit group_id und teamrole
    $stmt = $pdo->prepare("SELECT id, group_id, teamrole FROM users WHERE username = :username");
    $stmt->execute(['username' => $username]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user || !$user['group_id']) {
        echo json_encode(['success' => false, 'message' => 'Benutzer ist in keinem Team.']);
        exit;
    }

    $gid = $user['group_id'];
    $isLeader = (string)$user['teamrole'] === '2' || strtolower((string)$user['teamrole']) === 'Leader';

    $pdo->beginTransaction();

    if ($isLeader) {
        // Hole andere Mitglieder (ohne den Leader)
        $stmt = $pdo->prepare("SELECT username FROM users WHERE group_id = :gid AND username != :leader");
        $stmt->execute(['gid' => $gid, 'leader' => $username]);
        $others = $stmt->fetchAll(PDO::FETCH_COLUMN);

        if (count($others) === 0) {
            // Keine Mitglieder -> Team löschen
            // WICHTIG: Wenn FK ON DELETE RESTRICT besteht, müssen wir vorher users.group_id auf NULL setzen (Leader ist noch dabei)
            // Entferne zuerst den Leader aus dem Team (setzt group_id NULL)
            $u = $pdo->prepare("UPDATE users SET group_id = NULL, teamrole = NULL WHERE username = :username");
            $u->execute(['username' => $username]);

            // Dann Team löschen
            $del = $pdo->prepare("DELETE FROM groups WHERE id = :gid");
            $del->execute(['gid' => $gid]);

            $pdo->commit();
            echo json_encode([
                'success' => true,
                'message' => 'Team gelöscht, da keine weiteren Mitglieder vorhanden waren.',
                'teamDeleted' => true
            ]);
            exit;
        } else {
            // Wähle zufälligen neuen Leader
            $newLeader = $others[array_rand($others)];
            // Setze neuen Leader-Rolle
            $setNew = $pdo->prepare("UPDATE users SET teamrole = :leaderRole WHERE username = :newLeader");
            // Je nach Schema: teamrole numeric (z.B. 1=leader) oder string; passe an falls nötig
            $leaderRoleValue = 2;
            $setNew->execute(['leaderRole' => $leaderRoleValue, 'newLeader' => $newLeader]);

            // Entferne aktuellen Leader aus Team (setze group_id NULL)
            $u = $pdo->prepare("UPDATE users SET group_id = NULL, teamrole = NULL WHERE username = :username");
            $u->execute(['username' => $username]);

            $pdo->commit();
            echo json_encode([
                'success' => true,
                'message' => 'Sie haben das Team verlassen. Ein neuer Teamleader wurde bestimmt.',
                'newLeader' => $newLeader,
                'teamDeleted' => false
            ]);
            exit;
        }
    } else {
        // Nicht-Leader: einfach aus Team entfernen
        $stmt = $pdo->prepare("UPDATE users SET group_id = NULL, teamrole = NULL WHERE username = :username");
        $stmt->execute(['username' => $username]);
        $pdo->commit();
        echo json_encode(['success' => true, 'message' => 'Team erfolgreich verlassen.', 'teamDeleted' => false]);
        exit;
    }
} catch (Exception $e) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    echo json_encode(['success' => false, 'message' => 'Fehler: ' . $e->getMessage()]);
    exit;
}
