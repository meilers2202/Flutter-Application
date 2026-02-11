## GitHub Update (11.02.2026)

### Dateien geaendert/neu/geloescht

**Geaendert (Flutter/Dart):**
- lib/pages/user_pages/main_page/field_review_page2.dart
    - User-Feldansicht zeigt jetzt Bilder, Events und Pricing mit Detail-Dialogen.
    - Laden der Daten ueber eigene Fetcher (Events/Bilder/Pricing) + Bild-Preview mit Zoom.
- lib/pages/user_pages/settings_page/admin_pages/field_review_page.dart
    - Unnoetige `toList()` Aufrufe in Spread-Operatoren entfernt.
- lib/pages/user_pages/settings_page/field_owner_pages/field_details_page.dart
    - Unnoetige `toList()` Aufrufe in Spread-Operatoren entfernt.
    - `context.mounted` Guard nach DatePicker-Async-Gap.
    - Dropdowns auf `initialValue` umgestellt.
- lib/pages/user_pages/settings_page/field_owner_pages/create_field.dart
    - Dropdown auf `initialValue` umgestellt (deprecated `value` entfernt).
- lib/pages/user_pages/settings_page/field_owner_pages/edit_field_page.dart
    - `withOpacity` durch `withValues(alpha: ...)` ersetzt.
    - Dropdown auf `initialValue` umgestellt.

## GitHub Update (12.02.2026)

### Dateien geändert/neu/gelöscht

**Neu (SQL/DB):**
- db_migrations/2026-02-12-field-event-location-coords.sql
    - Event-Standort per Koordinaten (lat/lng).
- db_migrations/2026-02-12-field-pricing-packages.sql
    - Pricing-Pakete pro Feld.

**Geaendert (PHP):**
- htdocs/add_field_event.php
    - Koordinaten speichern, Tickets optional, Chrono/Briefing optional, Limit-Wert optional.
- htdocs/get_field_events.php
    - Koordinaten mitliefern.
- htdocs/update_field_event.php
    - Koordinaten aktualisieren, Tickets optional, Limit-Wert optional.
 - htdocs/get_field_pricing.php
     - Pricing-Pakete eines Feldes laden.
 - htdocs/add_field_pricing.php
     - Pricing-Paket anlegen.
 - htdocs/update_field_pricing.php
     - Pricing-Paket bearbeiten.
 - htdocs/delete_field_pricing.php
     - Pricing-Paket loeschen.

**Geaendert (Flutter/Dart):**
- lib/pages/user_pages/settings_page/field_owner_pages/field_details_page.dart
    - Event-Dialog mit Karten-Position, optionaler Adresse, Pflicht-Ausrustung als Liste.
    - Klassen-Limits mit Pflicht-Dropdown, Limit-Wert optional, Tickets nur bei Bedarf.
    - Karten-AppBar angepasst + Adresse per Reverse-Geocoding in das Adressfeld.
    - Eventliste zeigt Titel + kurzen Zeitraum; Detailansicht mit Bearbeiten.
    - Pricing-Sektion mit Paketen, Dialog zum Hinzufuegen/Bearbeiten/Loeschen.
- lib/pages/user_pages/settings_page/admin_pages/field_review_page.dart
    - Admin-Ansicht zeigt Events, Bilder und Pricing inklusive Detail-Dialogen.

## GitHub Update (11.02.2026)

### Dateien geändert/neu/gelöscht

**Neu (SQL/DB):**
- db_migrations/2026-02-11-fields-events-images.sql
    - Migrationen: `home_team_id` in `fields`, neue Tabellen `field_events` und `field_images`.
- db_migrations/2026-02-11-field-events-details.sql
    - Erweiterte Eventfelder + Ticket-Tabelle fuer Preisstufen.
- db_migrations/2026-02-11-field-event-power-limits.sql
    - Event-Tabellen fuer Joule/FPS Limits pro Klasse.

**Neu (PHP):**
- htdocs/get_field_events.php
    - Events eines Feldes laden.
- htdocs/add_field_event.php
    - Event anlegen.
- htdocs/update_field_event.php
    - Event bearbeiten.
- htdocs/delete_field_event.php
    - Event löschen.
- htdocs/get_field_images.php
    - Bilder eines Feldes laden.
- htdocs/add_field_image.php
    - Bild hinzufügen.
- htdocs/delete_field_image.php
    - Bild löschen.
- htdocs/set_field_image_cover.php
    - Cover-Bild setzen.

**Geändert (PHP):**
- htdocs/get_field_owners_data.php
    - Rückgabe erweitert, `user_id` + `name`.
- htdocs/create_field.php
    - `home_team_id` unterstützen.
- htdocs/update_field.php
    - `home_team_id` unterstützen.
- htdocs/get_fields.php
    - `home_team_id` + `home_team_name` mitsenden.
- htdocs/get_field_by_id.php
    - `home_team_id` + `home_team_name` mitsenden.
- htdocs/fetch_fields_by_owner_id.php
    - `home_team_id` + `home_team_name` mitsenden.
- htdocs/remove_field_owner.php
    - Fieldowner entfernen + Felder auf "Abgelehnt" setzen.
- htdocs/add_field_image.php
    - Upload via `multipart/form-data` (Bilddatei) + Speicherung unter `IMAGES/FIELD/<field_id>/`.
- htdocs/delete_field_image.php
    - Loescht lokale Upload-Datei in `IMAGES/FIELD` oder `uploads/field_images`, wenn vorhanden.
- htdocs/add_field_event.php
    - Erweiterte Eventfelder + Ticket-Preisstufen + Joule/FPS Limits speichern.
- htdocs/get_field_events.php
    - Eventdetails + Ticket-Preisstufen + Joule/FPS Limits mitliefern.
- htdocs/update_field_event.php
    - Eventdetails + Ticket-Preisstufen + Joule/FPS Limits aktualisieren.

**Geändert (Flutter/Dart):**
- lib/service/database_models.dart
    - Field-Model um `homeTeamId`/`homeTeamName` erweitert.
- lib/pages/user_pages/settings_page/admin_pages/field_page.dart
    - Admin-Fields-Model um Heimteam erweitert.
- lib/pages/user_pages/settings_page/field_owner_pages/field_owner_main.dart
    - Fieldowner-Model um Heimteam erweitert + Hintergrundbild.
- lib/pages/user_pages/settings_page/field_owner_pages/create_field.dart
    - Heimteam-Dropdown + `home_team_id` senden + Hintergrundbild.
- lib/pages/user_pages/settings_page/field_owner_pages/edit_field_page.dart
    - Heimteam-Dropdown Styling angepasst + `home_team_id` senden + Hintergrundbild.
    - Bild-Upload per Galerie/Kamera, Vorschau im Edit, Loeschen von Bildern.
    - Darkmode-Styles fuer Inputs/Background verbessert.
- lib/pages/user_pages/settings_page/field_owner_pages/field_details_page.dart
    - Events/Bilder/Heimteam live aus DB laden + Hintergrundbild.
    - Bild-Preview (gross) per Tap; schliessen per X oder Tap ausserhalb; Zoom per Zwei-Finger-Geste.
    - Button "+ Event hinzufuegen" in der Events-Sektion.
    - Event-Dialog mit Pflichtfeldern, Sicherheit, Ticket-Preisstufen und Joule/FPS Limits pro Klasse.
- lib/pages/user_pages/settings_page/admin_pages/field_owner_list.dart
    - Fieldowner klickbar, Details + Entfernen möglich.