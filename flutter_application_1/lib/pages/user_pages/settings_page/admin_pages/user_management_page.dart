import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pewpew_connect/service/constants.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  
  List<String> _users = []; 
  @override
  void initState() {
    super.initState();
    _fetchAllUsers();
  }

  Future<void> _fetchAllUsers() async {
    final url = Uri.parse('$ipAddress/get_all_users.php');
    try {
      final response = await http.post(url);
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        if (mounted) {
          setState(() {
            _users = List<String>.from(data['users']);
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verbindungsfehler: $e')),
        );
      }
    } 
  }
  
  // Platzhalter für die zukünftige Bearbeitungsfunktion
  void _openUserEdit(String username) {
    ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Öffne Bearbeitung für $username')),
        );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Benutzerverwaltung', 
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
      body: RefreshIndicator( 
        onRefresh: _fetchAllUsers,
        child: _users.isEmpty
              ? const Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_alt_outlined, size: 50, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          'Keine Benutzer gefunden.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text(
                          'Zum Aktualisieren herunterziehen.',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                )
              : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return Card( 
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                          leading: Container(
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.person_outline,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  size: 24,
                                ),
                            ),
                          title: Text(
                            user,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          trailing: IconButton( 
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _openUserEdit(user),
                            ),
                            onTap: () => _openUserEdit(user),
                        ),
                    );
                  },
                ),
        ),
    );
  }
}