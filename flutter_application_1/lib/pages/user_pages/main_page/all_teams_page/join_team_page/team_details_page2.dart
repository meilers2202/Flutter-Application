import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pewpew_connect/service/constants.dart';

class TeamDetailsPage2 extends StatefulWidget {
  final String teamName;
  final String currentUsername;
  final String? userCurrentTeam;

  const TeamDetailsPage2({
    super.key,
    required this.teamName,
    required this.currentUsername,
    this.userCurrentTeam,
  });

  @override
  State<TeamDetailsPage2> createState() => _TeamDetailsPage2State();
}

class _TeamDetailsPage2State extends State<TeamDetailsPage2> {
  bool _isLoading = true;
  List<String> _members = [];

  @override
  void initState() {
    super.initState();
    _fetchTeamMembers();
  }

  Future<void> _fetchTeamMembers() async {
    setState(() => _isLoading = true);

    final url = Uri.parse('$ipAddress/get_team_members.php');
    try {
      final response = await http.post(url, body: {
        'teamName': widget.teamName,
      });

      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        final List<dynamic> membersData = data['members'] ?? [];
        setState(() {
          _members = membersData.map((e) => e.toString()).toList();
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Fehler beim Laden')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verbindungsfehler: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAlreadyMember = widget.userCurrentTeam == widget.teamName;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.teamName,
          style: const TextStyle(
              color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
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
          : RefreshIndicator(
              onRefresh: _fetchTeamMembers,
              child: _members.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              'Mitglieder (${_members.length})',
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const Icon(Icons.group_off,
                                size: 80, color: Colors.grey),
                            const Text(
                              'Noch keine Mitglieder vorhanden.',
                              textAlign: TextAlign.center, // 🔥 sorgt für horizontales Zentrieren
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton.icon(
                              onPressed: isAlreadyMember
                                  ? null
                                  : () async {
                                      final result =
                                          await Navigator.of(context)
                                              .pushNamed('/joinTeam', arguments: {
                                        'teamName': widget.teamName,
                                        'currentUsername':
                                            widget.currentUsername,
                                        'userCurrentTeam':
                                            widget.userCurrentTeam,
                                      });

                                      if (result != null && result is String) {
                                        Navigator.pop(context, result);
                                      }
                                    },
                              icon: const Icon(Icons.group_add,
                                  color: Colors.white),
                              label: Text(
                                isAlreadyMember
                                    ? 'Bereits Mitglied'
                                    : 'Team beitreten',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isAlreadyMember
                                    ? Colors.grey
                                    : Color.fromARGB(255, 41, 107, 43),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            'Mitglieder (${_members.length})',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _members.length,
                            itemBuilder: (context, index) {
                              final member = _members[index];
                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  leading: const Icon(Icons.person,
                                      color: Color.fromARGB(255, 41, 107, 43)),
                                  title: Text(member),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton.icon(
                            onPressed: isAlreadyMember
                                ? null
                                : () async {
                                    final result = await Navigator.of(context)
                                        .pushNamed('/joinTeam', arguments: {
                                      'teamName': widget.teamName,
                                      'currentUsername':
                                          widget.currentUsername,
                                      'userCurrentTeam':
                                          widget.userCurrentTeam,
                                    });

                                    if (result != null && result is String) {
                                      Navigator.pop(context, result);
                                    }
                                  },
                            icon: const Icon(Icons.group_add,
                                color: Colors.white),
                            label: Text(
                              isAlreadyMember
                                  ? 'Bereits Mitglied'
                                  : 'Team beitreten',
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAlreadyMember
                                  ? Colors.grey
                                  : Color.fromARGB(255, 41, 107, 43),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
    );
  }
}