import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pewpew_connect/service/constants.dart';

class JoinTeam extends StatefulWidget {
  final String teamName;
  final String currentUsername;
  final String? userCurrentTeam; // aktuelles Team des Benutzers

  const JoinTeam({
    super.key,
    required this.teamName,
    required this.currentUsername,
    this.userCurrentTeam,
  });

  @override
  State<JoinTeam> createState() => _JoinTeamState();
}

class _JoinTeamState extends State<JoinTeam> {
  bool _isLoading = false;

  Future<void> _joinTeam() async {
    setState(() => _isLoading = true);

    final url = Uri.parse('$ipAddress/join_team.php');
    try {
      final response = await http.post(url, body: {
        'username': widget.currentUsername,
        'teamName': widget.teamName,
      });

      final Map<String, dynamic> data = json.decode(response.body);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );

      if (data['success'] == true) {
          // print('New Team ${widget.teamName}');
          Navigator.pop(context, widget.teamName); // ✅
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verbindungsfehler: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAlreadyMember = widget.userCurrentTeam == widget.teamName;
    final isInAnotherTeam = widget.userCurrentTeam != null &&
        widget.userCurrentTeam!.isNotEmpty &&
        !isAlreadyMember;

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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // BEREITS MITGLIED
              if (isAlreadyMember) ...[
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
                const SizedBox(height: 20),
                Text(
                  'Glückwunsch, ${widget.currentUsername}!',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Du bist bereits ein Mitglied des Teams "${widget.teamName}".',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  label: const Text('Zurück', style: TextStyle(fontSize: 18, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                ),
              ]
              // MITGLIED IN EINEM ANDEREN TEAM
              else if (isInAnotherTeam) ...[
                const Icon(Icons.warning_amber, color: Colors.orange, size: 80),
                const SizedBox(height: 20),
                Text(
                  'Achtung, ${widget.currentUsername}!',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.orange),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    text: 'Du bist derzeit Mitglied in dem Team: ',
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                        text: '${widget.userCurrentTeam}', // Teamname
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.green, // hier die Farbe des Teams
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: '.', // Punkt am Ende
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),



                Text.rich(
                  TextSpan(
                    text: 'Möchtest du das Team wechseln zu: ',
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                        text: '${widget.teamName}', // Teamname
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.green, // hier die Farbe des Teams
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: '.', // Punkt am Ende
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                _buildJoinButton(),
              ]
              // STANDARD ANZEIGE (Beitreten)
              else ...[
                const Icon(Icons.group_add_outlined, color: Colors.blue, size: 80),
                const SizedBox(height: 20),
                Text(
                  'Tritt dem Team bei, ${widget.currentUsername}!',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Möchtest du dem Team "${widget.teamName}" beitreten?',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                _buildJoinButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _joinTeam,
      icon: const Icon(Icons.add_task, color: Colors.white),
      label: const Text('Jetzt beitreten', style: TextStyle(fontSize: 20, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
