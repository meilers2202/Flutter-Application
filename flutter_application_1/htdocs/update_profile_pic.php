<?php
// update_profile_pic.php – Robustes, fehlertolerantes Profilbild-Upload-Skript

// ************************************************
// SCHRITT 0: Sicherheits- und Fehlerkonfiguration
// ************************************************
ob_start();
header('Content-Type: application/json; charset=utf-8');

// Nur im Entwicklungsmodus aktivieren!
// ini_set('display_errors', 1);
// ini_set('display_startup_errors', 1);
// error_reporting(E_ALL);

// Deaktiviere Skript-Timeout für große Uploads (optional)
set_time_limit(60);

// ************************************************
// SCHRITT 1: Abhängigkeiten laden
// ************************************************
require_once __DIR__ . '/db_service.php';

// ************************************************
// SCHRITT 2: Konstanten definieren
// ************************************************
const ALLOWED_EXTENSIONS = ['jpg', 'jpeg', 'png', 'gif'];
const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5 MB
const UPLOAD_BASE_DIR = __DIR__ . '/IMAGES/USER/';

// ************************************************
// SCHRITT 3: Hilfsfunktionen
// ************************************************
function sendJson($data) {
    ob_clean();
    echo json_encode($data, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
    exit;
}

function logError($message) {
    error_log("[PROFILE_PIC_UPLOAD] " . $message . " | IP: " . ($_SERVER['REMOTE_ADDR'] ?? 'unknown'));
}

// ************************************************
// SCHRITT 4: Eingabevalidierung
// ************************************************

// POST-Daten prüfen
if (!isset($_POST['username']) || empty(trim($_POST['username']))) {
    logError("Fehlender oder leerer Benutzername");
    sendJson(['success' => false, 'message' => 'Benutzername fehlt oder ist ungültig.']);
}
$username = trim($_POST['username']);

// Datei prüfen
if (!isset($_FILES['profile_pic'])) {
    logError("Keine Datei im Upload erhalten");
    sendJson(['success' => false, 'message' => 'Keine Bilddatei ausgewählt.']);
}

$file = $_FILES['profile_pic'];

// Upload-Fehler prüfen
if ($file['error'] !== UPLOAD_ERR_OK) {
    $errors = [
        UPLOAD_ERR_INI_SIZE => 'Datei überschreitet upload_max_filesize in php.ini.',
        UPLOAD_ERR_FORM_SIZE => 'Datei überschreitet MAX_FILE_SIZE im Formular.',
        UPLOAD_ERR_PARTIAL => 'Datei wurde nur teilweise hochgeladen.',
        UPLOAD_ERR_NO_FILE => 'Keine Datei ausgewählt.',
        UPLOAD_ERR_NO_TMP_DIR => 'Temporärer Ordner fehlt.',
        UPLOAD_ERR_CANT_WRITE => 'Fehler beim Schreiben der Datei auf die Festplatte.',
        UPLOAD_ERR_EXTENSION => 'Upload durch PHP-Erweiterung gestoppt.'
    ];
    $errorMsg = $errors[$file['error']] ?? 'Unbekannter Upload-Fehler.';
    logError("Upload-Fehler (Code {$file['error']}): $errorMsg");
    sendJson(['success' => false, 'message' => $errorMsg]);
}

// Dateigröße prüfen
if ($file['size'] > MAX_FILE_SIZE) {
    logError("Datei zu groß: {$file['size']} Bytes");
    sendJson(['success' => false, 'message' => 'Datei darf maximal 5 MB groß sein.']);
}

// Dateiname und Erweiterung prüfen
$originalName = basename($file['name']);
$extension = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));

if (!in_array($extension, ALLOWED_EXTENSIONS)) {
    logError("Ungültige Dateierweiterung: $extension");
    sendJson(['success' => false, 'message' => 'Nur JPG, JPEG, PNG und GIF sind erlaubt.']);
}

