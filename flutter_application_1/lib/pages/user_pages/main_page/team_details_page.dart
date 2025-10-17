import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pewpew_connect/service/constants.dart';

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

  final Function({
    required String username,
    String? team,
    String? email,
    String? city,
    String? memberSince,
    String? role,
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
        widget.onTeamChange(
          username: widget.currentUsername,
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

      if (data['success']) {
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

      if (data['success']) {
        widget.onTeamChange(
          username: widget.currentUsername,
          team: widget.teamName,
          email: widget.userEmail,
          city: widget.userCity,
          memberSince: widget.userMemberSince,
          role: 'member',
        );
        Navigator.of(context).pop();
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
        content: Text(
            "Möchten Sie \"$member\" wirklich aus dem Team entfernen?"),
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
            child: const Text("Entfernen",
                style: TextStyle(color: Colors.white)),
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
        content: Text(
            "Möchten Sie die Teamleitung wirklich an \"$member\" übertragen?"),
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
            child:
                const Text("Übertragen", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = widget.currentUsername;
    final isLeader = widget.teamrole?.toLowerCase() == 'leader';

    // Debug (optional)
    // print(widget.userTeam);

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
              child: ElevatedButton.icon(
                onPressed: _confirmLeaveTeam,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Team verlassen',
                    style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "👥 Mitglieder des Teams:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                    leading: Icon(
                      isCurrentUser
                          ? Icons.person_pin
                          : Icons.person_outline,
                      color:
                          isCurrentUser ? Colors.blue : Colors.black54,
                    ),
                    title: Text(
                      member,
                      style: TextStyle(
                        fontWeight: isCurrentUser
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 17,
                        color: isCurrentUser
                            ? Colors.blue.shade900
                            : Colors.black87,
                      ),
                    ),
                    trailing: isCurrentUser
                        ? Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.blue,
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
            if (isLeader == true) ...[
              const SizedBox(height: 40),
              const Text(
                "⚙️ Teamleader Aktionen:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const Divider(height: 15, thickness: 1.5),
              ..._members
                  .where((m) => m != currentUser)
                  .map(
                    (member) => Card(
                      child: ListTile(
                        title: Text(member),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.person_remove,
                                  color: Colors.red),
                              tooltip: 'Mitglied entfernen',
                              onPressed: () =>
                                  _confirmRemoveMember(member),
                            ),
                            IconButton(
                              icon: const Icon(Icons.swap_horiz,
                                  color: Colors.blue),
                              tooltip: 'Teamleitung übertragen',
                              onPressed: () =>
                                  _confirmTransferLeadership(member),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
