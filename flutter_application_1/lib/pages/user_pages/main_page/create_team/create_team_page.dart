import 'package:pewpew_connect/service/imports.dart';

class CreateTeamPage extends StatefulWidget {
  final UserService userService;

  const CreateTeamPage({super.key, required this.userService});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final TextEditingController _teamNameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createTeam() async {
    final newTeamName = _teamNameController.text.trim();
    if (newTeamName.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final result = await widget.userService.createTeam(newTeamName);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );

      if (result['success'] == true) {
        Navigator.of(context).pop(newTeamName); // Name des neuen Teams zurückgeben
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Team erstellen',
          style: TextStyle(
            color: Colors.white,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _teamNameController,
              decoration: const InputDecoration(
                hintText: 'Teamname eingeben',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _createTeam,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Erstellen'),
            ),
          ],
        ),
      ),
    );
  }
}
