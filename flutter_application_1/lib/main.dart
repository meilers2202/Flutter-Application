
import 'service/imports.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    // Ignoriere Zertifikatfehler (nur für Entwicklung / NICHT in Produktion)
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  }
}

void main() {
  // Setze die Override nur, wenn wir NICHT im Web laufen.
  // (Browser erlauben kein programmatisches Ignorieren von Zertifikatsfehlern.)
  if (!kIsWeb) {
    HttpOverrides.global = MyHttpOverrides();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  String? _currentUsername;
  String? _setTeam;
  String? _setRole;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _setUserData({
    required String username,
    String? email,
    String? city,
    String? team,
    String? memberSince,
    String? role,
    String? teamrole,
  }) {
    setState(() {
      _currentUsername = username;
      _setTeam = team;
      _setRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
      initialRoute: '/login',
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
              currentUsername: _currentUsername,
              onTeamChange: _setUserData,
            ),
        '/profile': (context) => ProfilePage(username: _currentUsername),
        '/settings': (context) => SettingsPage(
              toggleTheme: _toggleTheme,
            ),
        '/admin': (context) => const AdminPage(),
        '/admin/users': (context) => const UserManagementPage(),
        '/admin/fieldowners': (context) => const FieldOwnerList(),
        '/admin/blocklist': (context) => const BlocklistPage(),
        '/admin/teams': (context) => const TeamsManagementPage(),
        '/admin/fields': (context) => const FieldList(),
        '/allTeams': (context) => const AllTeams(),
        '/fieldownerlogin': (context) => FieldOwnerLogin(
              toggleTheme: _toggleTheme,
              setUserData: _setUserData,
            ),
        '/fieldownerregister': (context) => RegisterFieldOwnerPage(
              toggleTheme: _toggleTheme,
            ),
        '/fieldownermain': (context) => FieldOwnerMainPage(
              currentUsername: _currentUsername ?? '',
            ),
        '/fieldcreate': (context) => CreateField(
              currentUsername: _currentUsername ?? '',
            ),
        '/fielddetails': (context) {
          // Übergabe eines Field-Objekts via Navigator.arguments erwartet
          final field = ModalRoute.of(context)!.settings.arguments as Field;
          return FieldDetailsPage(field: field);
        },
        '/editfield': (context) {
          final fieldToEdit = ModalRoute.of(context)!.settings.arguments as Field;
          return EditFieldPage(field: fieldToEdit);
        },
        '/registerpolicy': (context) => const RegisterPolicy(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/joinTeam') {
          final teamName = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) {
              return JoinTeam(
                teamName: teamName,
                currentUsername: _currentUsername ?? '',
              );
            },
          );
        }
        return null;
      },
    );
  }
}
