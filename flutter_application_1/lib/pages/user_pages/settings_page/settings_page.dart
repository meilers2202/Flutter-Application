import 'package:pewpew_connect/service/imports.dart';

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
  bool _analyticsEnabled = false;
  bool _loadingAnalytics = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationState();
    _loadAnalyticsState();
  }

  Future<void> _loadNotificationState() async {
    final enabled = await NotificationService.instance.isEnabled();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = enabled;
      _loadingNotifications = false;
    });
  }

  Future<void> _loadAnalyticsState() async {
    final enabled = await ConsentService.instance.isAllowed();
    if (!mounted) return;
    setState(() {
      _analyticsEnabled = enabled;
      _loadingAnalytics = false;
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

  Future<void> _toggleAnalytics(bool value) async {
    setState(() => _loadingAnalytics = true);
    await ConsentService.instance.setConsent(value);
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(value);
    await AnalyticsService.instance.setCollectionEnabled(value);
    await PerformanceService.instance.setCollectionEnabled(value);

    if (!mounted) return;
    setState(() {
      _analyticsEnabled = value;
      _loadingAnalytics = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Diagnose & Analyse aktiviert.'
              : 'Diagnose & Analyse deaktiviert.',
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
            const Divider(),
            SwitchListTile(
              title: Text(
                'Diagnose & Analyse',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: const Text('Hilft bei Stabilitaet und Performance.'),
              secondary: Icon(
                Icons.analytics,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              value: _analyticsEnabled,
              onChanged: _loadingAnalytics ? null : _toggleAnalytics,
            ),
          ],
        ),
      ),
    );
  }
}