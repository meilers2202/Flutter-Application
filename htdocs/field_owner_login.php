<?php
require_once 'db_service.php';
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Eingangsdaten lesen (JSON oder x-www-form-urlencoded)
$data = json_decode(file_get_contents("php://input"), true);
$username = $data['username'] ?? $_POST['username'] ?? null;
$password = $data['password'] ?? $_POST['password'] ?? null;

if (!$username || !$password) {
    echo json_encode(["success" => false, "message" => "Benutzername oder Passwort fehlt."]);
    exit;
}

try {
    // 1. fieldowner prüfen
    $stmt = $pdo->prepare("SELECT user_id FROM fieldowner WHERE name = :username");
    $stmt->execute(['username' => $username]);
    $fieldOwner = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$fieldOwner) {
        echo json_encode(["success" => false, "message" => "Benutzername ist kein Field Owner."]);
        exit;
    }

    $user_id = $fieldOwner['user_id'];

    // 2. Nutzer mit dieser ID holen
    $stmt = $pdo->prepare("SELECT username, password FROM users WHERE id = :user_id");
    $stmt->execute(['user_id' => $user_id]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        echo json_encode(["success" => false, "message" => "Benutzerdaten konnten nicht gefunden werden."]);
        exit;
    }

    // 3. Benutzername abgleichen (zur Sicherheit)
    if ($user['username'] !== $username) {
        echo json_encode(["success" => false, "message" => "Benutzerdaten stimmen nicht überein."]);
        exit;
    }

    // 4. Passwort prüfen
    if (password_verify($password, $user['password'])) {
        echo json_encode([
            "success" => true,
            "message" => "Anmeldung erfolgreich!",
            "username" => $user['username']
        ]);
    } else {
        echo json_encode(["success" => false, "message" => "Falsches Passwort."]);
    }

} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Fehler: " . $e->getMessage()]);
}
