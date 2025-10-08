import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pewpew_connect/service/constants.dart'; // <- für ipAddress

class BlocklistPage extends StatefulWidget {
  const BlocklistPage({super.key});

  @override
  State<BlocklistPage> createState() => _BlocklistPageState();
}

class _BlocklistPageState extends State<BlocklistPage> {
  List<String> _blockedUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchBlockedUsers();
  }

  Future<void> _fetchBlockedUsers() async {
    final url = Uri.parse('$ipAddress/get_blocked_users.php');
    try {
      final response = await http.get(url);
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        setState(() {
          _blockedUsers = List<String>.from(data['users']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Laden: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Blocklist',
          style: TextStyle(
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
      body: RefreshIndicator(
        onRefresh: _fetchBlockedUsers,
        child: _blockedUsers.isEmpty
            ? const Center(
                child: Text(
                  'Keine blockierten Benutzer.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _blockedUsers.length,
                itemBuilder: (context, index) {
                  final username = _blockedUsers[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.block, color: Colors.red),
                      title: Text(username),
                      // TODO: hier könnte man „Entblocken“ hinzufügen
                    ),
                  );
                },
              ),
      ),
    );
  }
}
