import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  // Variablen als finale Felder definieren
  final String? username;
  final String? email;
  final String? city;
  final String? team;
  final String? memberSince;

  const ProfilePage({
    super.key,
    this.username,
    this.email,
    this.city,
    this.team,
    this.memberSince,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
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
      body: Stack(
        children: [
          // Hintergrundbild mit Deckkraft
          Positioned.fill(
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/images/app_bgr.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Der ursprüngliche Profil-Inhalt
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // CircleAvatar mit Bild und Opacity
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
                  const SizedBox(height: 24),
                  Text(
                    username ?? 'Gast',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mitglied seit: ${memberSince ?? 'Unbekannt'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.groups),
                            title: Text('Team',
                                style: Theme.of(context).textTheme.bodyLarge),
                            subtitle: Text(team ?? 'Nicht verfügbar',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.email),
                            title: Text('E-Mail',
                                style: Theme.of(context).textTheme.bodyLarge),
                            subtitle: Text(email ?? 'Nicht verfügbar',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text('Standort',
                                style: Theme.of(context).textTheme.bodyLarge),
                            subtitle: Text(city ?? 'Nicht verfügbar',
                                style: Theme.of(context).textTheme.bodyMedium),
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