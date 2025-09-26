<?php
require_once 'db_config.php';
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Verbindungsfehler: " . $conn->connect_error]);
    exit();
}

if (isset($_POST['field_id'])) {
    $fieldId = $_POST['field_id'];

    // SQL-Delete-Anweisung
    $stmt = $conn->prepare("DELETE FROM fields WHERE id = ?");
    
    // Die Parameter binden: i = Integer (Field ID)
    if (!$stmt->bind_param("i", $fieldId)) {
        echo json_encode(["success" => false, "message" => "Bindungsfehler: " . $stmt->error]);
        $stmt->close();
        $conn->close();
        exit();
    }

    // Löschvorgang ausführen
    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode(["success" => true, "message" => "Feld erfolgreich gelöscht."]);
        } else {
            echo json_encode(["success" => false, "message" => "Feld ID $fieldId nicht gefunden."]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Fehler beim Löschen. SQL-Fehler: " . $stmt->error]);
    }

    $stmt->close();
} else {
    echo json_encode(["success" => false, "message" => "Fehlende Daten. Erwarte field_id."]);
}

$conn->close();
?>