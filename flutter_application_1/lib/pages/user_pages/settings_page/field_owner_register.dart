import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Hinzugefügt
import 'dart:convert'; // Hinzugefügt
import 'package:pewpew_connect/service/constants.dart'; // Hinzugefügt (für ipAddress)


class RegisterFieldOwnerPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const RegisterFieldOwnerPage({
    super.key,
    required this.toggleTheme,
  });

  @override
  State<RegisterFieldOwnerPage> createState() => _RegisterFieldOwnerPageState();
}

class _RegisterFieldOwnerPageState extends State<RegisterFieldOwnerPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // 🔥 NEUE/ANGEPASSTE Methode: Löst die Registrierung direkt aus
  Future<void> _registerFieldOwner() async { // async hinzugefügt
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text;

    // 1. Grundlegende Validierung
    if (username.isEmpty || password.isEmpty || _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte fülle alle Felder aus.')),
      );
      return;
    }

    if (password != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwörter stimmen nicht überein.')),
      );
      return;
    }

    // 2. HTTP-Anfrage zur Registrierung senden
    final url = Uri.parse('$ipAddress/field_owner_register.php'); // URL angepasst

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
        
        // Bei Erfolg zum Login navigieren
        Navigator.of(context).pushReplacementNamed('/fieldownerlogin'); 
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registrierung fehlgeschlagen: ${data['message']}')),
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
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                      'Feld-Besitzer Registrierung',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      'Benutzerdaten', 
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(_usernameController, 'Benutzername', false),
                    const SizedBox(height: 10),
                    _buildTextField(_passwordController, 'Passwort', true),
                    const SizedBox(height: 10),
                    _buildTextField(_confirmPasswordController,
                        'Passwort bestätigen', true),
                    const SizedBox(height: 30),
                    
                    ElevatedButton(
                      onPressed: _registerFieldOwner,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 90, 111, 78),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                      ),
                      child: const Text(
                        'Registrieren',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop(); // Zurück zum vorherigen Screen (vermutlich Login-Auswahl)
                        },
                        child: Text(
                          "Zum Login",
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
        'Feld-Besitzer',
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