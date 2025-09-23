import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String ipAddress = 'localhost';

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
    final url = Uri.parse('http://$ipAddress/leave_team.php');
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

  @override
  Widget build(BuildContext context) {
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
      body: widget.members.isNotEmpty
          ? ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ElevatedButton(
                  onPressed: () {
                    _leaveTeam();
                  },
                  child: const Text("Team verlassen"),
                ),
                const Text(
                  "Mitglieder:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 2),
                ...widget.members.map((member) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        "- $member",
                        style: const TextStyle(fontSize: 16),
                      ),
                    )),
              ],
            )
          : const Center(
              child: Text(
                "Dieses Team hat keine weiteren Mitglieder.",
                style: TextStyle(fontSize: 16),
              ),
            ),
    );
  }
}