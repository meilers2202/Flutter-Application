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
        if (mounted) {
          setState(() {
            _blockedUsers = List<String>.from(data['users']);
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
          SnackBar(content: Text('Fehler beim Laden: $e')),
        );
      }
    }
  }

  Future<void> _unblockUser(String username) async {
    final url = Uri.parse('$ipAddress/unblock_user.php');
    try {
      final response = await http.post(url, body: {'username': username});
      final data = json.decode(response.body);

      if (data['success'] == true && mounted) {
        // Benutzer sofort lokal entfernen
        setState(() {
          _blockedUsers.remove(username);
        });
      }

      // SnackBar anzeigen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Fehler beim Entblocken')),
        );
      }

      // Optional: Serverliste aktualisieren, falls nötig
      // await _fetchBlockedUsers();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verbindungsfehler: $e')),
        );
      }
    }
  }

  void _openUnblockDialog(String username) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text('Benutzer entblocken'),
                onTap: () async {
                  Navigator.pop(context);
                  await _unblockUser(username);
                },
              ),
            ],
          ),
        );
      },
    );
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
                            username,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          trailing: IconButton( 
                                icon: const Icon(Icons.edit, color: Color.fromARGB(255, 41, 107, 43)),
                                onPressed: () => _openUnblockDialog(username),
                            ),
                            onTap: () => _openUnblockDialog(username),
                        ),
                  );
                },
              ),
      ),
    );
  }
}
