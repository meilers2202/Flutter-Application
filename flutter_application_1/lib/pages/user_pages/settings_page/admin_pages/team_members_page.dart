import 'package:http/http.dart' as http;
import 'package:pewpew_connect/service/imports.dart';
import 'package:pewpew_connect/pages/user_pages/main_page/user_profile_page.dart';

class TeamMembersPage extends StatefulWidget {
  final String teamName;
  const TeamMembersPage({super.key, required this.teamName});

  @override
  State<TeamMembersPage> createState() => _TeamMembersPageState();
}

class _TeamMembersPageState extends State<TeamMembersPage> {
  List<String> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeamMembers();
  }

  Future<void> _fetchTeamMembers() async {
    final url = Uri.parse('$ipAddress/get_team_members.php');
    try {
      final response = await http.post(url, body: {'teamName': widget.teamName});
      final data = json.decode(response.body);

      if (data['success'] == true) {
        if (mounted) {
          setState(() {
            _members = List<String>.from(data['members']);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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
        title: Text(
          widget.teamName,
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
          : _members.isEmpty
              ? const Center(child: Text('Keine Mitglieder gefunden.'))
              : ListView.builder(
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    final member = _members[index];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(member),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => UserProfilePage(username: member)),
                        );
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _confirmRemoveMember(member),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _confirmRemoveMember(String member) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mitglied entfernen'),
        content: Text('Möchtest du $member wirklich aus dem Team "${widget.teamName}" entfernen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Entfernen')),
        ],
      ),
    );

    if (confirm == true) {
      await _removeMember(member);
    }
  }

  Future<void> _removeMember(String member) async {
    final url = Uri.parse('$ipAddress/leave_team.php');
    try {
      final response = await http.post(url, body: {'username': member});
      final data = json.decode(response.body);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Keine Antwort vom Server')));
      if (data['success'] == true) {
        await _fetchTeamMembers();
        // Inform caller that something changed
        //Navigator.pop(context, 'updated');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler beim Entfernen: $e')));
    }
  }
}
