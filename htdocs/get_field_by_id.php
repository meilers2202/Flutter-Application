<?php
require_once 'db_service.php';
header('Content-Type: application/json');

$fieldId = $_POST['field_id'] ?? null;
if ($fieldId === null) {
    echo json_encode(['success' => false, 'message' => 'field_id fehlt.']);
    exit;
}

$fieldIdInt = (int)$fieldId;

try {
    $stmt = $pdo->prepare(
        'SELECT id, fieldname, description, rules, street, housenumber, postalcode, city, company, field_owner_id, checkstate FROM fields WHERE id = :id LIMIT 1'
    );
    $stmt->execute(['id' => $fieldIdInt]);
    $field = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$field) {
        echo json_encode(['success' => false, 'message' => 'Feld nicht gefunden.']);
        exit;
    }

    $field['id'] = (int)$field['id'];
    $field['field_owner_id'] = (int)$field['field_owner_id'];
    $field['checkstate'] = isset($field['checkstate']) ? (int)$field['checkstate'] : null;

    echo json_encode(['success' => true, 'field' => $field]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Fehler bei der Datenbankabfrage: ' . $e->getMessage()]);
}
