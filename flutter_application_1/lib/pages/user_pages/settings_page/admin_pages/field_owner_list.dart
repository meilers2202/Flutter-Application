import 'package:http/http.dart' as http;
import 'package:pewpew_connect/service/imports.dart';
import 'package:pewpew_connect/service/database_models.dart';

class FieldOwnerList extends StatefulWidget {
  const FieldOwnerList({super.key});

  @override
  State<FieldOwnerList> createState() => _FieldOwnerListState();
}

class _FieldOwnerListState extends State<FieldOwnerList> {
  List<FieldOwner> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllUsers();
  }

  Future<void> _fetchAllUsers() async {
    final url = Uri.parse('$ipAddress/get_field_owners_data.php');
    try {
      final response = await http.post(url);
      final dynamic decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unerwartete Server-Antwort.');
      }
      final Map<String, dynamic> data = decoded;

      if (data['success'] == true) {
        if (mounted) {
          final dynamic usersRaw = data['users'];
          final List<dynamic> rawUsers = usersRaw is List
              ? usersRaw
              : usersRaw is Map
                  ? [usersRaw]
                  : usersRaw is String
                      ? [usersRaw]
                      : [];
          final List<FieldOwner> parsedUsers = [];
          for (final u in rawUsers) {
            if (u is String) {
              parsedUsers.add(FieldOwner(userId: 0, name: u));
            } else if (u is Map) {
              parsedUsers.add(FieldOwner.fromJson(Map<String, dynamic>.from(u)));
            }
          }
          setState(() {
            _users = parsedUsers;
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

  Future<bool> _removeFieldOwner(FieldOwner owner) async {
    final url = Uri.parse('$ipAddress/remove_field_owner.php');
    try {
      final response = await http.post(url, body: {'field_owner_id': owner.userId.toString()});
      if (response.body.trim().isEmpty) {
        throw Exception('Leere Server-Antwort (remove_field_owner.php).');
      }
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Fieldowner entfernt.')),
          );
        }
        return true;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Entfernen fehlgeschlagen.')),
        );
      }
      return false;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verbindungsfehler: $e')),
        );
      }
      return false;
    }
  }

  Future<void> _confirmRemoveFieldOwner(FieldOwner owner) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Fieldowner entfernen'),
        content: Text('Möchtest du "${owner.name}" wirklich entfernen?\nDie Felder werden auf "Abgelehnt" gesetzt.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Entfernen', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      final success = await _removeFieldOwner(owner);
      if (success) {
        _fetchAllUsers();
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
          : _users.isEmpty
              ? const Center(
                  child: Text(
                    'Keine Benutzer gefunden.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return ListTile(
                      title: Text(user.name, style: Theme.of(context).textTheme.bodyMedium),
                      leading: Icon(
                        Icons.area_chart_outlined,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Entfernen',
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _confirmRemoveFieldOwner(user),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      onLongPress: () => _confirmRemoveFieldOwner(user),
                      onTap: () {
                        if (user.userId <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Keine Field-Owner-ID verfügbar.')),
                          );
                          return;
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FieldOwnerDetailsPage(owner: user),
                          ),
                        ).then((result) {
                          if (result == true) {
                            _fetchAllUsers();
                          }
                        });
                      },
                    );
                  },
                ),
    );
  }
}

class FieldOwnerDetailsPage extends StatefulWidget {
  final FieldOwner owner;

  const FieldOwnerDetailsPage({super.key, required this.owner});

  @override
  State<FieldOwnerDetailsPage> createState() => _FieldOwnerDetailsPageState();
}

class _FieldOwnerDetailsPageState extends State<FieldOwnerDetailsPage> {
  static const Color _primaryColor = Color.fromARGB(255, 41, 107, 43);
  Map<String, dynamic>? _userInfo;
  List<Map<String, dynamic>> _fields = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.wait([
        _fetchOwnerInfo(),
        _fetchOwnerFields(),
      ]);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchOwnerInfo() async {
    final url = Uri.parse('$ipAddress/get_profile.php');
    final response = await http.post(
      url,
      body: {'username': widget.owner.name},
    );

    if (response.body.trim().isEmpty) {
      throw Exception('Leere Server-Antwort (get_profile.php).');
    }
    final Map<String, dynamic> data = json.decode(response.body);
    if (data['success'] == true) {
      _userInfo = Map<String, dynamic>.from(data['user']);
    } else {
      throw Exception(data['message'] ?? 'Benutzerinfos nicht gefunden.');
    }
  }

