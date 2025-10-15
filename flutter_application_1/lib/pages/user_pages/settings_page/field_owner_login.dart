import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pewpew_connect/service/constants.dart';

class FieldOwnerLogin extends StatefulWidget {
  final VoidCallback toggleTheme;
  // Callback-Funktion, um Daten an die übergeordnete Klasse zu senden
  final Function({
    required String username,
    String? email,
    String? city,
    String? team,
    String? memberSince,
    String? role,
  }) setUserData;

  const FieldOwnerLogin({
    super.key,
    required this.toggleTheme,
    required this.setUserData,
  });

  @override
  State<FieldOwnerLogin> createState() => _FieldOwnerLoginState();
}

class _FieldOwnerLoginState extends State<FieldOwnerLogin> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showDeveloperButton = false;

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    // Ändere den Endpunkt auf die neue PHP-Datei
    final url = Uri.parse('$ipAddress/field_owner_login.php');

    try {
      final response = await http.post(
        url,
        body: {
          'username': username,
          'password': password,
        },
      );

      if (!mounted) return;

      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        // Die erhaltenen Daten an die MyApp-Klasse übergeben
        widget.setUserData(
          username: username,
          email: data['email'],
          city: data['city'],
          team: data['team'],
          memberSince: data['memberSince'],
          role: data['role'],
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
        Navigator.of(context).pushNamed('/fieldownermain');
        setState(() {
          _showDeveloperButton = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
        setState(() {
          _showDeveloperButton = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verbindungsfehler: $e')),
      );
      setState(() {
        _showDeveloperButton = true;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/app_bgr.jpg',
                  fit: BoxFit.cover,
                ),
                Container(
                  color: Colors.black.withOpacity(0.4),
                ),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bitte melde dich als Field Owner an',
                    textAlign: TextAlign.center, // Diese Zeile zentriert den Text
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(context, _usernameController, 'Benutzername', false),
                  const SizedBox(height: 5),
                  _buildTextField(context, _passwordController, 'Passwort', true),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 90, 111, 78),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    child: const Text(
                      'Anmelden',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  if (_showDeveloperButton)
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Hier navigierst du am Login vorbei
                            Navigator.of(context).pushNamed('/main');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                          ),
                          child: const Text(
                            'Entwicklermodus (Login überspringen)',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/fieldownerregister',
                        );
                      },
                      child: Text(
                        "Registrieren",
                        style: TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]
      ),
    );
  }

  static AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Field-Owner',
        style: TextStyle(
          color: Colors.white,
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
    BuildContext context, // 👈 context als Parameter hinzufügen
    TextEditingController controller,
    String labelText,
    bool obscureText,
  ) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        filled: true,
        labelStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
        ),
      ),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
    );
  }
}