import 'package:http/http.dart' as http;
import 'package:pewpew_connect/service/imports.dart';

class IngameRolesAdminPage extends StatefulWidget {
  const IngameRolesAdminPage({super.key});

  @override
  State<IngameRolesAdminPage> createState() => _IngameRolesAdminPageState();
}

class _IngameRolesAdminPageState extends State<IngameRolesAdminPage> {
  final TextEditingController _nameController = TextEditingController();
  List<Map<String, dynamic>> _roles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('$ipAddress/get_ingameroles.php'));
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          _roles = List<Map<String, dynamic>>.from(data['roles']);
          _isLoading = false;
        });
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      _isLoading = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: $e')));
      }
    }
  }

  Future<void> _addRole() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('$ipAddress/manage_ingamerole.php'),
        body: {'action': 'add', 'name': name},
      );
      final data = json.decode(response.body);
      if (data['success']) {
        _nameController.clear();
        _loadRoles(); // Liste neu laden
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler beim Hinzufügen: $e')));
      }
    }
  }

  Future<void> _deleteRole(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Löschen bestätigen'),
        content: Text('Möchtest du den Rang "$name" wirklich löschen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Abbrechen')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Löschen')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.post(
          Uri.parse('$ipAddress/manage_ingamerole.php'),
          body: {'action': 'delete', 'id': '$id'},
        );
        final data = json.decode(response.body);
        if (data['success']) {
          _loadRoles();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rollen verwalten',
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
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Eingabefeld + Button zum Hinzufügen
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Neuen Rang eingeben',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addRole(),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _addRole,
                    icon: const Icon(Icons.add),
                    label: const Text('Rang hinzufügen'),
                  ),
                  const SizedBox(height: 24),

                  // Liste der Ränge
                  Expanded(
                    child: _roles.isEmpty
                        ? const Center(child: Text('Keine Ränge vorhanden.'))
                        : ListView.builder(
                            itemCount: _roles.length,
                            itemBuilder: (context, index) {
                              final role = _roles[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  title: Text(role['name']),
                                  subtitle: Text('ID: ${role['id']}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteRole(role['id'], role['name']),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}