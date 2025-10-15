import 'package:flutter/material.dart';
import 'package:pewpew_connect/pages/login/register_personaldata_page.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const RegisterPage({
    super.key,
    required this.toggleTheme,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _navigateToPersonalData() {
    // Grundlegende Validierung für den ersten Screen
    if (_usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte fülle alle Felder aus.')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwörter stimmen nicht überein.')),
      );
      return;
    }

    // Navigiere zum zweiten Screen und übergebe die Daten
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PersonalDataPage(
          username: _usernameController.text,
          password: _passwordController.text,
        ),
      ),
    );
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
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Bitte registriere dich',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                          ),
                        ),
                        Text(
                          '1. Benutzerdaten',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(context, _usernameController, 'Benutzername', false),
                        const SizedBox(height: 5),
                        _buildTextField(context, _passwordController, 'Passwort', true),
                        const SizedBox(height: 5),
                        _buildTextField(context, _confirmPasswordController, 'Passwort bestätigen', true),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _navigateToPersonalData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 90, 111, 78),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                          child: const Text(
                            'Weiter',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pushReplacementNamed('/login');
                            },
                            child: Text(
                              "Zum Login",
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
              );
            },
          ),
        ],
      ),
    );
  }

  static AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Airsoft App',
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