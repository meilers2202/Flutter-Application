<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
require_once 'db_service.php';

$username_to_fetch = $_POST['username'] ?? null;

if ($username_to_fetch === null) {
    echo json_encode(["success" => false, "message" => "Benutzername fehlt."]);
    exit;
}

$sql = "SELECT 
            users.username, 
            users.email, 
            users.city, 
            users.created_at, 
            users.role as userRole, 
            groups.name AS team, 
            roles.name AS teamrole, 
            ingameroles.name AS ingamerole,
        FROM users 
        LEFT JOIN groups ON users.group_id = groups.id 
        LEFT JOIN roles ON users.teamrole = roles.id 
        LEFT JOIN ingameroles ON users.ingamerole_id = ingameroles.id
        WHERE users.username = :username";

$stmt = $pdo->prepare($sql);
$stmt->execute(['username' => $username_to_fetch]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if ($user) {
    $memberSince = date("d.m.Y", strtotime($user['created_at']));

    echo json_encode([
        "success" => true,
        "user" => [
            "username" => $user['username'],
            "email" => $user['email'],
            "city" => $user['city'],
            "team" => $user['team'],
            "memberSince" => $memberSince,
            "teamrole" => $user['teamrole'],
            "role" => $user['userRole']
            "ingamerole" => $user['ingamerole'],
        ]
    ]);
} else {
    echo json_encode(["success" => false, "message" => "Benutzer nicht gefunden."]);
}
