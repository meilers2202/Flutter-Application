
import 'package:http/http.dart' as http;
import 'package:pewpew_connect/service/imports.dart';

class AllTeams extends StatefulWidget {
  const AllTeams({super.key});

  @override
  State<AllTeams> createState() => _AllTeamsState();
}

class _AllTeamsState extends State<AllTeams> {
  List<dynamic> _teams = [];
  bool _isLoading = true;

  // NEU: Benutzerinfos
  String? _currentUsername;
  String? _userTeam;

  @override
  void initState() {
    super.initState();

    // Warte, bis Build ausgeführt wird, um ModalRoute nutzen zu können
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        _currentUsername = args['currentUsername'] as String?;
        _userTeam = args['userTeam'] as String?;
      }

      await _fetchTeams();

    });
  }

  Future<void> _fetchTeams() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('$ipAddress/get_all_teams.php');
    try {
      final response = await http.post(url);
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        setState(() {
          _teams = data['teams'];
        });

        // ✅ Alle Teams einzeln ausgeben
        //print('--------------TeamPage DEBUG--------------');
        // for (var team in _teams) {
        //   print('Teamname: ${team['teamName']}, Mitglieder: ${team['memberCount']}');
        // }
        // print('------------------------------------------');
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Team beitreten',
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
      body: RefreshIndicator(
        onRefresh: _fetchTeams,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _teams.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_off, size: 50, color: Colors.grey),
                        SizedBox(height: 10),
                        Text('Keine Teams gefunden.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        Text('Ziehen Sie nach unten zum Aktualisieren.', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12.0),
                    itemCount: _teams.length,
                    itemBuilder: (context, index) {
                      final team = _teams[index];
                      final memberCount = team['memberCount']?.toString() ?? '0';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 41, 107, 43),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.group, color: Colors.white, size: 28),
                          ),
                          title: Text(
                            team['teamName'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text('$memberCount Mitglieder', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueGrey, size: 16),
                          onTap: () async {
                            final result = await Navigator.of(context).pushNamed(
                              '/teamDetails',
                              arguments: {
                                'teamName': team['teamName'],
                                'username': _currentUsername,
                                'userCurrentTeam': _userTeam,
                              },
                            );

                            if (result != null && result is String) {
                              setState(() {
                                _userTeam = result;
                              });
                              await _fetchTeams();
                            }
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
