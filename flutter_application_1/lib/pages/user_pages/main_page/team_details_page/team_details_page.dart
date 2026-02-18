import 'package:http/http.dart' as http;
import 'package:pewpew_connect/service/imports.dart';
import 'package:pewpew_connect/pages/user_pages/main_page/team_details_page/teamleader_actions_page.dart';

class TeamDetailsPage extends StatefulWidget {
  final String teamName;
  final List<String> members;
  final String currentUsername;
  final String? userEmail;
  final String? userCity;
  final String? userMemberSince;
  final String? userTeam;
  final String? teamrole;
  final String? userRole;

  final void Function({
    required String username,
    required bool stayLoggedIn, // Das hier ist der entscheidende Pin!
    String? email,
    String? city,
    String? team,
    String? memberSince,
    String? role,
    String? teamrole,
  }) onTeamChange;

  const TeamDetailsPage({
    super.key,
    required this.teamName,
    required this.members,
    required this.currentUsername,
    required this.onTeamChange,
    this.userEmail,
    this.userCity,
    this.userMemberSince,
    this.userTeam,
    this.teamrole,
    this.userRole,
  });

  @override
  State<TeamDetailsPage> createState() => _TeamDetailsPageState();
}

class _TeamDetailsPageState extends State<TeamDetailsPage> {
  late List<String> _members;

  @override
  void initState() {
    super.initState();
    _members = List.from(widget.members);
  }

  Future<void> _leaveTeam() async {
    final url = Uri.parse('$ipAddress/leave_team.php');
    try {
      final response = await http.post(
        url,
        body: {'username': widget.currentUsername},
      );
      final Map<String, dynamic> data = json.decode(response.body);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );

      if (data['success'] == true) {
        AnalyticsService.instance.logEvent('team_left', parameters: {
          'team_name': widget.teamName,
        });
        widget.onTeamChange(
          username: widget.currentUsername,
          stayLoggedIn: true, // Added this required parameter
          email: widget.userEmail,
          city: widget.userCity,
          memberSince: widget.userMemberSince,
          role: widget.userRole,
          team: null,
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verbindungsfehler: $e')),
      );
    }
  }

  void _confirmLeaveTeam() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Team verlassen?'),
          content: Text(
              'Sind Sie sicher, dass Sie das Team "${widget.teamName}" verlassen möchten?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _leaveTeam();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Verlassen',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = widget.currentUsername;
    final teamRoleValue = widget.teamrole?.toString().toLowerCase().trim() ?? '';
    final isLeader = teamRoleValue == 'leader' || teamRoleValue == '2';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.teamName,
          style: const TextStyle(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
            ),
            const SizedBox(height: 30),
            const Text(
              "Mitglieder des Teams:",
              style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Divider(height: 15, thickness: 1.5),
            if (_members.length <= 1 && _members.contains(currentUser))
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    "Sie sind das einzige Mitglied dieses Teams.",
                    style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey),
                  ),
                ),
              )
            else
                  ..._members.map((member) {
                final isCurrentUser = member == currentUser;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: isCurrentUser ? 4 : 2,
                  color:
                      isCurrentUser ? Colors.lightBlue.shade50 : Colors.white,
                  child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => UserProfilePage(username: member)),
                          );
                        },
                    leading: Icon(
                      isCurrentUser
                          ? Icons.person_pin
                          : Icons.person_outline,
                      color:
                          isCurrentUser ? const Color.fromARGB(255, 41, 107, 43) : Colors.black54,
                    ),
                    title: Text(
                      member,
                      style: TextStyle(
                        fontWeight: isCurrentUser
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 17,
                        color: isCurrentUser
                            ? Color.fromARGB(255, 41, 107, 43)
                            : Colors.black87,
                      ),
                    ),
                    trailing: isCurrentUser
                        ? Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 41, 107, 43),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              'Sie',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          )
                        : null,
                  ),
                );
              }),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _confirmLeaveTeam,
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Team verlassen',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 174, 30, 30),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            if (isLeader == true) ...[
              const SizedBox(height: 40),
              const Text(
                "⚙️ Teamleader Aktionen:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const Divider(height: 15, thickness: 1.5),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TeamLeaderActionsPage(
                          teamName: widget.teamName,
                          currentUsername: currentUser,
                          members: _members,
                          onTeamChange: widget.onTeamChange,
                          userEmail: widget.userEmail,
                          userCity: widget.userCity,
                          userMemberSince: widget.userMemberSince,
                          userRole: widget.userRole,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
                  label: const Text('Zur Teamleaderseite'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 41, 107, 43),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}