import 'package:http/http.dart' as http;
import 'package:pewpew_connect/service/imports.dart';

class FieldOwnerLogin extends StatefulWidget {
  final VoidCallback toggleTheme;
  final Function({
    required String username,
    required bool stayLoggedIn,
    String? email,
    String? city,
    String? team,
    String? memberSince,
    String? role,
    String? teamrole,
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
  bool _stayLoggedIn2 = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final bool stayLoggedIn2 = prefs.getBool('stayLoggedIn2') ?? false;
    final String? savedUsername = prefs.getString('fieldOwnerUsername');

    if (stayLoggedIn2 && savedUsername != null && savedUsername.isNotEmpty) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/fieldownermain');
      }
    }
  }

  Future<void> _login() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte fülle alle Felder aus.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('$ipAddress/field_owner_login.php');
      final response = await http.post(
        url,
        body: {'username': username, 'password': password},
      ).timeout(const Duration(seconds: 10));

      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        if (_stayLoggedIn2) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('stayLoggedIn2', true);
          await prefs.setString('fieldOwnerUsername', username);
        }

        if (!mounted) return;

        widget.setUserData(
          username: username,
          stayLoggedIn: _stayLoggedIn2,
          email: data['email'],
          city: data['city'],
          team: data['team'],
          memberSince: data['memberSince'],
          role: data['role'],
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Erfolgreich angemeldet')),
        );

        Navigator.of(context).pushReplacementNamed('/fieldownermain');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login fehlgeschlagen')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verbindungsfehler: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      appBar: AppBar(
        title: const Text('Field-Owner Login', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/app_bgr.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(color: Colors.black.withValues(alpha: 0.5)),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_outlined, size: 80, color: Colors.white),
                  const SizedBox(height: 20),
                  const Text(
                    'Willkommen zurück',
                    style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(_usernameController, 'Benutzername', false, Icons.person),
                  const SizedBox(height: 16),
                  _buildTextField(_passwordController, 'Passwort', true, Icons.lock),
                  const SizedBox(height: 10),
                  Theme(
                    data: ThemeData(unselectedWidgetColor: Colors.white),
                    child: CheckboxListTile(
                      title: const Text("Angemeldet bleiben", style: TextStyle(color: Colors.white)),
                      value: _stayLoggedIn2,
                      onChanged: (bool? value) {
                        setState(() => _stayLoggedIn2 = value ?? false);
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Colors.green,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _isLoading 
                    ? const CircularProgressIndicator(color: Colors.green)
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 90, 111, 78),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Anmelden', style: TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/fieldownerregister'),
                    child: const Text(
                      "Noch kein Konto? Jetzt registrieren",
                      style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
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

  Widget _buildTextField(TextEditingController controller, String label, bool obscure, IconData icon) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        fillColor: Colors.white.withValues(alpha: 0.1),
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green),
        ),
      ),
    );
  }
}