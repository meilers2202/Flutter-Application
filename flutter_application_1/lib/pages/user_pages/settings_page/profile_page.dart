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
  static const Color _primaryColor = Color.fromARGB(255, 41, 107, 43);
  String? email;
  String? city;
  String? team;
  String? memberSince;
  String? teamrole;
  String? ingamerole;
  int? ingameroleId;
  List<Map<String, dynamic>> _availableRoles = [];
  bool _rolesLoading = true;
  String? profileImageUrl;
  bool _isLoading = true;

  // Cache-Buster, um das Bild bei Aktualisierung neu zu laden
  int _cacheBusterKey = (DateTime.now().millisecondsSinceEpoch ~/ 5000);

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _loadAvailableRoles();
  }

  Widget _buildProfileCard(ThemeData theme) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, bottomInset + 24.0),
      child: Column(
        children: [
          const SizedBox(height: 100),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profilbild (zentriert)
                    Center(
                      child: Stack(
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
                                          "$profileImageUrl?v=$_cacheBusterKey",
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                    : null,
                                                color: _primaryColor,
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
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            widget.username ?? 'Gast',
                            style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22),
                          ),
                          const SizedBox(height: 4),
                          Text("Mitglied seit: ${memberSince ?? 'Unbekannt'}", style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 40),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.groups, color: _primaryColor),
                      title: const Text('Team Info', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Team: ${team ?? "Kein"}'),
                          Text('Pos: ${teamrole ?? "N/A"}'),
                          Row(
                            children: [
                              Text('Rang: ${ingamerole ?? "N/A"}'),
                              const SizedBox(width: 6), // Etwas mehr Abstand für das größere Icon
                              GestureDetector(
                                behavior: HitTestBehavior.opaque, // Vergrößert die Trefferfläche
                                onTap: _rolesLoading ? null : () => _showRoleEditDialog(),
                                child: Icon(
                                  Icons.edit,
                                  color: _primaryColor,
                                  size: 22, // Die gewünschte mittlere Größe
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.email, color: _primaryColor),
                      title: const Text('E-Mail', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        email ?? 'Nicht verfügbar',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                      trailing: SizedBox(
                        width: 36,
                        height: 36,
                        child: IconButton(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                          icon: Icon(Icons.edit, color: _primaryColor, size: 20),
                          onPressed: () => _showEditEmailDialog(),
                        ),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.location_on, color: _primaryColor),
                      title: const Text('Standort', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        city ?? 'Nicht verfügbar',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                      trailing: SizedBox(
                        width: 36,
                        height: 36,
                        child: IconButton(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                          icon: Icon(Icons.edit, color: _primaryColor, size: 20),
                          onPressed: () => _showEditCityDialog(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (widget.username != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => ChangePasswordPage(username: widget.username!)),
                            );
                          }
                        },
                        icon: const Icon(Icons.vpn_key, color: Colors.white),
                        label: const Text('Passwort ändern', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
                      ),
                    ),
                  ],

                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _loadAvailableRoles() async {
    setState(() => _rolesLoading = true);
    try {
      final resp = await http.get(Uri.parse('$ipAddress/get_ingameroles.php'));
      final data = json.decode(resp.body);
      if (data['success'] == true) {
        setState(() {
          _availableRoles = List<Map<String, dynamic>>.from(data['roles']);
          _rolesLoading = false;
        });
      } else {
        setState(() => _rolesLoading = false);
      }
    } catch (e) {
      setState(() => _rolesLoading = false);
    }
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
          ingameroleId = data['user']['ingamerole_id'] is int ? data['user']['ingamerole_id'] : (data['user']['ingamerole_id'] != null ? int.tryParse(data['user']['ingamerole_id'].toString()) : null);
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
        backgroundColor: isError ? Colors.red : _primaryColor,
      ),
    );
  }

  Future<void> _updateIngameRole(int newRoleId) async {
    if (widget.username == null) return;
    try {
      final response = await http.post(
        Uri.parse('$ipAddress/update_ingamerole.php'),
        body: {'username': widget.username!, 'ingamerole_id': newRoleId.toString()},
      );
      final data = json.decode(response.body);
      if (data['success'] == true) {
        setState(() {
          ingameroleId = newRoleId;
          // update displayed name from available roles
          final match = _availableRoles.firstWhere((r) => (r['id'] is int ? r['id'] : int.parse(r['id'].toString())) == newRoleId, orElse: () => {});
          if (match.isNotEmpty) ingamerole = match['name'];
        });
        _showSnackBar(data['message'] ?? 'Rang aktualisiert');
      } else {
        _showSnackBar(data['message'] ?? 'Fehler beim Aktualisieren', isError: true);
      }
    } catch (e) {
      _showSnackBar('Verbindungsfehler: $e', isError: true);
    }
  }

  Future<void> _showEditEmailDialog() async {
    if (widget.username == null) return;
    final formKey = GlobalKey<FormState>();
    String? newEmail;
    String? currentPassword;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('E-Mail ändern'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: email,
                decoration: const InputDecoration(labelText: 'Neue E-Mail'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Bitte E-Mail eingeben';
                  final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
                  if (!emailRegex.hasMatch(v)) return 'Ungültige E-Mail';
                  return null;
                },
                onSaved: (v) => newEmail = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Aktuelles Passwort'),
                obscureText: true,
                validator: (v) => (v == null || v.isEmpty) ? 'Passwort erforderlich' : null,
                onSaved: (v) => currentPassword = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                Navigator.pop(ctx, true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            child: const Text('Speichern', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true && newEmail != null && currentPassword != null) {
      try {
        final resp = await http.post(Uri.parse('$ipAddress/change_email.php'), body: {
          'username': widget.username!,
          'current_password': currentPassword!,
          'new_email': newEmail!,
        });
        final data = json.decode(resp.body);
        if (data['success'] == true) {
          setState(() => email = newEmail);
          _showSnackBar(data['message'] ?? 'E-Mail aktualisiert');
        } else {
          _showSnackBar(data['message'] ?? 'Fehler beim Aktualisieren', isError: true);
        }
      } catch (e) {
        _showSnackBar('Verbindungsfehler: $e', isError: true);
      }
    }
  }

  Future<void> _showEditCityDialog() async {
    if (widget.username == null) return;
    final formKey = GlobalKey<FormState>();
    String? newCity;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Standort ändern'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: city,
                decoration: const InputDecoration(labelText: 'Neuer Standort'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Bitte Standort eingeben';
                  return null;
                },
                onSaved: (v) => newCity = v?.trim(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                Navigator.pop(ctx, true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            child: const Text('Speichern', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true && newCity != null) {
      try {
        final resp = await http.post(Uri.parse('$ipAddress/change_city.php'), body: {
          'username': widget.username!,
          'new_city': newCity!,
        });
        final data = json.decode(resp.body);
        if (data['success'] == true) {
          setState(() => city = newCity);
          _showSnackBar(data['message'] ?? 'Standort aktualisiert');
        } else {
          _showSnackBar(data['message'] ?? 'Fehler beim Aktualisieren', isError: true);
        }
      } catch (e) {
        _showSnackBar('Verbindungsfehler: $e', isError: true);
      }
    }
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
            : Center(child: _buildProfileCard(theme)),
        ],
      ),
    );
  }

  Future<void> _showRoleEditDialog() async {
    if (_rolesLoading) return;
    int? selected = ingameroleId;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rang ändern'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return DropdownButtonFormField<int>(
              initialValue: selected,
              items: _availableRoles
                  .map((r) => DropdownMenuItem<int>(value: r['id'] is int ? r['id'] : int.parse(r['id'].toString()), child: Text(r['name'])))
                  .toList(),
              onChanged: (v) => setState(() => selected = v),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Abbrechen')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Speichern')),
        ],
      ),
    );
    if (result == true && selected != null && selected != ingameroleId) {
      await _updateIngameRole(selected!);
    }
  }
}