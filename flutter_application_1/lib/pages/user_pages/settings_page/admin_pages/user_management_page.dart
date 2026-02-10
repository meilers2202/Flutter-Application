import 'package:http/http.dart' as http;
import 'package:pewpew_connect/service/imports.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<String> _users = [];
  List<String> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterUsers);
    _fetchAllUsers();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    super.dispose();
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
          setState(() {
            _users = List<String>.from(data['users']);
            _filteredUsers = List.from(_users);
          });
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
    final ingameRole = user['ingamerole'] ?? '';
    final profileImage = user['profile_image_url'] as String?;
    final forcePW = user['force_password_change'] == true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.68,
          minChildSize: 0.35,
          maxChildSize: 0.95,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.green.shade700,
                    backgroundImage: profileImage != null ? NetworkImage(profileImage) : null,
                    child: profileImage == null ? Text(_initials(username), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)) : null,
                  ),
                  const SizedBox(height: 12),
                  Text(username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 8),
                  if (forcePW)
                    Chip(label: const Text('Passwortwechsel erforderlich'), backgroundColor: Colors.orange.shade100),
                  const SizedBox(height: 12),

                  const Divider(),
                  _buildInfoRow(Icons.email, email),
                  _buildInfoRow(Icons.location_city, city),
                  const Divider(),
                  _buildInfoRow(Icons.group, team),
                  _buildInfoRow(Icons.badge, teamRole),
                  _buildInfoRow(Icons.sports_esports, ingameRole),
                  const Divider(),
                  _buildInfoRow(Icons.calendar_today, memberSince),
                  _buildInfoRow(Icons.admin_panel_settings, role),

                  const SizedBox(height: 16),

                  if (!forcePW)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, minimumSize: const Size.fromHeight(48)),
                      icon: const Icon(Icons.vpn_key),
                      label: const Text('Passwortwechsel erzwingen'),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Passwortwechsel erzwingen'),
                            content: Text('Soll $username beim nächsten Login aufgefordert werden, das Passwort zu ändern?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
                              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Erzwingen')),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          await _requirePasswordChange(username);
                        }
                      },
                    )
                  else
                    OutlinedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Passwortwechsel angefordert'),
                      onPressed: null,
                    ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size.fromHeight(44)),
                          icon: const Icon(Icons.block),
                          label: const Text('Benutzer blockieren'),
                          onPressed: () {
                            Navigator.pop(context);
                            _confirmAndExecuteBlock(username);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size.fromHeight(44)),
                          icon: const Icon(Icons.remove_circle_outline),
                          label: const Text('Benutzer entfernen'),
                          onPressed: () {
                            Navigator.pop(context);
                            _confirmAndExecuteDelete(username);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Schließen'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _requirePasswordChange(String username) async {
    try {
      final response = await http.post(Uri.parse('$ipAddress/require_password_change.php'), body: {'username': username});
      final data = json.decode(response.body) as Map<String, dynamic>;
      _showError(data['message'] ?? 'Antwort erhalten');
      if (data['success'] == true) {
        _fetchAllUsers();
      }
    } catch (e) {
      _showError('Verbindungsfehler: $e');
    }
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

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredUsers = List.from(_users));
    } else {
      setState(() => _filteredUsers = _users.where((u) => u.toLowerCase().contains(query)).toList());
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Future<void> _confirmAndExecuteBlock(String username) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Benutzer blockieren'),
        content: Text('Soll Benutzer "$username" wirklich blockiert werden?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Blockieren')),
        ],
      ),
    );
    if (confirmed == true) {
      await _blockUser(username);
    }
  }

  Future<void> _confirmAndExecuteDelete(String username) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Benutzer löschen'),
        content: Text('Soll Benutzer "$username" wirklich gelöscht werden? Diese Aktion kann nicht rückgängig gemacht werden.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Löschen')),
        ],
      ),
    );
    if (confirmed == true) {
      await _deleteUser(username);
    }
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Suchen (Benutzername)...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
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
                    : _filteredUsers.isEmpty
                      ? Center(child: Text('Keine Benutzer zu "${_searchController.text}" gefunden.', style: const TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green.shade700,
                                  child: Text(_initials(user), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                                title: Text(user, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                subtitle: const Text('Tippe zum Bearbeiten', style: TextStyle(fontSize: 12)),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _openUserEdit(user);
                                    } else if (value == 'block') {
                                      _confirmAndExecuteBlock(user);
                                    } else if (value == 'delete') {
                                      _confirmAndExecuteDelete(user);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Bearbeiten'))),
                                    const PopupMenuItem(value: 'block', child: ListTile(leading: Icon(Icons.block, color: Colors.red), title: Text('Blockieren'))),
                                    const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.orange), title: Text('Entfernen'))),
                                  ],
                                ),
                                onTap: () => _openUserEdit(user),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}