<?php
require_once 'db_service.php';

if (!isset($_POST['field_owner_id'])) {
    echo json_encode(["success" => false, "message" => "Keine Field Owner ID angegeben."]);
    exit();
}

$fieldOwnerId = (int)$_POST['field_owner_id'];

$sql = "SELECT f.id, f.fieldname, f.description, f.street, f.housenumber, f.postalcode, 
               f.rules, f.city, f.company, f.checkstate AS checkstate_id, 
               c.status_name AS checkstatename, c.color_hint 
        FROM fields f 
        JOIN checkstate c ON f.checkstate = c.id 
        WHERE f.field_owner_id = :field_owner_id";

$stmt = $pdo->prepare($sql);
$stmt->execute(['field_owner_id' => $fieldOwnerId]);
$fields = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode([
    "success" => true,
    "fields" => $fields
]);
