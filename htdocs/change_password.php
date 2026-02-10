<?php
require_once 'db_service.php';

// Erwartet: POST: username, current_password, new_password
if (!isset($_POST['username']) || !isset($_POST['current_password']) || !isset($_POST['new_password'])) {
    echo json_encode(["success" => false, "message" => "Erwarte: username, current_password, new_password"]);
    exit;
}

$username = $_POST['username'];
$current = $_POST['current_password'];
$new = $_POST['new_password'];

try {
    $stmt = $pdo->prepare("SELECT id, password FROM users WHERE username = :username");
    $stmt->execute(['username' => $username]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        echo json_encode(["success" => false, "message" => "Benutzer nicht gefunden."]);
        exit;
    }

    if (!password_verify($current, $user['password'])) {
        echo json_encode(["success" => false, "message" => "Aktuelles Passwort ist falsch."]);
        exit;
    }

    // Passwort-Update
    $hashed = password_hash($new, PASSWORD_DEFAULT);
    $upd = $pdo->prepare("UPDATE users SET password = :pw, force_password_change = 0 WHERE id = :id");
    $upd->execute(['pw' => $hashed, 'id' => $user['id']]);

    if ($upd->rowCount() > 0) {
        echo json_encode(["success" => true, "message" => "Passwort erfolgreich geändert."]);
    } else {
        echo json_encode(["success" => false, "message" => "Fehler beim Aktualisieren des Passworts."]);
    }
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Datenbankfehler: " . $e->getMessage()]);
}

?>