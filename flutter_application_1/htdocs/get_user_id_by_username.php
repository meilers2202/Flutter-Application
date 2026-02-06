<?php
header("Content-Type: application/json; charset=UTF-8");
require_once 'db_service.php';

$inputUsername = $_POST['username'] ?? null;

if (!$inputUsername) {
    echo json_encode(["success" => false, "message" => "Kein Benutzername angegeben."]);
    exit;
}

try {
    $stmt = $pdo->prepare("SELECT id FROM users WHERE username = :username");
    $stmt->execute(['username' => $inputUsername]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user) {
        echo json_encode(["success" => true, "userId" => (int)$user['id']]);
    } else {
        echo json_encode(["success" => false, "message" => "Benutzer nicht gefunden."]);
    }
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Fehler: " . $e->getMessage()]);
}
