import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pewpew_connect/service/imports.dart';

class ProfilePage extends StatefulWidget {
  final String? username;
  final VoidCallback toggleTheme;

  const ProfilePage({
    super.key,
    required this.username,
    required this.toggleTheme,
  });

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
  String? profileImageUrl;
  bool _isLoading = true;

  // Cache-Buster, um das Bild bei Aktualisierung neu zu laden
  int _cacheBusterKey = (DateTime.now().millisecondsSinceEpoch ~/ 5000);

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    if (widget.username == null) {
      setState(() => _isLoading = false);
      return;
    }

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
          profileImageUrl = data['user']['profile_image_url'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        _showSnackBar('Fehler: ${data['message']}', isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Fehler beim Laden: $e', isError: true);
    }
  }

  void _navigateToImageUpload() async {
    if (widget.username == null) return;

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageUploadPage(username: widget.username!),
      ),
    );

    if (result == true) {
      setState(() {
        _cacheBusterKey = (DateTime.now().millisecondsSinceEpoch ~/ 5000);
      });
      _fetchProfileData();
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : const Color.fromARGB(255, 41, 107, 43),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profil',
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
      body: Stack(
        children: [
          // Globaler Hintergrund
          Positioned.fill(
            child: Opacity(
              opacity: 0.9,
              child: Image.asset('assets/images/app_bgr.jpg', fit: BoxFit.cover),
            ),
          ),

          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 120),
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                // PROFILBILD-BEREICH MIT LOADING-LOGIK
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 140,
                                      height: 140,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white24, width: 2),
                                      ),
                                      child: ClipOval(
                                        child: profileImageUrl != null
                                            ? Image.network(
                                                '$profileImageUrl?v=$_cacheBusterKey',
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return Center(
                                                    child: CircularProgressIndicator(
                                                      value: loadingProgress.expectedTotalBytes != null
                                                          ? loadingProgress.cumulativeBytesLoaded /
                                                              loadingProgress.expectedTotalBytes!
                                                          : null,
                                                      color: const Color.fromARGB(255, 41, 107, 43),
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Icon(Icons.person, size: 80, color: Colors.white);
                                                },
                                              )
                                            : const Icon(Icons.person, size: 80, color: Colors.white),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: InkWell(
                                        onTap: _navigateToImageUpload,
                                        child: const CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Color.fromARGB(255, 41, 107, 43),
                                          child: Icon(Icons.edit, color: Colors.white, size: 20),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                Text(
                                  widget.username ?? 'Gast', 
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontSize: 22, // Hier ist die Anpassung
                                  ),
                                ),
                                Text('Mitglied seit: ${memberSince ?? 'Unbekannt'}'),

                                const Divider(height: 40),

                                _buildDetailRow(theme, Icons.groups, 'Team Info',
                                    'Team: ${team ?? "Kein"}\nPos: ${teamrole ?? "N/A"}\nRang: ${ingamerole ?? "N/A"}'),
                                _buildDetailRow(theme, Icons.email, 'E-Mail', email ?? 'Nicht verfügbar'),
                                _buildDetailRow(theme, Icons.location_on, 'Standort', city ?? 'Nicht verfügbar'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, IconData icon, String title, String sub) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color.fromARGB(255, 41, 107, 43)),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
        ),
      ),
      subtitle: Text(
        sub,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54,
        ),
      ),
    );
  }
}