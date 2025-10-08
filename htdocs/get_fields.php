<?php
require_once 'db_service.php'; // stellt $pdo bereit

try {
    $stmt = $pdo->query("SELECT id, fieldname, description, rules, street, housenumber, postalcode, city, company, field_owner_id, checkstate FROM fields");
    $fields = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Typcasting der int-Felder vor json_encode
    if ($fields) {
        foreach ($fields as &$field) {
            $field['id'] = (int)$field['id'];
            $field['field_owner_id'] = (int)$field['field_owner_id'];
            // Falls checkstate auch integer ist, casten:
            $field['checkstate'] = isset($field['checkstate']) ? (int)$field['checkstate'] : null;
            // Weitere Integerfelder bei Bedarf hier casten
        }
    }

    echo json_encode([
        "success" => true,
        "fields" => $fields ?: [],
        "message" => empty($fields) ? "Keine registrierten Spielfelder gefunden." : null
    ]);
} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Fehler bei der Datenbankabfrage: " . $e->getMessage()
    ]);
}
