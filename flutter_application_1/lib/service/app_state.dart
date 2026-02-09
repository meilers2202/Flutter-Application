import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  final SharedPreferences prefs;
  
  ThemeMode _themeMode;
  String? _username;
  String? _team;
  String? _role;
  String? _teamrole;
  bool _forcePasswordChange = false;

  AppState(this.prefs) : 
    _themeMode = (prefs.getBool('isDarkMode') ?? false) ? ThemeMode.dark : ThemeMode.light {
    
    // Logik beim Kaltstart der App:
    final bool stayLoggedIn = prefs.getBool('stayLoggedIn') ?? false;

    if (stayLoggedIn) {
      _username = prefs.getString('username');
      _team = prefs.getString('team');
      _role = prefs.getString('role');
      _teamrole = prefs.getString('teamrole');
      _forcePasswordChange = prefs.getBool('forcePasswordChange') ?? false;
    } else {
      // Wenn der Haken nicht gesetzt war (oder explizit auf false steht), 
      // starten wir immer als Gast ohne Daten.
      _username = null;
      _team = null;
      _role = null;
    }
  }

  // Getter
  ThemeMode get themeMode => _themeMode;
  String get username => _username ?? 'Gast';
  String? get team => _team;
  String? get role => _role;
  String? get teamrole => _teamrole;
  bool get forcePasswordChange => _forcePasswordChange;

  // Der entscheidende Check für die main.dart
  bool get isAutoLoggedIn {
    if (_username == null || _username == 'Gast' || _username!.isEmpty) {
      return false;
    }
    // Sicherheitshalber muss auch das Flag im Speicher auf true stehen
    return prefs.getBool('stayLoggedIn') ?? false;
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    notifyListeners();
  }

  void setUserData({
    required String username,
    required bool stayLoggedIn,
    String? email,
    String? city,
    String? team,
    String? memberSince,
    String? role,
    String? teamrole,
    bool forcePasswordChange = false,
  }) {
    _username = username;
    _team = team;
    _role = role;
    _teamrole = teamrole;
    _forcePasswordChange = forcePasswordChange;

    // Speicher-Entscheidung:
    prefs.setBool('stayLoggedIn', stayLoggedIn);
    
    // Die Daten werden gespeichert. Ob sie beim nächsten Start 
    // genutzt werden, entscheidet der Konstruktor oben!
    prefs.setString('username', username);
    if (team != null) prefs.setString('team', team);
    if (role != null) prefs.setString('role', role);
  if (teamrole != null) prefs.setString('teamrole', teamrole);
    prefs.setBool('forcePasswordChange', forcePasswordChange);

    notifyListeners();
  }

  void setForcePasswordChange(bool value) async {
    _forcePasswordChange = value;
    await prefs.setBool('forcePasswordChange', value);
    notifyListeners();
  }

  void logout() async {
    _username = null;
    _team = null;
    _role = null;
    
    // Tabula Rasa im Speicher
    await prefs.remove('username');
    await prefs.remove('team');
    await prefs.remove('role');
    await prefs.setBool('stayLoggedIn', false); // Flag explizit auf false
    await prefs.remove('stayLoggedIn2');
    await prefs.remove('fieldOwnerUsername');
    
    notifyListeners();
  }
}