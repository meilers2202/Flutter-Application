import 'package:pewpew_connect/service/imports.dart';
import 'package:pewpew_connect/service/remote_config_service.dart';

int addincrement = 0;

void incrementCounter() {
  addincrement++;
  // print ist okay für Debugging, die Warnung ignorieren wir erst mal
  debugPrint('Der neue Wert ist: $addincrement');
}

class MainPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final String? userRole;
  final String? userTeam;
  final String? teamrole;
  final String? currentUsername;

  // Updated to match AppState.setUserData signature
  final void Function({
    required String username,
    required bool stayLoggedIn,
    String? email,
    String? city,
    String? team,
    String? memberSince,
    String? role,
    String? teamrole,
  }) onTeamChange;

  const MainPage({
    super.key,
    required this.toggleTheme,
    this.userRole,
    this.userTeam,
    this.teamrole,
    required this.currentUsername,
    required this.onTeamChange,
  });

  @override
  State<MainPage> createState() => MainPageState();
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MainPageState extends State<MainPage> with RouteAware {
  final UserService _userService = UserService();
  String? _userEmail;
  String? _userCity;
  String? _userMemberSince;
  String? _userRole;
  String? _userTeam;
  String? _teamrole;
  String _version = '';
  bool _isLoading = true;
  String _maintenanceMessage = '';
  bool _showMapButton = true;

  @override
  void initState() {
    super.initState();
    _initPackageInfo().then((_) => _loadRemoteConfig());
    fetchProfileData(); 
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      if (appState.forcePasswordChange) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Passwortwechsel erforderlich'),
            content: const Text('Du wirst beim nächsten Login aufgefordert, dein Passwort zu ändern.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Später')),
              ElevatedButton(onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/profile');
              }, child: const Text('Jetzt ändern')),
            ],
          ),
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    fetchProfileData();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _version = info.version;
    });
  }

  Future<void> _loadRemoteConfig() async {
    await RemoteConfigService.instance.refresh();
    if (!mounted) return;
    setState(() {
      _maintenanceMessage = RemoteConfigService.instance.maintenanceMessage;
      _showMapButton = RemoteConfigService.instance.showMapButton;
    });

    if (_version.isNotEmpty && RemoteConfigService.instance.isUpdateRequired(_version)) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Update erforderlich'),
          content: const Text('Bitte aktualisiere die App, um fortzufahren.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  Future<void> fetchProfileData() async {
    if (widget.currentUsername == null || widget.currentUsername == 'Gast') {
      setState(() => _isLoading = false);
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
        _teamrole = userData['teamrole'] ?? 'member';
        _userRole = userData['role'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Laden: ${result['message']}')),
      );
    }
  }

  Future<void> _handleLogout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ausloggen'),
        content: const Text('Möchtest du dich wirklich ausloggen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ja, Ausloggen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      Provider.of<AppState>(context, listen: false).logout();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  Future<void> _fetchTeamMembersAndNavigate() async {
    if (_userTeam == null || _userTeam!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Du bist keinem Team zugeordnet.')));
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
            onTeamChange: widget.onTeamChange, // Updated to match the signature
            userEmail: _userEmail,
            userCity: _userCity,
            userMemberSince: _userMemberSince,
            userRole: _userRole,
            teamrole: _teamrole,
            userTeam: _userTeam,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.green)));
    }

    final bool isAdmin = _userRole == "admin";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Airsoft App', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/app_bgr2.jpg'), fit: BoxFit.cover),
          ),
        ),
      ),
      drawer: Drawer(
        width: 220,
        child: Column(
          children: [
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/images/app_bgr2.jpg'), fit: BoxFit.cover),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Menü', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Builder(
                      builder: (BuildContext context) {
                        return IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Scaffold.of(context).closeDrawer(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () => Navigator.of(context).pushNamed('/profile'),
            ),
            ListTile(
              leading: const Icon(Icons.area_chart_outlined),
              title: const Text('Field-Owner'),
              onTap: () => Navigator.of(context).pushNamed('/fieldownerlogin'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Einstellungen'),
              onTap: () => Navigator.of(context).pushNamed('/settings'),
            ),
            const Divider(),
            if (isAdmin)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
                title: const Text('Admin-Bereich'),
                onTap: () => Navigator.of(context).pushNamed('/admin'),
              ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Ausloggen'),
              onTap: _handleLogout,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Version v$_version', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/images/app_bgr.jpg', fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                if (_maintenanceMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _maintenanceMessage,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildMenuButton(Icons.group, _fetchTeamMembersAndNavigate),
                      _buildMenuButton(Icons.group_add, () async {
                        final newTeam = await Navigator.of(context).push<String>(
                          MaterialPageRoute(builder: (_) => CreateTeamPage(userService: _userService, username: widget.currentUsername!)),
                        );
                        if (newTeam != null) fetchProfileData();
                      }),
                      _buildMenuButton(Icons.list, () => Navigator.of(context).pushNamed('/allTeams', arguments: {'currentUsername': widget.currentUsername, 'userTeam': _userTeam})),
                      _buildMenuButton(Icons.area_chart_outlined, () => Navigator.of(context).pushNamed('/fieldslist')),
                      if (_showMapButton) _buildMenuButton(Icons.gps_fixed, _handleGps),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGps() async {
    final updatedCity = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => FieldMapPage(currentUsername: widget.currentUsername),
      ),
    );
    if (updatedCity != null && mounted) {
      setState(() => _userCity = updatedCity);
    }
  }

  Widget _buildMenuButton(IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        // KORREKTUR: .withValues() statt .withOpacity() wegen Deprecation
        backgroundColor: Colors.green.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Icon(icon, color: Colors.white, size: 50),
    );
  }
}