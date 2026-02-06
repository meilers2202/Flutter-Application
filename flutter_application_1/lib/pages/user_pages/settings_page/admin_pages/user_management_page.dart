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

  Future<void> _showError(String message) async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _fetchAllUsers() async {
    try {
      final response = await http.post(Uri.parse('$ipAddress/get_all_users.php'));
      final data = json.decode(response.body) as Map<String, dynamic>;

      if (data['success'] == true) {
        if (mounted) {
          setState(() => _users = List<String>.from(data['users']));
        }
      } else {
        _showError(data['message'] ?? 'Fehler beim Laden');
      }
    } catch (e) {
      _showError('Verbindungsfehler: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchProfileData(String username) async {
    try {
      final response = await http.post(
        Uri.parse('$ipAddress/get_profile.php'),
        body: {'username': username},
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Verbindungsfehler: $e'};
    }
  }

  Future<void> _blockUser(String username) async {
    try {
      final response = await http.post(
        Uri.parse('$ipAddress/block_user.php'),
        body: {'username': username},
      );
      final data = json.decode(response.body);
      _showError(data['message'] ?? 'Fehler beim Blockieren');
      if (data['success'] == true) _fetchAllUsers();
    } catch (e) {
      _showError('Verbindungsfehler: $e');
    }
  }

  Future<void> _deleteUser(String username) async {
    try {
      final response = await http.post(
        Uri.parse('$ipAddress/delete_user.php'),
        body: {'username': username},
      );
      final data = json.decode(response.body);
      _showError(data['message'] ?? 'Fehler beim Löschen');
      if (data['success'] == true) _fetchAllUsers();
    } catch (e) {
      _showError('Verbindungsfehler: $e');
    }
  }

  void _openUserEdit(String username) async {
    final result = await _fetchProfileData(username);
    if (!mounted) return;

    if (result['success'] != true) {
      _showError('Fehler: ${result['message']}');
      return;
    }

    final user = result['user'];
    final email = user['email'] ?? '';
    final city = user['city'] ?? '';
    final team = user['team'] ?? '';
    final memberSince = user['memberSince'] ?? '';
    final role = user['role'] ?? '';
    final teamRole = user['teamrole'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.0), // 5px innen
          child: Container( // 👈 Dieser Container begrenzt die Breite
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 25), // 10px Gesamtabstand (5+5)
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      _buildInfoRow(Icons.email, email),
                      _buildInfoRow(Icons.location_city, city),
                      const Divider(height: 1),
                      _buildInfoRow(Icons.group, team),
                      _buildInfoRow(Icons.badge, teamRole),
                      const Divider(height: 1),
                      _buildInfoRow(Icons.calendar_today, memberSince),
                      const Divider(height: 1),
                      _buildInfoRow(Icons.admin_panel_settings, role),
                      const Divider(height: 1),
                    ],
                  ),
                ),
                const Divider(height: 1),
                _buildActionTile(
                  Icons.block,
                  'Benutzer blockieren',
                  Colors.red,
                  () => _confirmAndExecute(context, () => _blockUser(username)),
                ),
                _buildActionTile(
                  Icons.remove_circle_outline,
                  'Benutzer entfernen',
                  Colors.orange,
                  () => _confirmAndExecute(context, () => _deleteUser(username)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _confirmAndExecute(BuildContext context, Future<void> Function() action) {
    Navigator.pop(context); // schließt das BottomSheet
    action(); // führt Aktion aus (Block/Löschen)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Benutzerverwaltung',
          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
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
                    Text('Keine Benutzer gefunden.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    Text('Zum Aktualisieren herunterziehen.', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      leading: const Icon(Icons.person_outline, size: 24),
                      title: Text(user, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Color.fromARGB(255, 41, 107, 43)),
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