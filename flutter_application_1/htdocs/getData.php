<?php
require_once 'db_config.php';
header("Content-Type: application/json; charset=UTF-8");


$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["error" => "Verbindung fehlgeschlagen: " . $conn->connect_error]));
}

// SQL-Abfrage
$sql = "SELECT * FROM deine_tabelle"; // Ersetze mit deinem Tabellennamen
$result = $conn->query($sql);

$data = array();
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
}

echo json_encode($data);

$conn->close();
?>