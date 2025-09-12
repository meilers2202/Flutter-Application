import 'package:flutter/material.dart';

// Importiere alle Seiten-Dateien aus deinem 'pages'-Ordner
import 'package:flutter_application_1/pages/welcome_page.dart';
import 'package:flutter_application_1/pages/register_page.dart';
import 'package:flutter_application_1/pages/personaldata_page.dart';
import 'package:flutter_application_1/pages/main_page.dart';
import 'package:flutter_application_1/pages/profile_page.dart';
import 'package:flutter_application_1/pages/settings_page.dart';

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
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
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
              userTeam: _setTeam,
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