  Future<void> _fetchOwnerFields() async {
    final url = Uri.parse('$ipAddress/fetch_fields_by_owner_id.php');
    final response = await http.post(
      url,
      body: {'field_owner_id': widget.owner.userId.toString()},
    );

    if (response.body.trim().isEmpty) {
      throw Exception('Leere Server-Antwort (fetch_fields_by_owner_id.php).');
    }
    final Map<String, dynamic> data = json.decode(response.body);
    if (data['success'] == true) {
      final rawFields = (data['fields'] as List?) ?? [];
      _fields = rawFields
          .map((f) => Map<String, dynamic>.from(f as Map))
          .toList();
    } else {
      _fields = [];
    }
  }

  Future<bool> _removeFieldOwner() async {
    final url = Uri.parse('$ipAddress/remove_field_owner.php');
    try {
      final response = await http.post(url, body: {'field_owner_id': widget.owner.userId.toString()});
      if (response.body.trim().isEmpty) {
        throw Exception('Leere Server-Antwort (remove_field_owner.php).');
      }
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Fieldowner entfernt.')),
          );
        }
        return true;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Entfernen fehlgeschlagen.')),
        );
      }
      return false;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verbindungsfehler: $e')),
        );
      }
      return false;
    }
  }

  Future<void> _confirmRemoveFieldOwner() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Fieldowner entfernen'),
        content: Text('Möchtest du "${widget.owner.name}" wirklich entfernen?\nDie Felder werden auf "Abgelehnt" gesetzt.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Entfernen', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      final success = await _removeFieldOwner();
      if (success && mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  Color _colorFromHint(String? hint) {
    switch ((hint ?? '').toLowerCase()) {
      case 'gruen':
      case 'grün':
      case 'green':
        return Colors.green;
      case 'gelb':
      case 'yellow':
        return Colors.orange;
      case 'rot':
      case 'red':
        return Colors.red;
      case 'grau':
      case 'grey':
      case 'gray':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  int _intFrom(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? fallback;
  }

  Fields _toAdminField(Map<String, dynamic> field) {
    return Fields(
      id: _intFrom(field['id']),
      fieldname: field['fieldname']?.toString() ?? 'Unbenannt',
      description: field['description']?.toString(),
      rules: field['rules']?.toString(),
      street: field['street']?.toString(),
      housenumber: field['housenumber']?.toString(),
      postalcode: field['postalcode']?.toString(),
      city: field['city']?.toString(),
      company: field['company']?.toString(),
      fieldOwnerId: widget.owner.userId,
      checkstate: _intFrom(field['checkstate_id'] ?? field['checkstate']),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value.isNotEmpty ? value : 'Nicht angegeben')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = _userInfo ?? {};
    final username = widget.owner.name;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          username,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
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
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard('Profil', [
                        _buildInfoRow('Username', username),
                        _buildInfoRow('Mitglied seit', userInfo['memberSince']?.toString() ?? ''),
                        _buildInfoRow('Team', userInfo['team']?.toString() ?? ''),
                        _buildInfoRow('Teamrolle', userInfo['ingamerole']?.toString() ?? ''),
                      ]),
                      _buildInfoCard('Kontakt', [
                        _buildInfoRow('E-Mail', userInfo['email']?.toString() ?? ''),
                        _buildInfoRow('Stadt', userInfo['city']?.toString() ?? ''),
                      ]),
                      _buildInfoCard('Felder', [
                        Text(
                          'Gesamt: ${_fields.length}',
                          style: const TextStyle(fontWeight: FontWeight.w600, color: _primaryColor),
                        ),
                        const SizedBox(height: 12),
                        if (_fields.isEmpty)
                          const Text('Keine Felder gefunden.')
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _fields.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final field = _fields[index];
                              final statusName = field['checkstatename']?.toString() ?? 'Unbekannt';
                              final colorHint = field['color_hint']?.toString();
                              return Card(
                                elevation: 1,
                                child: ListTile(
                                  title: Text(field['fieldname']?.toString() ?? 'Unbenannt'),
                                  subtitle: Text(field['city']?.toString() ?? ''),
                                  leading: CircleAvatar(
                                    backgroundColor: _colorFromHint(colorHint),
                                    child: const Icon(Icons.place, color: Colors.white, size: 18),
                                  ),
                                  trailing: Text(statusName),
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(
                                          MaterialPageRoute(
                                            builder: (_) => FieldReviewPage(field: _toAdminField(field)),
                                          ),
                                        )
                                        .then((_) => _fetchOwnerFields());
                                  },
                                ),
                              );
                            },
                          ),
                      ]),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _confirmRemoveFieldOwner,
                          icon: const Icon(Icons.delete_forever, color: Colors.white),
                          label: const Text('Fieldowner entfernen', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}