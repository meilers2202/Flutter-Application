// ignore_for_file: use_build_context_synchronously

import 'package:pewpew_connect/service/imports.dart';

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
  State<MainPage> createState() => MainPageState();
}

// Global RouteObserver für die App (in main.dart initialisieren)
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MainPageState extends State<MainPage> with RouteAware {
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
    _initPackageInfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }

    // Direkt beim ersten Aufbau laden
    _refreshProfileData();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Wird aufgerufen, wenn die Route wieder angezeigt wird (z.B. nach Teamwechsel)
  @override
  void didPopNext() {
    _refreshProfileData();
  }

  Future<void> _refreshProfileData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    await fetchProfileData();
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

  Future<void> fetchProfileData() async {
    if (widget.currentUsername == null) return;

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
      });

      // ✅ Debug-Ausgabe
      print('--------------MainPage DEBUG--------------');
      print('Benutzername: ${userData['username']}');
      print('E-Mail: ${userData['email']}');
      print('Stadt: ${userData['city']}');
      print('Team: ${userData['team']}');
      print('Mitglied seit: ${userData['memberSince']}');
      print('Teamrolle: ${userData['teamrole']}');
      print('Rolle: ${userData['role']}');
      print('------------------------------------------');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: ${result['message']}')),
      );
    }
  }

  Future<void> _fetchTeamMembersAndNavigate() async {
    await(fetchProfileData());
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
      ),
      drawer: Drawer(
        width: 200,
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
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.close, color: Color.fromARGB(255, 255, 255, 255), size: 24),
                        onPressed: () {
                          Scaffold.of(context).closeDrawer();
                        },
                      ),
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
                leading: Icon(Icons.image,
                    color: Theme.of(context).textTheme.bodyMedium?.color),
                title: Text('ImageLoader',
                    style: Theme.of(context).textTheme.bodyMedium),
                onTap: () {
                  Navigator.pushNamed(context, '/image-upload');
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
                style: Theme.of(context).textTheme.bodyMedium,
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
                  onPressed: () async {
                    final newTeamName = await Navigator.of(context).push<String>(
                      MaterialPageRoute(
                        builder: (_) => CreateTeamPage(userService: _userService),
                      ),
                    );

                    if (newTeamName != null && newTeamName.isNotEmpty) {
                      setState(() {
                        _userTeam = newTeamName; // Optional: Team sofort in MainPage aktualisieren
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB((255 * 0.3).round(), 55, 99, 5),
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
                    Navigator.of(context).pushNamed(
                      '/allTeams',
                      arguments: {
                        'currentUsername': widget.currentUsername,
                        'userTeam': _userTeam,
                      },
                    );
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
