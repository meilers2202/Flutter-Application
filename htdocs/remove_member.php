<?php
header('Content-Type: application/json; charset=utf-8');
require_once 'db_service.php';

if (!isset($_POST['leader']) || !isset($_POST['member'])) {
    echo json_encode(['success' => false, 'message' => 'Parameter fehlen.']);
    exit;
}

$leader = $_POST['leader'];
$member = $_POST['member'];

try {
    // Prüfen ob Aufrufer tatsächlich Leader im Team ist
    $stmt = $pdo->prepare("SELECT group_id FROM users WHERE username = :leader AND (teamrole = '2' OR teamrole = 'Leader')");
    $stmt->execute(['leader' => $leader]);
    $data = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$data) {
        echo json_encode(['success' => false, 'message' => 'Keine Berechtigung.']);
        exit;
    }
    $gid = $data['group_id'];

    // Entferne Mitglied nur, wenn es im selben Team ist
    $stmt = $pdo->prepare("UPDATE users SET group_id = NULL, teamrole = NULL WHERE username = :member AND group_id = :gid");
    $stmt->execute(['member' => $member, 'gid' => $gid]);

    if ($stmt->rowCount() > 0) {
        echo json_encode(['success' => true, 'message' => 'Mitglied entfernt.']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Mitglied nicht gefunden oder nicht im selben Team.']);
    }
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Fehler: '.$e->getMessage()]);
}
