<?php
require_once 'db_service.php';

$action = $_POST['action'] ?? ''; // 'add' oder 'delete'
$name = $_POST['name'] ?? '';
$id = $_POST['id'] ?? null;

try {
    if ($action === 'add' && !empty(trim($name))) {
        $stmt = $pdo->prepare("INSERT INTO ingameroles (name) VALUES (:name)");
        $stmt->execute(['name' => trim($name)]);
        echo json_encode(["success" => true, "message" => "Rang hinzugefügt."]);

    } elseif ($action === 'delete' && is_numeric($id)) {
        // Prüfen, ob noch Benutzer diesen Rang haben (optional)
        $check = $pdo->prepare("SELECT COUNT(*) FROM users WHERE ingamerole_id = :id");
        $check->execute(['id' => $id]);
        if ($check->fetchColumn() > 0) {
            echo json_encode(["success" => false, "message" => "Rang wird noch von Benutzern verwendet und kann nicht gelöscht werden."]);
            exit;
        }

        $stmt = $pdo->prepare("DELETE FROM ingameroles WHERE id = :id");
        $stmt->execute(['id' => $id]);
        echo json_encode(["success" => true, "message" => "Rang gelöscht."]);

    } else {
        echo json_encode(["success" => false, "message" => "Ungültige Aktion oder fehlende Daten."]);
    }
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Fehler: " . $e->getMessage()]);
}
?>