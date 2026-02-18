import 'package:http/http.dart' as http;
import 'package:pewpew_connect/service/imports.dart';

class TeamMembersViewPage extends StatefulWidget {
  final String teamName;
  final String currentUsername;
  final List<String> members;
  final String? userEmail;
  final String? userCity;
  final String? userMemberSince;
  final String? userRole;
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

  const TeamMembersViewPage({
    super.key,
    required this.teamName,
    required this.currentUsername,
    required this.members,
    required this.onTeamChange,
    this.userEmail,
    this.userCity,
    this.userMemberSince,
    this.userRole,
  });

  @override
  State<TeamMembersViewPage> createState() => _TeamMembersViewPageState();
}

class _TeamMembersViewPageState extends State<TeamMembersViewPage> {
  late List<String> _members;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _members = List.from(widget.members);
  }

  Future<void> _removeMember(String member) async {
    final url = Uri.parse('$ipAddress/remove_member.php');
    try {
      final response = await http.post(url, body: {
        'leader': widget.currentUsername,
        'member': member,
      });
      final data = json.decode(response.body);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(data['message'])));

      if (data['success'] == true) {
        setState(() {
          _members.remove(member);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Fehler: $e')));
    }
  }

  Future<void> _transferLeadership(String newLeader) async {
    final url = Uri.parse('$ipAddress/transfer_leadership.php');
    try {
      final response = await http.post(url, body: {
        'leader': widget.currentUsername,
        'newLeader': newLeader,
      });
      final data = json.decode(response.body);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(data['message'])));

      if (data['success'] == true) {
        final profileResult = await _userService.fetchProfileData(widget.currentUsername);
        final userData = profileResult['success'] == true
            ? Map<String, dynamic>.from(profileResult['user'] as Map)
            : <String, dynamic>{};

        final refreshedEmail = userData['email']?.toString() ?? widget.userEmail;
        final refreshedCity = userData['city']?.toString() ?? widget.userCity;
        final refreshedTeam = userData['team']?.toString() ?? widget.teamName;
        final refreshedMemberSince =
            userData['memberSince']?.toString() ?? widget.userMemberSince;
        final refreshedRole = userData['role']?.toString() ?? widget.userRole;
        final refreshedTeamRole = userData['teamrole']?.toString() ?? '1';

        widget.onTeamChange(
          username: widget.currentUsername,
          stayLoggedIn: true,
          email: refreshedEmail,
          city: refreshedCity,
          team: refreshedTeam,
          memberSince: refreshedMemberSince,
          role: refreshedRole,
          teamrole: refreshedTeamRole,
        );

        if (!mounted) return;
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Fehler: $e')));
    }
  }

  void _confirmRemoveMember(String member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Mitglied entfernen"),
        content: Text("Möchten Sie $member wirklich aus dem Team entfernen?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Abbrechen"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              _removeMember(member);
            },
            child:
                const Text("Entfernen", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmTransferLeadership(String member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Teamleitung übertragen"),
        content: Text("Möchten Sie die Teamleitung wirklich an $member übertragen?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Abbrechen"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () {
              Navigator.of(context).pop();
              _transferLeadership(member);
            },
            child: const Text("Übertragen", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = widget.currentUsername;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mitglieder: ${widget.teamName}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
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
      body: _members.where((m) => m != currentUser).isEmpty
          ? const Center(
              child: Text(
                'Keine Mitglieder gefunden.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: _members
                    .where((m) => m != currentUser)
                    .map(
                      (member) => Card(
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserProfilePage(username: member),
                              ),
                            );
                          },
                          title: Text(member),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.person_remove,
                                    color: Colors.red),
                                tooltip: 'Mitglied entfernen',
                                onPressed: () => _confirmRemoveMember(member),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.swap_horiz, color: Colors.blue),
                                tooltip: 'Teamleitung übertragen',
                                onPressed: () =>
                                    _confirmTransferLeadership(member),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
    );
  }
}
