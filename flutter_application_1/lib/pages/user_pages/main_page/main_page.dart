// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pewpew_connect/service/user_service.dart';
import 'package:pewpew_connect/pages/user_pages/main_page/team_details_page.dart';
import 'package:package_info_plus/package_info_plus.dart'; 

class MainPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final String? userRole;
  final String? userTeam;
  final String? currentUsername;

  final Function({
    required String username,
    String? email,
    String? city,
    String? team,
    String? memberSince,
    String? role,
  }) onTeamChange;

  const MainPage({
    super.key,
    required this.toggleTheme,
    this.userRole,
    this.userTeam,
    required this.currentUsername,
    required this.onTeamChange,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final UserService _userService = UserService();
  String? _userEmail;
  String? _userCity;
  String? _userMemberSince;
  String? _userRole;
  String? _userTeam;
  String _version = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAllData();
  }

    Future<void> _initAllData() async {
    // Rufe beide asynchronen Funktionen gleichzeitig auf
    await Future.wait([
      _fetchProfileData(),
      _initPackageInfo(),
    ]);

    // Stelle sicher, dass das Widget noch existiert, bevor setState aufgerufen wird
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    _version = info.version;
  }

  Future<void> _fetchProfileData() async {
    if (widget.currentUsername == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Benutzername nicht verfügbar.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final result = await _userService.fetchProfileData(widget.currentUsername!);

    if (!mounted) return;

    if (result['success'] == true) {
      final userData = result['user'];
      setState(() {
        _userEmail = userData['email'];
        _userCity = userData['city'];
        _userTeam = userData['team'];
        _userMemberSince = userData['memberSince'];
        _userRole = userData['role'];
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: ${result['message']}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createTeam() async {
    final TextEditingController teamNameController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Neues Team erstellen'),
          content: TextField(
            controller: teamNameController,
            decoration: const InputDecoration(hintText: "Teamname eingeben"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Erstellen'),
              onPressed: () async {
                final newTeamName = teamNameController.text.trim();
                if (newTeamName.isNotEmpty) {
                  final result = await _userService.createTeam(newTeamName);

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message'])),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchTeamMembersAndNavigate() async {
    await(_fetchProfileData());
    if (_userTeam == null || _userTeam!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Du bist keinem Team zugeordnet.')),
        );
      }
      return;
    }

    final teamData = await _userService.fetchTeamMembers(_userTeam!);

    if (!mounted) return;

    if (teamData['success'] == true) {
      final List<String> members = List<String>.from(teamData['members']);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TeamDetailsPage(
            teamName: teamData['teamName'],
            members: members,
            currentUsername: widget.currentUsername!,
            onTeamChange: widget.onTeamChange,
            userEmail: _userEmail,
            userCity: _userCity,
            userMemberSince: _userMemberSince,
            userRole: _userRole,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(teamData['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final bool isAdmin = _userRole == "admin";
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
              height: 69,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/app_bgr2.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Menü',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 24),
                      padding: EdgeInsets.zero, // 👈 entfernt Standard-Padding
                      constraints: const BoxConstraints(), // 👈 entfernt Mindestgröße
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
              leading: Icon(Icons.area_chart_outlined,
                  color: Theme.of(context).textTheme.bodyMedium?.color),
              title: Text('Field-Owner',
                  style: Theme.of(context).textTheme.bodyMedium),
              onTap: () {
                Navigator.of(context).pushNamed('/fieldownerlogin');
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
            const Divider(),
            if (isAdmin)
              ListTile(
                leading: Icon(Icons.admin_panel_settings,
                    color: Theme.of(context).textTheme.bodyMedium?.color),
                title: Text('Admin-Bereich',
                    style: Theme.of(context).textTheme.bodyMedium),
                onTap: () {
                  Navigator.of(context).pushNamed('/admin');
                },
              ),
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
            const Spacer(),
            ListTile(
              leading: Icon(
                Icons.build_circle_outlined,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              title: Text(
                'Version (v$_version)',
                style: Theme.of(context).textTheme.bodyMedium, // Das "style"-Argument ist jetzt korrekt hier
              ),
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
                  onPressed: _fetchTeamMembersAndNavigate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color.fromARGB((255 * 0.3).round(), 55, 99, 5),
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
                ElevatedButton(
                  onPressed: _createTeam,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color.fromARGB((255 * 0.3).round(), 55, 99, 5),
                    minimumSize: const Size(100, 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(
                    Icons.group_add,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/allTeams');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color.fromARGB((255 * 0.3).round(), 55, 99, 5),
                    minimumSize: const Size(100, 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(
                    Icons.list,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/fieldslist');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color.fromARGB((255 * 0.3).round(), 55, 99, 5),
                    minimumSize: const Size(100, 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(
                    Icons.area_chart_outlined,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}