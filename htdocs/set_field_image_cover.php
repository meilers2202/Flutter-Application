<?php
require_once 'db_service.php';
header('Content-Type: application/json; charset=utf-8');

$id = $_POST['id'] ?? null;
if (!$id) {
    echo json_encode(['success' => false, 'message' => 'id fehlt.']);
    exit;
}

try {
    $stmt = $pdo->prepare('SELECT field_id FROM field_images WHERE id = :id');
    $stmt->execute(['id' => (int)$id]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$row) {
        echo json_encode(['success' => false, 'message' => 'Bild nicht gefunden.']);
        exit;
    }

    $fieldId = (int)$row['field_id'];

    $pdo->beginTransaction();
    $reset = $pdo->prepare('UPDATE field_images SET is_cover = 0 WHERE field_id = :field_id');
    $reset->execute(['field_id' => $fieldId]);

    $set = $pdo->prepare('UPDATE field_images SET is_cover = 1 WHERE id = :id');
    $set->execute(['id' => (int)$id]);
    $pdo->commit();

    echo json_encode(['success' => true, 'message' => 'Cover-Bild gesetzt.']);
} catch (PDOException $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    echo json_encode(['success' => false, 'message' => 'Fehler: ' . $e->getMessage()]);
}
