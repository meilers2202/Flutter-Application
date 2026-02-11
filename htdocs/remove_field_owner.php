<?php
require_once 'db_service.php';
header('Content-Type: application/json; charset=utf-8');

if (!isset($_POST['field_owner_id'])) {
    echo json_encode(["success" => false, "message" => "Keine Field Owner ID angegeben."]);
    exit();
}

$fieldOwnerId = (int)$_POST['field_owner_id'];

try {
    $pdo->beginTransaction();

    // Felder des Fieldowners auf "Abgelehnt" setzen (checkstate = 3)
    $upd = $pdo->prepare("UPDATE fields SET checkstate = 3 WHERE field_owner_id = :id");
    $upd->execute(['id' => $fieldOwnerId]);

    // Fieldowner entfernen
    $del = $pdo->prepare("DELETE FROM fieldowner WHERE user_id = :id");
    $del->execute(['id' => $fieldOwnerId]);

    $pdo->commit();

    if ($del->rowCount() > 0) {
        echo json_encode([
            "success" => true,
            "message" => "Fieldowner entfernt. Felder wurden auf Abgelehnt gesetzt.",
            "fields_updated" => $upd->rowCount(),
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Fieldowner nicht gefunden.",
            "fields_updated" => $upd->rowCount(),
        ]);
    }
} catch (Throwable $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    echo json_encode([
        "success" => false,
        "message" => "Serverfehler: " . $e->getMessage(),
    ]);
}