// ************************************************
// SCHRITT 5: Benutzer prüfen
// ************************************************
try {
    $stmt = $pdo->prepare("SELECT id FROM users WHERE username = :username");
    $stmt->execute(['username' => $username]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        logError("Benutzer nicht gefunden: $username");
        sendJson(['success' => false, 'message' => "Benutzer '$username' existiert nicht."]);
    }
    $user_id = (int)$user['id'];
} catch (PDOException $e) {
    logError("Datenbankfehler bei Benutzersuche: " . $e->getMessage());
    sendJson(['success' => false, 'message' => 'Datenbankfehler. Bitte versuchen Sie es später erneut.']);
}

$def_fn = 'LOGOS.';

// ************************************************
// SCHRITT 6: Zielverzeichnis vorbereiten
// ************************************************
$targetDir = UPLOAD_BASE_DIR . $user_id . '/';
$finalFilename = $def_fn . $extension;
$targetPath = $targetDir . $finalFilename;

// Verzeichnis rekursiv erstellen (mit Berechtigungsprüfung)
if (!is_dir($targetDir)) {
    if (!mkdir($targetDir, 0755, true)) {
        logError("Verzeichnis konnte nicht erstellt werden: $targetDir");
        sendJson(['success' => false, 'message' => 'Interner Serverfehler: Upload-Verzeichnis nicht erstellbar.']);
    }
}

// Berechtigungen explizit setzen (optional, aber sicherer)
chmod($targetDir, 0755);

// ************************************************
// ✨ NEU: Alte LOGO-Dateien löschen (alle Formate)
// ************************************************
$possible_extensions = ['jpg', 'jpeg', 'png', 'gif'];
foreach ($possible_extensions as $ext) {
    $oldFile = $targetDir . $def_fn . $ext;
    if (file_exists($oldFile)) {
        if (!unlink($oldFile)) {
            logError("Konnte alte Profilbild-Datei nicht löschen: $oldFile");
            // Fortfahren trotz Fehler – ggf. wird move_uploaded_file trotzdem klappen
        }
    }
}

// ************************************************
// SCHRITT 7: Datei validieren (echte Bildprüfung!)
// ************************************************
$finfo = finfo_open(FILEINFO_MIME_TYPE);
$mimeType = finfo_file($finfo, $file['tmp_name']);
finfo_close($finfo);

$allowedMimeTypes = ['image/jpeg', 'image/png', 'image/gif'];
if (!in_array($mimeType, $allowedMimeTypes)) {
    logError("Ungültiger MIME-Typ trotz korrekter Endung: $mimeType");
    sendJson(['success' => false, 'message' => 'Die Datei ist kein gültiges Bild.']);
}

// ************************************************
// SCHRITT 8: Datei verschieben
// ************************************************
if (!move_uploaded_file($file['tmp_name'], $targetPath)) {
    logError("move_uploaded_file fehlgeschlagen für: {$file['tmp_name']} → $targetPath");
    sendJson(['success' => false, 'message' => 'Fehler beim Speichern der Datei. Bitte prüfen Sie die Serverberechtigungen.']);
}

// Berechtigungen der Datei setzen
chmod($targetPath, 0644);

// ************************************************
// SCHRITT 9: Datenbank aktualisieren
// ************************************************
try {
    $dbPath = "IMAGES/USER/$user_id/$finalFilename";
    $stmt = $pdo->prepare("UPDATE users SET profile_image_url = :path WHERE id = :id");
    $updated = $stmt->execute(['path' => $dbPath, 'id' => $user_id]);

    if (!$updated) {
        // Optional: Neue Datei löschen, wenn DB-Update fehlschlägt
        @unlink($targetPath);
        logError("Datenbank-Update fehlgeschlagen für Benutzer-ID: $user_id");
        sendJson(['success' => false, 'message' => 'Bild gespeichert, aber Datenbank konnte nicht aktualisiert werden.']);
    }
} catch (PDOException $e) {
    @unlink($targetPath);
    logError("Datenbank-Update-Fehler: " . $e->getMessage());
    sendJson(['success' => false, 'message' => 'Datenbankfehler beim Speichern des Bildpfads.']);
}

// ************************************************
// SCHRITT 10: Erfolg
// ************************************************

sendJson([
    'success' => true,
    'message' => 'Profilbild erfolgreich aktualisiert.',
    'db_path' => $dbPath
]);