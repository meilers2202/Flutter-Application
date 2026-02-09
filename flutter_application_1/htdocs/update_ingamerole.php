<?php
require_once 'db_service.php';

// Erwartet POST: username, ingamerole_id
if (!isset($_POST['username']) || !isset($_POST['ingamerole_id'])) {
    echo json_encode(["success" => false, "message" => "Erwarte: username, ingamerole_id"]);
    exit;
}

$username = $_POST['username'];
$roleId = $_POST['ingamerole_id'];

if (!is_numeric($roleId)) {
    echo json_encode(["success" => false, "message" => "Ungültige Rollen-ID"]);
    exit;
}

try {
    // Prüfen, ob die Rolle existiert
    $chk = $pdo->prepare("SELECT id FROM ingameroles WHERE id = :id");
    $chk->execute(['id' => $roleId]);
    if (!$chk->fetch()) {
        echo json_encode(["success" => false, "message" => "Rolle nicht gefunden"]);
        exit;
    }

    // Update des Benutzers
    $upd = $pdo->prepare("UPDATE users SET ingamerole_id = :rid WHERE username = :username");
    $upd->execute(['rid' => $roleId, 'username' => $username]);

    if ($upd->rowCount() > 0) {
        echo json_encode(["success" => true, "message" => "Rang erfolgreich aktualisiert."]);
    } else {
        echo json_encode(["success" => false, "message" => "Kein Update durchgeführt (Benutzer nicht gefunden oder gleiche Rolle)."]);
    }
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Datenbankfehler: " . $e->getMessage()]);
}

?>