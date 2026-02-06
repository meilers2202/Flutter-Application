<?php
require_once 'db_service.php';

$sql = "SELECT id, name FROM ingameroles ORDER BY id";
$stmt = $pdo->query($sql);
$roles = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode(["success" => true, "roles" => $roles]);
?>