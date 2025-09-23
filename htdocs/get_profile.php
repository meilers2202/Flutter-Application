<?php
require_once 'db_config.php';
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

$conn = new mysqli($servername, $username, $password, $dbname);
$username_to_fetch = $_POST['username'] ?? null;
if ($username_to_fetch === null) {
    echo json_encode(["success" => false, "message" => "Benutzername fehlt."]);
    exit();
}

$stmt = $conn->prepare("SELECT users.username, users.email, users.city, users.created_at, users.role as userRole, groups.name AS team, roles.name AS teamrole FROM users LEFT JOIN groups ON users.group_id = groups.id LEFT JOIN roles ON users.teamrole = roles.id WHERE users.username = ?");

$stmt->bind_param("s", $username_to_fetch);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $memberSince = date("d.m.Y", strtotime($row['created_at']));
    
    echo json_encode([
        "success" => true,
        "user" => [
            "username" => $row['username'],
            "email" => $row['email'],
            "city" => $row['city'],
            "team" => $row['team'],
            "memberSince" => $memberSince,
            "teamrole" => $row['teamrole'],
            "role" => $row['userRole']
        ]
    ]);
} else {
    echo json_encode(["success" => false, "message" => "Benutzer nicht gefunden."]);
}

$stmt->close();
$conn->close();
?>