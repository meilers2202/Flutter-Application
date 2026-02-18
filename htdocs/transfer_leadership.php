<?php
header('Content-Type: application/json; charset=utf-8');
require_once 'db_service.php';

if (!isset($_POST['leader']) || !isset($_POST['newLeader'])) {
    echo json_encode(['success' => false, 'message' => 'Parameter fehlen.']);
    exit;
}

$leader = $_POST['leader'];
$newLeader = $_POST['newLeader'];

try {
    // Prüfen, ob aufrufer Leader ist und group_id holen
    $stmt = $pdo->prepare("SELECT group_id FROM users WHERE username = :leader AND (teamrole = '2' OR teamrole = 'Leader')");
    $stmt->execute(['leader' => $leader]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$row) {
        echo json_encode(['success' => false, 'message' => 'Nur der Teamleader kann die Führung übertragen.']);
        exit;
    }
    $gid = $row['group_id'];

    // Prüfen, ob newLeader im selben Team ist
    $stmt = $pdo->prepare("SELECT username FROM users WHERE username = :newLeader AND group_id = :gid");
    $stmt->execute(['newLeader' => $newLeader, 'gid' => $gid]);
    if (!$stmt->fetch()) {
        echo json_encode(['success' => false, 'message' => 'Der ausgewählte Benutzer ist nicht im selben Team.']);
        exit;
    }

    $pdo->beginTransaction();

    // Entferne Leader-Rolle vom aktuellen Leader
    $pdo->prepare("UPDATE users SET teamrole = 1 WHERE username = :leader")->execute(['leader' => $leader]);
    // Setze Leader-Rolle beim neuen Leader
    $pdo->prepare("UPDATE users SET teamrole = :leaderRole WHERE username = :newLeader")->execute(['leaderRole' => 2, 'newLeader' => $newLeader]);

    $pdo->commit();
    echo json_encode(['success' => true, 'message' => 'Leadership erfolgreich übertragen.', 'newLeader' => $newLeader]);
    exit;
} catch (Exception $e) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    echo json_encode(['success' => false, 'message' => 'Fehler: ' . $e->getMessage()]);
    exit;
}
