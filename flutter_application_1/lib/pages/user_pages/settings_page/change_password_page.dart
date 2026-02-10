import 'package:http/http.dart' as http;
import 'package:pewpew_connect/service/imports.dart';

class ChangePasswordPage extends StatefulWidget {
  final String username;

  const ChangePasswordPage({super.key, required this.username});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final current = _currentController.text.trim();
    final nw = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    if (current.isEmpty || nw.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bitte alle Felder ausfüllen.')));
      return;
    }
    if (nw.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Das neue Passwort muss mindestens 6 Zeichen haben.')));
      return;
    }
    if (nw != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwörter stimmen nicht überein.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$ipAddress/change_password.php'),
        body: {
          'username': widget.username,
          'current_password': current,
          'new_password': nw,
        },
      );
      if (!mounted) return;
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Passwort geändert')));
        // clear force change flag in app state
        Provider.of<AppState>(context, listen: false).setForcePasswordChange(false);
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Fehler')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verbindungsfehler: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Passwort ändern')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _currentController, obscureText: true, decoration: const InputDecoration(labelText: 'Aktuelles Passwort')),
            const SizedBox(height: 12),
            TextField(controller: _newController, obscureText: true, decoration: const InputDecoration(labelText: 'Neues Passwort')),
            const SizedBox(height: 12),
            TextField(controller: _confirmController, obscureText: true, decoration: const InputDecoration(labelText: 'Neues Passwort bestätigen')),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Ändern'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
