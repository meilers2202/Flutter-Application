import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pewpew_connect/service/constants.dart';

class JoinTeam extends StatefulWidget {
  final String teamName;
  final String currentUsername;
  final String? userCurrentTeam; // NEU: Das Team, in dem der Benutzer gerade ist

  const JoinTeam({
    super.key,
    required this.teamName,
    required this.currentUsername,
    this.userCurrentTeam, // NEU: Muss beim Aufruf übergeben werden
  });

  @override
  State<JoinTeam> createState() => _JoinTeamState();
}

class _JoinTeamState extends State<JoinTeam> {
  
  // Funktion zum Beitreten zum Team (Logik unverändert)
  Future<void> _joinTeam() async {
    final url = Uri.parse('$ipAddress/join_team.php');
    try {
      final response = await http.post(
        url,
        body: {
          'username': widget.currentUsername,
          'teamName': widget.teamName,
        },
      );
      final Map<String, dynamic> data = json.decode(response.body);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );

      if (data['success'] == true) {
        // Bei Erfolg zurück zur Hauptseite navigieren
        Navigator.of(context).pushNamedAndRemoveUntil('/main', (Route<dynamic> route) => false);
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
    // 1. Prüfen, ob der Benutzer bereits im Team ist
    final isAlreadyMember = widget.userCurrentTeam == widget.teamName;
    
    // 2. Prüfen, ob der Benutzer in einem anderen Team ist
    final isInAnotherTeam = widget.userCurrentTeam != null && widget.userCurrentTeam!.isNotEmpty && !isAlreadyMember;

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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // *** ANZEIGE, WENN BEREITS MITGLIED ***
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
                // Button, um einfach zurück zur Hauptseite zu gehen
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  label: const Text('Zurück', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                ),
              ] 
              // *** ANZEIGE, WENN MAN IN EINEM ANDEREN TEAM IST ***
              else if (isInAnotherTeam) ...[
                const Icon(Icons.warning_amber, color: Colors.orange, size: 80),
                const SizedBox(height: 20),
                Text(
                  'Achtung, ${widget.currentUsername}!',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Du bist derzeit Mitglied in einem anderen Team (${widget.userCurrentTeam}). Wenn du Team "${widget.teamName}" beitrittst, verlässt du automatisch dein aktuelles Team.',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                _buildJoinButton(),
              ]
              // *** STANDARD ANZEIGE (Beitreten) ***
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

  // Hilfsmethode für den Beitritt-Button (Redundanz vermeiden)
  Widget _buildJoinButton() {
    return ElevatedButton.icon(
      onPressed: _joinTeam,
      icon: const Icon(Icons.add_task, color: Colors.white),
      label: const Text('Jetzt beitreten', style: TextStyle(fontSize: 20)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}