<?php
require_once 'db_service.php';
header("Content-Type: application/json; charset=UTF-8");

if (!isset($_POST['field_id'])) {
    echo json_encode(["success" => false, "message" => "Fehlende Daten. Erwarte field_id."]);
    exit();
}

$fieldId = (int)$_POST['field_id'];

$sql = "DELETE FROM fields WHERE id = :id";
$stmt = $pdo->prepare($sql);

if ($stmt->execute([':id' => $fieldId])) {
    if ($stmt->rowCount() > 0) {
        echo json_encode(["success" => true, "message" => "Feld erfolgreich gelöscht."]);
    } else {
        echo json_encode(["success" => false, "message" => "Feld ID $fieldId nicht gefunden."]);
    }
} else {
    $errorInfo = $stmt->errorInfo();
    echo json_encode(["success" => false, "message" => "Fehler beim Löschen. SQL-Fehler: " . $errorInfo[2]]);
}
