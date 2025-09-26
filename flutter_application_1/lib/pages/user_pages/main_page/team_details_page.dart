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
    this.userRole,
  });

  @override
  State<TeamDetailsPage> createState() => _TeamDetailsPageState();
}

class _TeamDetailsPageState extends State<TeamDetailsPage> {

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

  // NEU: Widget zur Bestätigung des Verlassens
  void _confirmLeaveTeam() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Team verlassen?'),
          content: Text('Sind Sie sicher, dass Sie das Team "${widget.teamName}" verlassen möchten?'),
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
              child: const Text('Verlassen', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ermitteln des aktuellen Benutzers für die Anzeige
    final currentUser = widget.currentUsername;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.teamName,
          style: const TextStyle(
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
      body: SingleChildScrollView( 
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Team verlassen Button (mit Bestätigungsdialog)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _confirmLeaveTeam, 
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Team verlassen', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, 
                  backgroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            
            const SizedBox(height: 30),

            // 2. Mitglieder-Sektion
            const Text(
              "👥 Mitglieder des Teams:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87),
            ),
            const Divider(height: 15, thickness: 1.5),
            
            // Anzeige bei keinen weiteren Mitgliedern
            if (widget.members.length <= 1 && widget.members.contains(currentUser)) 
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    "Sie sind das einzige Mitglied dieses Teams.",
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ),
              )
            else
              // Liste der Mitglieder (mit Cards und Icons)
              ...widget.members.map((member) { // .toList() wurde hier entfernt
                final isCurrentUser = member == currentUser;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: isCurrentUser ? 4 : 2, 
                  color: isCurrentUser ? Colors.lightBlue.shade50 : Colors.white,
                  child: ListTile(
                    leading: Icon(
                      isCurrentUser ? Icons.person_pin : Icons.person_outline,
                      color: isCurrentUser ? Colors.blue : Colors.black54,
                    ),
                    title: Text(
                      member,
                      style: TextStyle(
                        fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                        fontSize: 17,
                        color: isCurrentUser ? Colors.blue.shade900 : Colors.black87,
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
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          )
                        : null,
                  ),
                );
              })
          ],
        ),
      ),
    );
  }
}