import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String ipAddress = 'localhost';

class JoinTeam extends StatefulWidget {
  final String teamName;
  final String currentUsername;

  const JoinTeam({
    super.key,
    required this.teamName,
    required this.currentUsername,
  });

  @override
  State<JoinTeam> createState() => _JoinTeamState();
}

class _JoinTeamState extends State<JoinTeam> {
  
  Future<void> _joinTeam() async {
    final url = Uri.parse('http://$ipAddress/join_team.php');
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // Abfrage
          // if userTeam == teamName 
          //    "Du bist bereits "
          children: <Widget>[
            Text(
              'Möchtest du dem Team "${widget.teamName}" beitreten?',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
              
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _joinTeam();
                Navigator.of(context).pushNamed('/main');
              },

              child: const Text('Beitreten'),
            ),
          ],
        ),
      ),
    );
  }
}