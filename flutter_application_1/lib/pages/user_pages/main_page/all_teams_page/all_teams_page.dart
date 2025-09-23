import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String ipAddress = 'localhost';

class AllTeams extends StatefulWidget {
  const AllTeams({super.key});

  @override
  State<AllTeams> createState() => _AllTeamsState();
}

class _AllTeamsState extends State<AllTeams> {
  List<dynamic> _teams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeams();
  }

  Future<void> _fetchTeams() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://$ipAddress/get_all_teams.php');
    try {
      final response = await http.post(url);
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        setState(() {
          _teams = data['teams'];
        });
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
          ? const Center(child: CircularProgressIndicator())
          : _teams.isEmpty
              ? const Center(child: Text('Keine Teams gefunden.'))
              : ListView.builder(
                  itemCount: _teams.length,
                  itemBuilder: (context, index) {
                    final team = _teams[index];
                    return Column(
                      children: [
                        ListTile(
                          title: Text(team['teamName']),
                          subtitle: Text('${team['memberCount']} Mitglieder'),
                          onTap: () {
                            // Übergebe den Team-Code als Argument
                            Navigator.of(context).pushNamed(
                              '/joinTeam',
                              arguments: team['teamName'],
                            );
                          },
                        ),
                        const Divider(),
                      ],
                    );
                  },
                ),
    );
  }
}