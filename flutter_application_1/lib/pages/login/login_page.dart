import 'package:http/io_client.dart';
import 'package:pewpew_connect/service/imports.dart';

IOClient getInsecureClient() {
  if (kIsWeb) {
    return IOClient(HttpClient());
  } else {
    final ioc = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    return IOClient(ioc);
  }
}

class WelcomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final Function({
    required String username,
    required bool stayLoggedIn, // Diesen Parameter hinzufügen!
    String? email,
    String? city,
    String? team,
    String? memberSince,
    String? role,
  }) setUserData;

  const WelcomePage({
    super.key,
    required this.toggleTheme,
    required this.setUserData,
  });

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showDeveloperButton = false;
  bool _stayLoggedIn = false;
  bool _isLoading = false;

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
      final client = getInsecureClient();

      final response = await client.post(
        Uri.parse('$ipAddress/login.php'),
        body: {'username': username, 'password': password},
      );

      if (!mounted) return;

      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        // NUR NOCH den AppState rufen, der kümmert sich um alles (Prefs + State)
        widget.setUserData(
          username: username,
          stayLoggedIn: _stayLoggedIn,
          email: data['email'],
          city: data['city'],
          team: data['team'],
          memberSince: data['memberSince'],
          role: data['role'],
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Erfolgreich angemeldet')),
        );

        // Wir nutzen pushNamedAndRemoveUntil, um den Stack zu leeren
        Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login fehlgeschlagen')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verbindungsfehler: $e')),
      );
      setState(() {
        _showDeveloperButton = true;
      });
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
        title: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
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
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                      value: _stayLoggedIn,
                      onChanged: (bool? value) {
                        setState(() => _stayLoggedIn = value ?? false);
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
                    onPressed: () {
                      Navigator.of(context).pushNamed('/register');
                    },
                    child: const Text(
                      "Noch kein Konto? Jetzt registrieren",
                      style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
                    ),
                  ),
                  if (_showDeveloperButton)
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Im Entwicklermodus setzen wir Gast-Daten ohne stayLoggedIn
                            widget.setUserData(username: 'Entwickler', stayLoggedIn: false);
                            Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                          child: const Text(
                            'Entwicklermodus (Login überspringen)',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
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
        fillColor: Colors.white.withOpacity(0.1),
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