import 'package:http/http.dart' as http;
import 'package:pewpew_connect/service/imports.dart';

class Field {
  final int id;
  final String fieldname;
  final String description;
  final String street;
  final String city;
  final String company;
  final String housenumber;
  final String postalcode;
  final String rules;
  final String checkstatename;
  final String checkstateColor;

  Field({
    required this.id,
    required this.fieldname,
    required this.description,
    required this.street,
    required this.city,
    required this.company,
    required this.housenumber,
    required this.postalcode,
    required this.rules,
    required this.checkstatename,
    required this.checkstateColor,
  });

  factory Field.fromJson(Map<String, dynamic> json) {
    // Sichereres Parsing, falls Werte null sind oder Typen variieren
    return Field(
      id: int.tryParse(json['id'].toString()) ?? 0,
      fieldname: json['fieldname']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      street: json['street']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      housenumber: json['housenumber']?.toString() ?? '',
      postalcode: json['postalcode']?.toString() ?? '',
      rules: json['rules']?.toString() ?? '',
      checkstatename: json['checkstatename']?.toString() ?? 'Unbekannt',
      checkstateColor: json['color_hint']?.toString() ?? 'grau',
    );
  }
}

class FieldOwnerMainPage extends StatefulWidget {
  final String currentUsername;

  const FieldOwnerMainPage({
    super.key,
    required this.currentUsername,
  });

  @override
  State<FieldOwnerMainPage> createState() => _FieldOwnerMainPageState();
}

class _FieldOwnerMainPageState extends State<FieldOwnerMainPage> {
  List<Field> _fields = [];
  bool _isLoading = true;
  String? _errorMessage;

  Color _getColorForStatus(String colorHint) {
    switch (colorHint.toLowerCase()) {
      case 'grau':
        return Colors.grey;
      case 'grün':
      case 'green':
        return Colors.green;
      case 'gelb':
      case 'yellow':
        return Colors.yellow[700]!;
      case 'rot':
      case 'red':
        return Colors.red;
      default:
        return Colors.grey; // Fallback statt transparent für bessere Sichtbarkeit
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAndLoadFields();
  }

  Future<void> _fetchAndLoadFields() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = await _fetchUserId(widget.currentUsername);

      if (userId == null) {
        throw Exception('Benutzer-ID konnte nicht abgerufen werden.');
      }

      await _fetchFields(userId);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<int?> _fetchUserId(String username) async {
    final url = Uri.parse('$ipAddress/get_user_id_by_username.php');
    final response = await http.post(
      url,
      body: {'username': username},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true && data.containsKey('userId')) {
        return int.tryParse(data['userId'].toString());
      } else {
        throw Exception(data['message'] ?? 'Benutzer nicht gefunden.');
      }
    }
    throw Exception('Verbindungsfehler: ${response.statusCode}');
  }

  Future<void> _fetchFields(int fieldOwnerId) async {
    final url = Uri.parse('$ipAddress/fetch_fields_by_owner_id.php');
    final response = await http.post(
      url,
      body: {'field_owner_id': fieldOwnerId.toString()},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        final List<dynamic> fieldsData = data['fields'] ?? [];
        final List<Field> loadedFields = fieldsData
            .map((json) => Field.fromJson(json))
            .toList();

        if (mounted) {
          setState(() {
            _fields = loadedFields;
          });
        }
      } else {
        // Falls Erfolg false ist, aber die Liste nur leer war, kein Fehler werfen
        if (mounted) {
          setState(() => _fields = []);
        }
      }
    } else {
      throw Exception('Serverfehler: ${response.statusCode}');
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('stayLoggedIn2');
    await prefs.remove('fieldOwnerUsername');

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/main', (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meine Felder',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed('/fieldcreate')
                      .then((_) => _fetchAndLoadFields());
                },
                label: const Text(
                  "Feld hinzufügen",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchAndLoadFields,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _fetchAndLoadFields, child: const Text("Erneut versuchen"))
            ],
          ),
        ),
      );
    }

    if (_fields.isEmpty) {
      return const Center(
        child: Text('Sie haben noch keine Felder hinzugefügt.'),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(), // Wichtig für RefreshIndicator
      itemCount: _fields.length,
      itemBuilder: (context, index) {
        final field = _fields[index];
        return Card(
          clipBehavior: Clip.antiAlias, // Sorgt dafür, dass der Status-Balken sauber abschließt
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: InkWell( // Bessere visuelle Rückmeldung beim Tippen
            onTap: () {
              Navigator.of(context)
                .pushNamed('/fielddetails', arguments: field)
                .then((result) {
                  if (result == true) _fetchAndLoadFields();
                });
            },
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(field.fieldname, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(field.company, style: const TextStyle(fontStyle: FontStyle.italic)),
                          Text('${field.street} ${field.housenumber}'),
                          Text('${field.postalcode} ${field.city}'),
                          const Divider(),
                          Text('Status: ${field.checkstatename}', 
                               style: TextStyle(color: _getColorForStatus(field.checkstateColor), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 8,
                    color: _getColorForStatus(field.checkstateColor),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}