import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MainPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final String? userRole;
  final String? userTeam; // NEU

  const MainPage({
    super.key,
    required this.toggleTheme,
    this.userRole,
    this.userTeam, // NEU
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Funktion zum Abrufen der Teammitglieder
  Future<void> _fetchTeamMembersAndShowDialog() async {
    // Überprüfe, ob der Benutzer in einem Team ist
    if (widget.userTeam == null || widget.userTeam!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Du bist keinem Team zugeordnet.')),
        );
      }
      return;
    }

    const String ipAddress = 'localhost';
    final url = Uri.parse('http://$ipAddress/get_team_members.php');

    try {
      final response = await http.post(
        url,
        body: {'teamName': widget.userTeam},
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        final List<String> members = List<String>.from(data['members']);
        if (mounted) {
          _showTeamDialog(data['teamName'], members);
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verbindungsfehler: $e')),
      );
    }
  }

  // Funktion zum Anzeigen des Dialogs
  void _showTeamDialog(String teamName, List<String> members) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Team: $teamName"),
          content: members.isNotEmpty
              ? SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      const Text("Mitglieder:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ...members.map((member) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Text("- $member"),
                          )),
                    ],
                  ),
                )
              : const Text("Dieses Team hat keine weiteren Mitglieder."),
          actions: <Widget>[
            TextButton(
              child: const Text("Schließen"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Überprüfe die Rolle des Benutzers
    final bool isAdmin = widget.userRole == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Airsoft App',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/app_bgr2.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              height: 120,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/app_bgr2.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Menü',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person,
                  color: Theme.of(context).textTheme.bodyMedium?.color),
              title: Text('Profil',
                  style: Theme.of(context).textTheme.bodyMedium),
              onTap: () {
                Navigator.of(context).pushNamed('/profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings,
                  color: Theme.of(context).textTheme.bodyMedium?.color),
              title: Text('Einstellungen',
                  style: Theme.of(context).textTheme.bodyMedium),
              onTap: () {
                Navigator.of(context).pushNamed('/settings');
              },
            ),
            if (isAdmin)
            ListTile(
              leading: Icon(Icons.admin_panel_settings,
                  color: Theme.of(context).textTheme.bodyMedium?.color),
              title: Text('Admin-Bereich',
                  style: Theme.of(context).textTheme.bodyMedium),
              onTap: () {
                // Hier kannst du zu einer Admin-spezifischen Seite navigieren
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout,
                  color: Theme.of(context).textTheme.bodyMedium?.color),
              title: Text('Ausloggen',
                  style: Theme.of(context).textTheme.bodyMedium),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 1,
              child: Image.asset(
                'assets/images/app_bgr.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                ElevatedButton(
                  onPressed: _fetchTeamMembersAndShowDialog, // Der neue Aufruf
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB((255 * 0.3).round(), 55, 99, 5),
                    minimumSize: const Size(100, 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(
                    Icons.group,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ]
            ),
          ),
        ],
      ),
    );
  }
}