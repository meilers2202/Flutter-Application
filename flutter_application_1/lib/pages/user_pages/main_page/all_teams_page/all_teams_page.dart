import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pewpew_connect/service/constants.dart';

class AllTeams extends StatefulWidget {
  const AllTeams({super.key});

  @override
  State<AllTeams> createState() => _AllTeamsState();
}

class _AllTeamsState extends State<AllTeams> {
  // Das Team-Objekt hat 'teamName' (String) und 'memberCount' (int/String)
  List<dynamic> _teams = []; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeams();
  }

  // Funktion zum Abrufen der Teams (unverändert)
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
      body: RefreshIndicator( // Ermöglicht Pull-to-Refresh
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
                      // Sicherstellen, dass die Member-Anzahl als String behandelt wird
                      final memberCount = team['memberCount']?.toString() ?? '0'; 

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        elevation: 4, // Etwas Schatten für besseres Aussehen
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Abgerundete Ecken
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          
                          // Icon des Teams
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor, 
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.group, color: Colors.white, size: 28),
                          ),
                          
                          // Teamname
                          title: Text(
                            team['teamName'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          
                          // Mitgliederanzahl
                          subtitle: Text(
                            '$memberCount Mitglieder',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          
                          // Aktions-Icon (Beitreten)
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.blueGrey,
                            size: 16,
                          ),
                          
                          onTap: () {
                            // Übergebe den Team-Namen als Argument
                            Navigator.of(context).pushNamed(
                              '/joinTeam',
                              arguments: team['teamName'],
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}