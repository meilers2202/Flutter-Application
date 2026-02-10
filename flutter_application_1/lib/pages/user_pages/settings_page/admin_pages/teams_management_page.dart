
import 'package:http/http.dart' as http;
import 'package:pewpew_connect/service/imports.dart';

class TeamsManagementPage extends StatefulWidget {
  const TeamsManagementPage({super.key});

  @override
  State<TeamsManagementPage> createState() => _TeamsManagementPageState();
}

class _TeamsManagementPageState extends State<TeamsManagementPage> {
  List<String> _teams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllTeams();
  }

  Future<void> _confirmDeleteTeam(String team) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Team löschen'),
        content: Text('Möchtest du das Team "$team" wirklich löschen? Dies kann nicht rückgängig gemacht werden.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Löschen')),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteTeam(team);
    }
  }

  Future<void> _deleteTeam(String team) async {
    final url = Uri.parse('$ipAddress/delete_team.php');
    try {
      // show loading
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final response = await http.post(url, body: {'teamName': team}).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      // remove loading
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (_) {}

      if (response.statusCode != 200) {
        debugPrint('delete_team.php non-200 response: ${response.statusCode}');
        debugPrint('body: ${response.body}');

        // Fallback: if the team no longer exists, treat as success
        final bool existsAfter = await _checkTeamExistsRemotely(team);
        if (!mounted) return;
        if (!existsAfter) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Team wurde möglicherweise gelöscht (Server antwortete mit Fehler, aber Team nicht mehr vorhanden).')));
          await _fetchAllTeams();
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Server-Fehler: HTTP ${response.statusCode}')));
        return;
      }

      final body = response.body.trim();
      if (body.isEmpty) {
        debugPrint('delete_team.php returned empty body');

        final bool existsAfter = await _checkTeamExistsRemotely(team);
        if (!mounted) return;
        if (!existsAfter) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Team wurde gelöscht (leere Server-Antwort).')));
          await _fetchAllTeams();
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leere Antwort vom Server beim Löschen')));
        return;
      }

      Map<String, dynamic> data;
      try {
        data = json.decode(body) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('delete_team.php invalid json: $body');

        final bool existsAfter = await _checkTeamExistsRemotely(team);
        if (!mounted) return;
        if (!existsAfter) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Team wurde gelöscht (Server-Antwort nicht-JSON).')));
          await _fetchAllTeams();
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ungültige Server-Antwort: $e')));
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Keine Antwort vom Server')));
      if (data['success'] == true) {
        _fetchAllTeams();
      }
    } catch (e) {
      if (!mounted) return;
      // remove loading if still present
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (_) {}

      debugPrint('delete_team.php request error: $e');

      // As last resort, check whether the team still exists
      final bool existsAfter = await _checkTeamExistsRemotely(team);
      if (!mounted) return;
      if (!existsAfter) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Team wurde gelöscht (Fehler, aber Team nicht mehr vorhanden).')));
        await _fetchAllTeams();
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler beim Löschen: $e')));
    }
  }

  // Helper: query the server for the current teams and return whether team exists
  Future<bool> _checkTeamExistsRemotely(String team) async {
    try {
      final url = Uri.parse('$ipAddress/get_all_teams_management.php');
      final response = await http.post(url).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return true; // cannot determine -> assume exists
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        final List<String> teams = List<String>.from(data['teams']);
        return teams.contains(team);
      }
      return true;
    } catch (e) {
      debugPrint('checkTeamExists error: $e');
      return true;
    }
  }




  Future<void> _fetchAllTeams() async {
    final url = Uri.parse('$ipAddress/get_all_teams_management.php');
    try {
      final response = await http.post(url);
      if (!mounted) return;
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        if (mounted) {
          setState(() {
            _teams = List<String>.from(data['teams']);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verbindungsfehler: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Teams',
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _teams.isEmpty
              ? const Center(
                  child: Text(
                    'Keine Teams gefunden.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: _teams.length,
                  itemBuilder: (context, index) {
                    final team = _teams[index];
                    return ListTile(
                      title: Text(
                        team,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      leading: Icon(
                        Icons.groups,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      onTap: () {
                        // Zur Team-Mitglieder-Seite navigieren
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeamMembersPage(teamName: team),
                          ),
                        ).then((value) {
                          // Falls Mitglieder entfernt wurden, Liste aktualisieren
                          _fetchAllTeams();
                        });
                      },
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'members') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TeamMembersPage(teamName: team)),
                            ).then((_) => _fetchAllTeams());
                          } else if (value == 'delete') {
                            _confirmDeleteTeam(team);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'members', child: Text('Mitglieder anzeigen')),
                          const PopupMenuItem(value: 'delete', child: Text('Team löschen', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}