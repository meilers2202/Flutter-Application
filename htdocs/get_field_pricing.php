<?php
require_once 'db_service.php';
header('Content-Type: application/json; charset=utf-8');

$fieldId = $_POST['field_id'] ?? null;
if ($fieldId === null) {
    echo json_encode(['success' => false, 'message' => 'field_id fehlt.']);
    exit;
}

try {
    $stmt = $pdo->prepare('SELECT id, field_id, name, price, currency, description, play_time, age_rating, notes, areas_json, sort_order, created_at FROM field_pricing_packages WHERE field_id = :field_id ORDER BY sort_order ASC, id ASC');
    $stmt->execute(['field_id' => (int)$fieldId]);
    $packages = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(['success' => true, 'packages' => $packages]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Fehler bei der Datenbankabfrage: ' . $e->getMessage()]);
}
