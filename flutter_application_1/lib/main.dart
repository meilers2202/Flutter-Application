import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Benutzerdaten als Instanzvariablen speichern
  String? _currentUsername;
  String? _setEmail;
  String? _setCity;
  String? _setTeam;
  String? _setMemberSince;
  ThemeMode _themeMode = ThemeMode.light;
  String? _setRole;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // Methode, um die Benutzerdaten zu aktualisieren
  void _setUserData({
    required String username,
    String? email,
    String? city,
    String? team,
    String? memberSince,
    String? role,
  }) {
    setState(() {
      _currentUsername = username;
      _setEmail = email;
      _setCity = city;
      _setTeam = team;
      _setMemberSince = memberSince;
      _setRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color.fromARGB(255, 226, 226, 226),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color.fromARGB(255, 158, 158, 158),
        ),
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          titleLarge: TextStyle(color: Colors.black),
          titleMedium: TextStyle(color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: WelcomePage(
        toggleTheme: _toggleTheme,
        setUserData: _setUserData,
      ),
      routes: {
        '/login': (context) => WelcomePage(
              toggleTheme: _toggleTheme,
              setUserData: _setUserData,
            ),
        '/register': (context) => RegisterPage(
              toggleTheme: _toggleTheme,
            ),
        '/personalData': (context) => const PersonalDataPage(
              username: '',
              password: '',
            ),
        '/main': (context) => MainPage(
              toggleTheme: _toggleTheme,
              userRole: _setRole,
              userTeam: _setTeam, // NEU: den Teamnamen übergeben
            ),
        // Daten als Argumente an die Profilseite übergeben
        '/profile': (context) => ProfilePage(
              username: _currentUsername,
              email: _setEmail,
              city: _setCity,
              team: _setTeam,
              memberSince: _setMemberSince,
            ),
        '/settings': (context) => SettingsPage(
              toggleTheme: _toggleTheme,
            ),
      },
    );
  }
}

// --------------------------------------------------------------------------
// WELCOME PAGE (LOGIN)
// --------------------------------------------------------------------------

class WelcomePage extends StatefulWidget {
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

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    const String ipAddress = 'localhost';
    final url = Uri.parse('http://$ipAddress/login.php');

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
        Navigator.of(context).pushNamed('/main');
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bitte melde dich an',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 15),
              _buildTextField(_usernameController, 'Benutzername', false),
              const SizedBox(height: 5),
              _buildTextField(_passwordController, 'Passwort', true),
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RegisterPage(toggleTheme: widget.toggleTheme),
                      ),
                    );
                  },
                  child: Text(
                    "Registrieren",
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

// --------------------------------------------------------------------------
// REGISTER PAGE - ERSTER SCHRITT
// --------------------------------------------------------------------------

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
                      '1. Benutzerdaten',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(_usernameController, 'Benutzername', false),
                    const SizedBox(height: 5),
                    _buildTextField(_passwordController, 'Passwort', true),
                    const SizedBox(height: 5),
                    _buildTextField(_confirmPasswordController,
                        'Passwort bestätigen', true),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _navigateToPersonalData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 90, 111, 78),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
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
                          Navigator.of(context).pushNamed('/login');
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

// --------------------------------------------------------------------------
// PERSONAL DATA PAGE - ZWEITER SCHRITT
// --------------------------------------------------------------------------

class PersonalDataPage extends StatefulWidget {
  final String username;
  final String password;

  const PersonalDataPage({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  _PersonalDataPageState createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends State<PersonalDataPage> {
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  
  // NEUE Variablen für das Dropdown-Menü
  List<dynamic> _teams = [];
  String? _selectedTeamName;

  @override
  void initState() {
    super.initState();
    _fetchTeams(); // Lade die Teams, wenn die Seite geladen wird
  }

  Future<void> _fetchTeams() async {
    const String ipAddress = 'localhost';
    final url = Uri.parse('http://$ipAddress/get_teams.php');

    try {
      final response = await http.get(url);
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        setState(() {
          _teams = data['teams'];
        });
      } else {
        // Hier kannst du eine Fehlermeldung anzeigen
        print("Fehler beim Laden der Teams: ${data['message']}");
      }
    } catch (e) {
      print("Verbindungsfehler beim Laden der Teams: $e");
    }
  }

  Future<void> _register() async {
    final String email = _emailController.text;
    final String city = _cityController.text;

    // Korrigierte Logik:
    if (email.isEmpty || city.isEmpty || _selectedTeamName == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bitte fülle alle Felder aus und wähle ein Team aus.')),
      );
      return;
    }

    // Korrigierte Zeile: Die ID als String abrufen und in einen Integer umwandeln
    final int selectedTeamId = int.parse(
      _teams.firstWhere((team) => team['name'] == _selectedTeamName)['id'],
    );
    
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
          'group_id': selectedTeamId.toString(), // Die Integer-ID als String senden
        },
      );

      if (!mounted) return;
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
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
                    // NEU: Dropdown-Menü für die Team-Auswahl
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Team',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      value: _selectedTeamName,
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
                      onPressed: _register,
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

// --------------------------------------------------------------------------
// WEITERE SEITEN
// --------------------------------------------------------------------------

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

class SettingsPage extends StatelessWidget {
  final VoidCallback toggleTheme;
  const SettingsPage({
    super.key,
    required this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Einstellungen',
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
      body: ListView(
        children: [
          ListTile(
            title: Text('Dunkler Modus',
                style: Theme.of(context).textTheme.bodyMedium),
            leading: Icon(Icons.dark_mode,
                color: Theme.of(context).textTheme.bodyMedium?.color),
            trailing: Switch(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (bool value) {
                toggleTheme();
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text('Benachrichtigungen',
                style: Theme.of(context).textTheme.bodyMedium),
            leading: Icon(Icons.notifications,
                color: Theme.of(context).textTheme.bodyMedium?.color),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Benachrichtigungseinstellungen geöffnet'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  // Variablen als finale Felder definieren
  final String? username;
  final String? email;
  final String? city;
  final String? team;
  final String? memberSince;

  const ProfilePage({
    super.key,
    this.username,
    this.email,
    this.city,
    this.team,
    this.memberSince,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
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
      body: Stack(
        children: [
          // Hintergrundbild mit Deckkraft
          Positioned.fill(
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/images/app_bgr.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Der ursprüngliche Profil-Inhalt
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // CircleAvatar mit Bild und Opacity
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipOval(
                        child: Opacity(
                          opacity: 0.5,
                          child: Image.asset(
                            'assets/images/app_bgr2.jpg',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    username ?? 'Gast',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mitglied seit: ${memberSince ?? 'Unbekannt'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.groups),
                            title: Text('Team',
                                style: Theme.of(context).textTheme.bodyLarge),
                            subtitle: Text(team ?? 'Nicht verfügbar',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.email),
                            title: Text('E-Mail',
                                style: Theme.of(context).textTheme.bodyLarge),
                            subtitle: Text(email ?? 'Nicht verfügbar',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text('Standort',
                                style: Theme.of(context).textTheme.bodyLarge),
                            subtitle: Text(city ?? 'Nicht verfügbar',
                                style: Theme.of(context).textTheme.bodyMedium),
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