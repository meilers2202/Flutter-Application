<?php
require_once 'db_service.php'; // stellt $pdo bereit

try {
    $stmt = $pdo->query("SELECT f.id, f.fieldname, f.description, f.rules, f.street, f.housenumber, f.postalcode, f.city, f.company, f.home_team_id, g.name AS home_team_name, f.field_owner_id, f.checkstate FROM fields f LEFT JOIN groups g ON f.home_team_id = g.id");
    $fields = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Typcasting der int-Felder vor json_encode
    if ($fields) {
        foreach ($fields as &$field) {
            $field['id'] = (int)$field['id'];
            $field['field_owner_id'] = (int)$field['field_owner_id'];
            $field['home_team_id'] = isset($field['home_team_id']) ? (int)$field['home_team_id'] : null;
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
