<?php
require_once 'db_service.php'; // stellt $pdo bereit

try {
    // 1. Prüfen, ob field_id und new_status übergeben wurden
    $fieldId = $_POST['field_id'] ?? null;
    $newStatus = $_POST['new_status'] ?? null;

    if ($fieldId === null || $newStatus === null) {
        echo json_encode(['success' => false, 'message' => 'Unvollständige Daten. Erwarte field_id und new_status.']);
        exit;
    }

    // 2. Sicheres Casting auf Integer
    $fieldIdInt = (int)$fieldId;
    $newStatusInt = (int)$newStatus;

    // optional: validieren, ob newStatusInt in erlaubtem Bereich liegt (z.B. 0-3)
    $allowed = [0,1,2,3];
    if (!in_array($newStatusInt, $allowed, true)) {
        echo json_encode(['success' => false, 'message' => 'Ungültiger Status-Wert.']);
        exit;
    }

    // 3. Update mit Prepared Statement (PDO)
    $sql = "UPDATE fields SET checkstate = :newStatus WHERE id = :id";
    $stmt = $pdo->prepare($sql);
    $executed = $stmt->execute([
        'newStatus' => $newStatusInt,
        'id' => $fieldIdInt
    ]);

    if ($executed) {
        if ($stmt->rowCount() > 0) {
            echo json_encode(['success' => true, 'message' => "Status erfolgreich auf $newStatusInt geändert."]);
        } else {
            echo json_encode(['success' => false, 'message' => "Feld ID $fieldIdInt nicht gefunden oder Status bereits $newStatusInt."]);
        }
    } else {
        $err = $stmt->errorInfo();
        echo json_encode(['success' => false, 'message' => 'Fehler beim Update: ' . ($err[2] ?? 'Unbekannter Fehler')]);
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Datenbankfehler: ' . $e->getMessage()]);
}
