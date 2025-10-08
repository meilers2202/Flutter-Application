<?php
require_once 'db_service.php';
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'message' => 'Ungültige Anfragemethode.']);
    exit();
}

$id = $_POST['id'] ?? null;
$fieldname = $_POST['fieldname'] ?? null;
$description = $_POST['description'] ?? null;
$rules = $_POST['rules'] ?? null;
$street = $_POST['street'] ?? null;
$housenumber = $_POST['housenumber'] ?? null;
$city = $_POST['city'] ?? null;
$company = $_POST['company'] ?? null;

if (!$id || !$fieldname) {
    echo json_encode(['success' => false, 'message' => 'Feld-ID oder Feldname fehlt.']);
    exit();
}

$sql = "UPDATE fields SET fieldname = :fieldname, description = :description, rules = :rules, street = :street, housenumber = :housenumber, city = :city, company = :company WHERE id = :id";

$stmt = $pdo->prepare($sql);

$params = [
    ':fieldname' => $fieldname,
    ':description' => $description,
    ':rules' => $rules,
    ':street' => $street,
    ':housenumber' => $housenumber,
    ':city' => $city,
    ':company' => $company,
    ':id' => $id,
];

if ($stmt->execute($params)) {
    if ($stmt->rowCount() > 0) {
        echo json_encode(['success' => true, 'message' => 'Feld erfolgreich aktualisiert.']);
    } else {
        echo json_encode(['success' => true, 'message' => 'Keine Änderungen vorgenommen oder Feld nicht gefunden.']);
    }
} else {
    $errorInfo = $stmt->errorInfo();
    echo json_encode(['success' => false, 'message' => 'Fehler beim Aktualisieren des Feldes: ' . $errorInfo[2]]);
}
