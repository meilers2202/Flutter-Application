import 'package:flutter/material.dart';

// SettingsPage ist jetzt ein StatelessWidget, da die Zustandsverwaltung von MyApp übernommen wird
class SettingsPage extends StatelessWidget {
  final VoidCallback toggleTheme;

  const SettingsPage({
    super.key,
    required this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Einstellungen',
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
      body: ListView(
        children: [
          ListTile(
            title: Text(
              'Dunkler Modus',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            leading: Icon(
              Icons.dark_mode,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            trailing: Switch(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (bool value) {
                // Diese Funktion ändert den Anzeigemodus
                toggleTheme();
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(
              'Benachrichtigungen',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            leading: Icon(
              Icons.notifications,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Benachrichtigungseinstellungen geöffnet'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}