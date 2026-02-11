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
        'SELECT f.id, f.fieldname, f.description, f.rules, f.street, f.housenumber, f.postalcode, f.city, f.company, f.home_team_id, g.name AS home_team_name, f.field_owner_id, f.checkstate FROM fields f LEFT JOIN groups g ON f.home_team_id = g.id WHERE f.id = :id LIMIT 1'
    );
    $stmt->execute(['id' => $fieldIdInt]);
    $field = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$field) {
        echo json_encode(['success' => false, 'message' => 'Feld nicht gefunden.']);
        exit;
    }

    $field['id'] = (int)$field['id'];
    $field['field_owner_id'] = (int)$field['field_owner_id'];
    $field['home_team_id'] = isset($field['home_team_id']) ? (int)$field['home_team_id'] : null;
    $field['checkstate'] = isset($field['checkstate']) ? (int)$field['checkstate'] : null;

    echo json_encode(['success' => true, 'field' => $field]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Fehler bei der Datenbankabfrage: ' . $e->getMessage()]);
}
