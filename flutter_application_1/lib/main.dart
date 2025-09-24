import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/login/login_page.dart'; // Hinzugefügt
import 'package:flutter_application_1/pages/login/register_page.dart';
import 'package:flutter_application_1/pages/login/register_personaldata_page.dart';
import 'package:flutter_application_1/pages/user_pages/main_page/main_page.dart';
import 'package:flutter_application_1/pages/user_pages/main_page/all_teams_page/all_teams_page.dart';
import 'package:flutter_application_1/pages/user_pages/main_page/all_teams_page/join_team_page/join_team_page.dart';
import 'package:flutter_application_1/pages/user_pages/settings_page/profile_page.dart';
import 'package:flutter_application_1/pages/user_pages/settings_page/settings_page.dart';
import 'package:flutter_application_1/pages/user_pages/settings_page/admin_page.dart';
import 'package:flutter_application_1/pages/user_pages/settings_page/admin_pages/user_management_page.dart';
import 'package:flutter_application_1/pages/user_pages/settings_page/admin_pages/block_list_page.dart';
import 'package:flutter_application_1/pages/user_pages/settings_page/admin_pages/field_owner_list.dart';
import 'package:flutter_application_1/pages/user_pages/settings_page/admin_pages/teams_management_page.dart';
import 'package:flutter_application_1/pages/user_pages/settings_page/field_owner_login.dart';
import 'package:flutter_application_1/pages/user_pages/settings_page/field_owner_pages/field_owner_main.dart';
import 'package:flutter_application_1/pages/user_pages/settings_page/field_owner_pages/create_field.dart';

void main() => runApp(const MyApp());

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
        '/allTeams': (context) => const AllTeams(),
        '/fieldownerlogin': (context) => FieldOwnerLogin(
          toggleTheme: _toggleTheme,
          setUserData: _setUserData,
        ),
        '/fieldownermain': (context) => const FieldOwnerMainPage(),
        '/fieldcreate': (context) => CreateField(currentUsername: _currentUsername!)
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/joinTeam') {
          final teamName = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) {
              return JoinTeam(
                teamName: teamName,
                currentUsername: _currentUsername!, 
              );
            },
          );
        }
        return null;
      },
    );
  }
}