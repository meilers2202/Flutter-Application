import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pewpew_connect/service/constants.dart';

class ProfilePage extends StatefulWidget {
  final String? username;

  const ProfilePage({super.key, required this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? email;
  String? city;
  String? team;
  String? memberSince;
  String? teamrole;
  String? ingamerole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    final url = Uri.parse('$ipAddress/get_profile.php');
    try {
      final response = await http.post(
        url,
        body: {'username': widget.username},
      );

      final data = json.decode(response.body);

      if (data['success']) {
        setState(() {
          email = data['user']['email'];
          city = data['user']['city'];
          team = data['user']['team'];
          memberSince = data['user']['memberSince'];
          teamrole = data['user']['teamrole'];
          ingamerole = data['user']['ingamerole'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: ${data['message']}')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Laden der Daten: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 28, fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/app_bgr2.jpg'), fit: BoxFit.cover),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.8,
              child: Image.asset('assets/images/app_bgr.jpg', fit: BoxFit.cover),
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipOval(
                              child: Opacity(
                                opacity: 0.5,
                                child: Image.asset(
                                  'assets/images/app_bgr2.jpg',
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        Text(
                          widget.username ?? 'Gast',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Mitglied seit: ${memberSince ?? 'Unbekannt'}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 24),
                        Card(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.groups),
                                  title: Text('Team', style: Theme.of(context).textTheme.bodyLarge),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Team: ${team ?? 'Kein Team'}',
                                        style: Theme.of(context).textTheme.bodyMedium
                                      ),
                                      Text(
                                        'Position: ${teamrole ?? 'Nicht zugewiesen'}',
                                        style: Theme.of(context).textTheme.bodyMedium
                                      ),
                                      Text(
                                        'Rang: ${ingamerole ?? 'Nicht zugewiesen'}',
                                        style: Theme.of(context).textTheme.bodyMedium
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.email),
                                  title: Text('E-Mail', style: Theme.of(context).textTheme.bodyLarge),
                                  subtitle: Text(email ?? 'Nicht verfügbar', style: Theme.of(context).textTheme.bodyMedium),
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.location_on),
                                  title: Text('Standort', style: Theme.of(context).textTheme.bodyLarge),
                                  subtitle: Text(city ?? 'Nicht verfügbar', style: Theme.of(context).textTheme.bodyMedium),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}