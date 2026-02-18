# Flutter Application – Arbeitsprotokoll

Dieses Dokument protokolliert die durchgeführten Arbeitsschritte im Projekt.

## Protokoll

### 2026-02-18

1. Event-Adresslogik angepasst: Zeile 1+2 kombiniert (mit Komma), Zeile 3+4 kombiniert (mit Komma).
2. Datei-Diagnostics geprüft: keine Fehler.
3. Projektanalyse ausgeführt (`flutter analyze`): keine Issues gefunden.
4. README-Protokoll initial erstellt und bisherigen Ablauf dokumentiert.
5. Teamleader-Aktion erweitert: Button „Mitglieder anzeigen“ in `team_details_page.dart` ergänzt und Navigation auf `team_members.dart` eingebaut; Mitglieder werden dort als Liste dargestellt.
6. `team_members.dart` stabilisiert: ungültige Referenzen entfernt (`onTeamChange`, `userEmail`, `userCity`, `userMemberSince`) und Mitgliederansicht konsistent auf übergebene Parameter (`teamName`, `currentUsername`, `members`) umgesetzt.
7. Teamleader-Funktionen ausgelagert: neue Seite `teamleader_actions_page.dart` erstellt; `team_details_page.dart` enthält nun einen Button zur Teamleaderseite, von dort führt „Mitglieder anzeigen“ auf `team_members.dart`.
8. `team_members.dart` auf Teamleader-Management umgestellt: statt normaler Mitgliederliste werden Mitglieder (ohne aktuellen User) mit Aktionen „Mitglied entfernen“ und „Teamleitung übertragen“ angezeigt.
9. Nach „Teamleitung übertragen“ wird jetzt `onTeamChange` ausgeführt (Teamrolle auf `member`), anschließend per Navigation zurück zur MainPage gewechselt; dadurch werden Profildaten neu geladen und ein neuer Aufruf der Team-Details nutzt wieder frische Daten.
10. Teamleiter-Wechsel aktualisiert: nach erfolgreicher Übertragung werden Profildaten serverseitig neu geladen und in den AppState geschrieben; zusätzlich lädt `MainPage` vor dem Öffnen der Teamdetails das Profil neu. Damit bleiben Rollen konsistent (alter Leader wird Mitglied, Leader-Aktionen verschwinden korrekt).
11. App-Icon geändert: `flutter_launcher_icons` in `pubspec.yaml` konfiguriert und neue Launcher-Icons aus `assets/images/ppc.jpg` für Android/iOS generiert.

## Hinweis

Ab jetzt wird jeder neue Arbeitsschritt hier fortlaufend ergänzt.
Temporäre Änderungen (z. B. eingefügte Funktionen, die später wieder entfernt wurden) werden nicht dokumentiert; protokolliert werden nur finale, im aktuellen Stand vorhandene Änderungen.
Debugging-Schritte und reine Debug-Ausgaben werden nicht in dieses Protokoll aufgenommen.

## Android Update-Fix (ohne Deinstallation)

Damit Android eine neue APK als Update über die bestehende App installiert, müssen **beide** Bedingungen erfüllt sein:

1. Gleiche `applicationId` (hier: `com.pewpew.connect`) und **derselbe Keystore** für alle Release-Builds.
2. Bei jedem Release ein **höherer `versionCode`**.

### Einmalig einrichten

1. `android/key.properties.example` nach `android/key.properties` kopieren.
2. Werte in `android/key.properties` mit eurem echten Upload-Keystore füllen.
3. Keystore-Datei sicher aufbewahren (Backup); ohne diesen Key sind spätere Updates nicht möglich.
4. Ohne `android/key.properties` bricht ein Release-Build jetzt absichtlich ab (Schutz vor falsch signierten APKs, die kein Update über bestehende Installationen erlauben).

### Für jedes neue Release

1. `pubspec.yaml` erhöhen: `version: x.y.z+buildNumber` (die Zahl hinter `+` muss steigen).
2. `flutter build apk --release` (oder `flutter build appbundle --release`) mit derselben Signatur erzeugen.
