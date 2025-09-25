import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PersonalDataPage extends StatefulWidget {
  final String username;
  final String password;

  const PersonalDataPage({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  PersonalDataPageState createState() => PersonalDataPageState();
}

class PersonalDataPageState extends State<PersonalDataPage> {
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  
  List<dynamic> _teams = [];
  String? _selectedTeamName;

  @override
  void initState() {
    super.initState();
    _fetchTeams();
  }

  Future<void> _fetchTeams() async {
    const String ipAddress = 'localhost';
    // Ändere die URL von 'get_teams.php' zu 'get_teams.php?detailed=false'
    final url = Uri.parse('http://$ipAddress/get_teams.php?detailed=false');

    try {
      final response = await http.get(url);
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        setState(() {
          _teams = data['teams'];
        });
      } else {
        debugPrint("Fehler beim Laden der Teams: ${data['message']}");
      }
    } catch (e) {
      debugPrint("Verbindungsfehler beim Laden der Teams: $e");
    }
  }
  
  // NEU: Funktion, die zur Policy navigiert und dann registriert
  void _checkPolicyAndRegister() async {
    final String email = _emailController.text;
    final String city = _cityController.text;

    // 1. Grundlegende Validierung
    if (email.isEmpty || city.isEmpty || _selectedTeamName == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bitte fülle alle Felder aus und wähle ein Team aus.')),
      );
      return;
    }
    
    // 2. Zur Policy-Seite navigieren und auf das Ergebnis warten
    // Das Ergebnis ist entweder true (Akzeptiert) oder false (Abgelehnt)
    final bool? policyAccepted = await Navigator.of(context).pushNamed(
        '/registerpolicy') as bool?;

    // 3. Registrierung nur durchführen, wenn die Policy akzeptiert wurde
    if (policyAccepted == true) {
      await _register();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Registrierung abgebrochen: Die Bedingungen wurden nicht akzeptiert.')),
      );
    }
  }


  // Die eigentliche Registrierungslogik (Wurde von _register in _doRegistration umbenannt, um Verwirrung zu vermeiden, wird aber von _checkPolicyAndRegister aufgerufen)
  Future<void> _register() async {
    final String email = _emailController.text;
    final String city = _cityController.text;

    // Findet das Team-Objekt und gibt ein leeres Map zurück, wenn es nicht gefunden wird.
    final teamData = _teams.firstWhere(
      (team) => team['name'] == _selectedTeamName,
      orElse: () => {},
    );

    // Überprüfen, ob das 'id'-Feld vorhanden und nicht null ist.
    final dynamic teamId = teamData['id'];
    if (teamId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Fehler: Die ID des ausgewählten Teams konnte nicht abgerufen werden.')),
      );
      return;
    }
    
    // Konvertiere teamId sicher in eine Zeichenkette und dann in eine Ganzzahl.
    final int selectedTeamId = int.parse(teamId.toString());

    const String ipAddress = 'localhost';
    final url = Uri.parse('http://$ipAddress/register.php');

    try {
      final response = await http.post(
        url,
        body: {
          'username': widget.username,
          'password': widget.password,
          'email': email,
          'city': city,
          'group_id': selectedTeamId.toString(),
        },
      );

      if (!mounted) return;
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
        
        // WICHTIG: NACH ERFOLGREICHER REGISTRIERUNG ZUM LOGIN-SCREEN NAVIGIEREN
        // Alle vorherigen Routen werden entfernt.
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/login', (Route<dynamic> route) => false);
            
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

  @override
  void dispose() {
    _emailController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Bitte registriere dich',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '2. Personenbezogene Daten',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(_emailController, 'E-Mail', false),
                    const SizedBox(height: 5),
                    _buildTextField(_cityController, 'Stadt', false),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Team',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      initialValue: _selectedTeamName,
                      items: _teams.map<DropdownMenuItem<String>>((team) {
                        return DropdownMenuItem<String>(
                          value: team['name'],
                          child: Text(team['name']),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedTeamName = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Bitte wähle ein Team aus.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _checkPolicyAndRegister, // **WICHTIG: Funktion geändert**
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 90, 111, 78),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                      ),
                      child: const Text(
                        'Registrieren',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: InkWell(
                        onTap: () {
                          // KORREKTUR: Einfach die aktuelle Seite aus dem Stack entfernen.
                          // Dies navigiert zur Seite, die VOR der PersonalDataPage lag (z.B. RegisterPage).
                          Navigator.of(context).pop(); 
                        },
                        child: Text(
                          "Zurück",
                          style: TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static AppBar _buildAppBar(BuildContext context) {
    return AppBar(
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
    );
  }

  static Widget _buildTextField(
      TextEditingController controller, String labelText, bool obscureText) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: Colors.grey),
      ),
      style: const TextStyle(color: Colors.black),
    );
  }
}