<?php
require_once 'db_config.php';
header("Content-Type: application/json; charset=UTF-8");


$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Verbindungsfehler: " . $conn->connect_error]);
    exit();
}

// Überprüfen, ob field_owner_id gesendet wurde
if (!isset($_POST['field_owner_id'])) {
    echo json_encode(["success" => false, "message" => "Keine Field Owner ID angegeben."]);
    exit();
}

$fieldOwnerId = (int)$_POST['field_owner_id'];
$fields = [];

// SQL-Abfrage: Alle Felder abrufen, die diese field_owner_id haben
$stmt = $conn->prepare("SELECT f.id, f.fieldname, f.description, f.street, f.housenumber, f.postalcode, f.rules, f.city, f.company, f.checkstate AS checkstate_id, c.status_name AS checkstatename, c.color_hint FROM fields f JOIN checkstate c ON f.checkstate = c.id WHERE f.field_owner_id = ?");
$stmt->bind_param("i", $fieldOwnerId);
$stmt->execute();
$result = $stmt->get_result();

while ($row = $result->fetch_assoc()) {
    $fields[] = $row;
}
$stmt->close();
$conn->close();

echo json_encode(["success" => true, "fields" => $fields]);
?>