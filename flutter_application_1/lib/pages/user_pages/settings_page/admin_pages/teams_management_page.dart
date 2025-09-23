import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String ipAddress = 'localhost'; // Oder die IP-Adresse deines Servers

class TeamsManagementPage extends StatefulWidget {
  const TeamsManagementPage({super.key});

  @override
  State<TeamsManagementPage> createState() => _TeamsManagementPageState();
}

class _TeamsManagementPageState extends State<TeamsManagementPage> {
  List<String> _teams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllUsers();
  }

  Future<void> _fetchAllUsers() async {
    final url = Uri.parse('http://$ipAddress/get_all_teams_management.php');
    try {
      final response = await http.post(url);
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        if (mounted) {
          setState(() {
            _teams = List<String>.from(data['teams']);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verbindungsfehler: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Field Owners',
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
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _teams.isEmpty
              ? const Center(
                  child: Text(
                    'Keine Benutzer gefunden.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: _teams.length,
                  itemBuilder: (context, index) {
                    final user = _teams[index];
                    return ListTile(
                      title: Text(
                        user,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      leading: Icon(
                        Icons.groups,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    );
                  },
                ),
    );
  }
}