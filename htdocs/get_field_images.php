<?php
require_once 'db_service.php';
header('Content-Type: application/json; charset=utf-8');

$fieldId = $_POST['field_id'] ?? null;
if ($fieldId === null) {
    echo json_encode(['success' => false, 'message' => 'field_id fehlt.']);
    exit;
}

try {
    $stmt = $pdo->prepare('SELECT id, field_id, image_url, sort_order, is_cover, created_at FROM field_images WHERE field_id = :field_id ORDER BY is_cover DESC, sort_order ASC, id ASC');
    $stmt->execute(['field_id' => (int)$fieldId]);
    $images = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(['success' => true, 'images' => $images]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Fehler bei der Datenbankabfrage: ' . $e->getMessage()]);
}
