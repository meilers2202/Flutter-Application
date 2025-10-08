<?php
require_once 'db_service.php';

if (isset($_POST['username']) && isset($_POST['password'])) {
    $inputUsername = $_POST['username'];
    $inputPassword = $_POST['password'];

    $sql = 'SELECT users.username, users.password, users.email, users.city, users.created_at, users.role, groups.name AS team 
            FROM users 
            LEFT JOIN groups ON users.group_id = groups.id 
            WHERE users.username = :username';

    $stmt = $pdo->prepare($sql);
    $stmt->execute(['username' => $inputUsername]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user) {
        if (password_verify($inputPassword, $user['password'])) {
            echo json_encode([
                "success" => true,
                "message" => "Login erfolgreich!",
                "username" => $user['username'],
                "email" => $user['email'],
                "city" => $user['city'],
                "team" => $user['team'],
                "memberSince" => $user['created_at'],
                "role" => $user['role']
            ]);
        } else {
            echo json_encode(["success" => false, "message" => "Falsches Passwort."]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Benutzer existiert nicht."]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Username und Passwort erforderlich."]);
}
