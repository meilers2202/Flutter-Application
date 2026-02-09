import 'package:flutter/material.dart';
import 'package:pewpew_connect/service/notification_service.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const SettingsPage({
    super.key,
    required this.toggleTheme,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = false;
  bool _loadingNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationState();
  }

  Future<void> _loadNotificationState() async {
    final enabled = await NotificationService.instance.isEnabled();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = enabled;
      _loadingNotifications = false;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _loadingNotifications = true);
    final enabled = await NotificationService.instance.setEnabled(value);
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = enabled;
      _loadingNotifications = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enabled
              ? 'Benachrichtigungen aktiviert.'
              : 'Benachrichtigungen deaktiviert oder blockiert.',
        ),
      ),
    );
  }

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
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        
        child: ListView(
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
                  widget.toggleTheme();
                },
              ),
            ),
            const Divider(),
            SwitchListTile(
              title: Text(
                'Benachrichtigungen',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              secondary: Icon(
                Icons.notifications,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              value: _notificationsEnabled,
              onChanged: _loadingNotifications ? null : _toggleNotifications,
            ),
          ],
        ),
      ),
    );
  }
}