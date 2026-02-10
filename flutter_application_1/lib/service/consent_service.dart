import 'package:pewpew_connect/service/imports.dart';

class ConsentService {
  ConsentService._();

  static final ConsentService instance = ConsentService._();

  static const _keyAllowed = 'analytics_enabled';
  static const _keyAsked = 'analytics_consent_asked';

  bool _promptInProgress = false;

  Future<bool> isAllowed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAllowed) ?? false;
  }

  Future<bool> wasAsked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAsked) ?? false;
  }

  Future<void> setConsent(bool allowed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAsked, true);
    await prefs.setBool(_keyAllowed, allowed);
  }

  Future<void> maybePrompt(BuildContext context) async {
    if (_promptInProgress) return;
    final asked = await wasAsked();
    if (asked) return;
    if (!context.mounted) return;

    _promptInProgress = true;
    final allow = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Diagnose & Analyse'),
        content: const Text(
          'Moeglich sind anonyme Fehlerberichte und Nutzungsstatistiken, um die App zu verbessern. Zulassen?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Ablehnen')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Zulassen')),
        ],
      ),
    );

    await setConsent(allow == true);
    _promptInProgress = false;
  }
}
