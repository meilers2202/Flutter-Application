import 'dart:async'; // Für den Timer, den wir nun entfernen, aber vorsichtshalber behalten
import 'package:http/http.dart' as http;
import 'package:pewpew_connect/service/imports.dart';
// import 'package:pewpew_connect/pages/user_pages/main_page/main_page.dart'; // Wird hier nicht benötigt

// *******************************************************
// WICHTIG: Stellen Sie sicher, dass dies in Ihrer counter_data.dart definiert ist
// int addincrement = 0;
// void incrementCounter() { addincrement++; }
// *******************************************************
// import 'package:pewpew_connect/pfad/zu/counter_data.dart'; // Fügen Sie den korrekten Import hier hinzu

class ProfilePage extends StatefulWidget {
  final String? username;

  const ProfilePage({super.key, required this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? email;
  String? city;
  String? team;
  String? memberSince;
  String? teamrole;
  String? ingamerole;
  String? profileImageUrl; 
  bool _isLoading = true;

    // ✨ NEU/KORRIGIERT: Wird verwendet, um den Cache Buster nach dem Pop manuell zu setzen.
    // Wir initialisieren ihn mit der aktuellen 5-Sekunden-Ganzzahl.
    int _cacheBusterKey = (DateTime.now().millisecondsSinceEpoch ~/ 5000); 

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    // buttonPressed(); // Aufruf entfernt, da er im initState in diesem Kontext meist nicht gewollt ist.
  }

  // Beibehaltene Funktion (Achtung: Prüfen Sie den Import von incrementCounter!)
  void buttonPressed() {
    // incrementCounter(); // Hier auskommentiert, da die Funktion nicht in diesem Code-Block ist
    // print('Zugriff von außen: $addincrement'); // Hier auskommentiert, da die Variable nicht in diesem Code-Block ist
  }

  Future<void> _fetchProfileData() async {
    // Stellen Sie sicher, dass ein Benutzername vorhanden ist, um Abfragen zu vermeiden
    if (widget.username == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    // Gehe davon aus, dass ipAddress im imports.dart oder einem globalen Scope ist.
    final url = Uri.parse('$ipAddress/get_profile.php'); 
    try {
      final response = await http.post(
        url,
        body: {'username': widget.username},
      );

      final data = json.decode(response.body);

      if (data['success']) {
        setState(() {
          email = data['user']['email'];
          city = data['user']['city'];
          team = data['user']['team'];
          memberSince = data['user']['memberSince'];
          teamrole = data['user']['teamrole'];
          ingamerole = data['user']['ingamerole'];
          profileImageUrl = data['user']['profile_image_url'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: ${data['message']}')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Laden der Daten: $e')),
      );
    }
  }

  // Funktion zur Navigation und zum Neuladen des Profils
  void _navigateToImageUpload() async {
    if (widget.username == null) return; 

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageUploadPage(username: widget.username!), 
      ),
    );
    
    // Wenn die Seite 'true' zurückgibt (also erfolgreich hochgeladen wurde)
    if (result == true) {
        // ✨ KRITISCH: Setze den Cache Buster Key manuell NEU, 
        // um die Aktualisierung sofort zu erzwingen.
        setState(() {
            _cacheBusterKey = (DateTime.now().millisecondsSinceEpoch ~/ 5000);
        });
        // Lade die neuen Daten vom Server (inkl. neuer Bild-URL)
        _fetchProfileData(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider background;
    
    // Hole den 5-Sekunden-Wert für den Cache Buster (entweder den neuen manuell 
    // gesetzten Wert, oder den Wert, der sich alle 5 Sekunden ändert)
    final int fiveSecondIntervals = _cacheBusterKey; // Wir verwenden den State-Wert

    if (profileImageUrl != null) {
        // Die URL-Zusammensetzung verwendet den 5-Sekunden-Key
        final String fullImageUrl = profileImageUrl!;
        final String cacheBusterUrl = '$fullImageUrl?v=$fiveSecondIntervals';
        
        background = NetworkImage(cacheBusterUrl);
    } else {
        // Fallback Asset-Bild
        background = const AssetImage('assets/images/app_bgr2.jpg');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 28, fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/app_bgr2.jpg'), fit: BoxFit.cover),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.8,
              child: Image.asset('assets/images/app_bgr.jpg', fit: BoxFit.cover),
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Das tatsächliche Profilbild (Network- oder Asset-Bild)
                            CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey.shade800,
                                // Das Bild wird über backgroundImage geladen
                                backgroundImage: background,
                                // Zeige das große Person-Icon nur, wenn KEIN Bild vom Server geladen wird
                                child: profileImageUrl == null && widget.username != null
                                    ? const Icon(
                                        Icons.person,
                                        size: 80,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            // Das anklickbare Bearbeiten-Icon
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: _navigateToImageUpload,
                                borderRadius: BorderRadius.circular(18),
                                child: const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Color.fromARGB(255, 41, 107, 43),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Cache Buster Key: $fiveSecondIntervals'
                        ),
                        Text(
                          widget.username ?? 'Gast',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Mitglied seit: ${memberSince ?? 'Unbekannt'}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 24),
                        Card(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.groups),
                                  title: Text('Team', style: Theme.of(context).textTheme.bodyLarge),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Team: ${team ?? 'Kein Team'}',
                                        style: Theme.of(context).textTheme.bodyMedium
                                      ),
                                      Text(
                                        'Position: ${teamrole ?? 'Nicht zugewiesen'}',
                                        style: Theme.of(context).textTheme.bodyMedium
                                      ),
                                      Text(
                                        'Rang: ${ingamerole ?? 'Nicht zugewiesen'}',
                                        style: Theme.of(context).textTheme.bodyMedium
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.email),
                                  title: Text('E-Mail', style: Theme.of(context).textTheme.bodyLarge),
                                  subtitle: Text(email ?? 'Nicht verfügbar', style: Theme.of(context).textTheme.bodyMedium),
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.location_on),
                                  title: Text('Standort', style: Theme.of(context).textTheme.bodyLarge),
                                  subtitle: Text(city ?? 'Nicht verfügbar', style: Theme.of(context).textTheme.bodyMedium),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}