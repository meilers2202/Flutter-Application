<?php
require_once 'db_config.php';
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Verbindungsfehler: " . $conn->connect_error]);
    exit();
}

// 1. Prüfen, ob Feld-ID und neuer Status übergeben wurden
if (isset($_POST['field_id']) && isset($_POST['new_status'])) {
    $fieldId = $_POST['field_id'];
    $newStatus = $_POST['new_status'];

    // 2. Sicherstellen, dass die Status-ID ein gültiger Integer ist (z.B. 0, 1, 2, 3)
    $newStatusInt = intval($newStatus);
    $fieldIdInt = intval($fieldId);

    // 3. SQL-Update-Anweisung
    // Wir verwenden Prepared Statements, um SQL Injection zu verhindern
    $stmt = $conn->prepare("UPDATE fields SET checkstate = ? WHERE id = ?");
    
    // Die Parameter binden: ii = Integer (Status), Integer (Field ID)
    if (!$stmt->bind_param("ii", $newStatusInt, $fieldIdInt)) {
        echo json_encode(["success" => false, "message" => "Bindungsfehler: " . $stmt->error]);
        $stmt->close();
        $conn->close();
        exit();
    }

    // 4. Update ausführen
    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode(["success" => true, "message" => "Status erfolgreich auf $newStatusInt geändert."]);
        } else {
            echo json_encode(["success" => false, "message" => "Feld ID $fieldIdInt nicht gefunden oder Status bereits $newStatusInt."]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Fehler beim Update. SQL-Fehler: " . $stmt->error]);
    }

    $stmt->close();
} else {
    echo json_encode(["success" => false, "message" => "Unvollständige Daten. Erwarte field_id und new_status."]);
}

$conn->close();
?>