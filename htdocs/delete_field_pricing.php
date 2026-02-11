<?php
require_once 'db_service.php';
header('Content-Type: application/json; charset=utf-8');

$id = $_POST['id'] ?? null;
if (!$id) {
    echo json_encode(['success' => false, 'message' => 'id fehlt.']);
    exit;
}

try {
    $stmt = $pdo->prepare('DELETE FROM field_pricing_packages WHERE id = :id');
    $stmt->execute(['id' => (int)$id]);
    echo json_encode(['success' => true, 'message' => 'Paket geloescht.']);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Fehler: ' . $e->getMessage()]);
}
