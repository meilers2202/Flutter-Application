import 'package:http/http.dart' as http;
import 'package:pewpew_connect/service/imports.dart';

class UserProfilePage extends StatefulWidget {
  final String username;
  const UserProfilePage({super.key, required this.username});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _user;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final url = Uri.parse('$ipAddress/get_profile.php');
    try {
      final response = await http.post(url, body: {'username': widget.username}).timeout(const Duration(seconds: 10));
      final body = response.body.trim();
      if (response.statusCode != 200 || body.isEmpty) {
        setState(() {
          _error = 'Fehler beim Laden des Profils.';
          _isLoading = false;
        });
        return;
      }

      final data = json.decode(body);
      if (data['success'] == true) {
        setState(() {
          _user = Map<String, dynamic>.from(data['user']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = data['message'] ?? 'Benutzer nicht gefunden.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Verbindungsfehler: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildProfile(),
    );
  }

  Widget _buildProfile() {
    final profileUrl = _user?['profile_image_url'] as String?;
    final displayName = _user?['username'] ?? widget.username;
    final memberSince = _user?['memberSince'] ?? _user?['created_at'] ?? '';
    final team = _user?['team'] ?? '—';
    final teamrole = _user?['teamrole'] ?? _user?['role'] ?? '';
    final city = _user?['city'] ?? '—';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 54,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: profileUrl != null && profileUrl.isNotEmpty ? NetworkImage(profileUrl) : null,
            child: (profileUrl == null || profileUrl.isEmpty) ? const Icon(Icons.person, size: 54) : null,
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 6),
              Text('Mitglied seit: $memberSince'),
            ],
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Team'),
            subtitle: Text(team),
            trailing: Text(teamrole ?? ''),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Standort'),
            subtitle: Text(city),
          ),
          const Divider(),
          if (_user?['email'] != null)
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('E-Mail'),
              subtitle: Text(_user!['email']),
            ),
          if (_user?['ingamerole'] != null)
            ListTile(
              leading: const Icon(Icons.shield),
              title: const Text('Ingame Rolle'),
              subtitle: Text(_user!['ingamerole']),
            ),
        ],
      ),
    );
  }
}
