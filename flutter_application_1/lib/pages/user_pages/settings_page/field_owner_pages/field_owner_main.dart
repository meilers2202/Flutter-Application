import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String ipAddress = 'localhost';

// Ein Modell für die Felddaten zur besseren Strukturierung
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
  final String checkstateColor; // NEU: Feld für die Farbe

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
    required this.checkstateColor, // NEU
  });

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: int.parse(json['id'].toString()),
      fieldname: json['fieldname'] as String,
      description: json['description'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      company: json['company'] as String,
      housenumber: json['housenumber'] as String,
      postalcode: json['postalcode'] as String,
      rules: json['rules'] as String,
      checkstatename: json['checkstatename'] as String, 
      checkstateColor: json['color_hint'] as String,    // Abruf der Farbe
    );
  }
}

class FieldOwnerMainPage extends StatefulWidget {
  // NEU: Wir benötigen den Benutzernamen, um die ID abzurufen
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

  // HIER IST DIE FUNKTION KORREKT PLATZIERT
  Color _getColorForStatus(String colorHint) {
    switch (colorHint.toLowerCase()) {
      case 'grau':
        return Colors.grey; 
      case 'grün':
        return Colors.green;
      case 'gelb':
        return Colors.yellow[700]!; // Ein etwas dunkleres Gelb
      case 'rot':
        return Colors.red;
      default:
        return Colors.transparent;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAndLoadFields();
  }

  // --- Schritt 1 & 2: ID abrufen und Felder laden ---
  Future<void> _fetchAndLoadFields() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Benutzer-ID anhand des Benutzernamens abrufen
      final userId = await _fetchUserId(widget.currentUsername);

      if (userId == null) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Benutzer-ID konnte nicht abgerufen werden.';
            _isLoading = false;
          });
        }
        return;
      }

      // 2. Felder für die abgerufene ID laden
      await _fetchFields(userId);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Ein Fehler ist aufgetreten: $e';
          _isLoading = false;
        });
      }
    }
  }

  // Hilfsmethode, um die Benutzer-ID vom Server abzurufen
  Future<int?> _fetchUserId(String username) async {
    final url = Uri.parse('http://$ipAddress/get_user_id_by_username.php');
    final response = await http.post(
      url,
      body: {'username': username},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true && data.containsKey('userId')) {
        return int.parse(data['userId'].toString());
      } else {
        throw Exception(data['message'] ?? 'Benutzer nicht gefunden.');
      }
    }
    return null;
  }

  // Hilfsmethode, um die Felder anhand der Field Owner ID abzurufen
  Future<void> _fetchFields(int fieldOwnerId) async {
    final url = Uri.parse('http://$ipAddress/fetch_fields_by_owner_id.php');
    final response = await http.post(
      url,
      body: {'field_owner_id': fieldOwnerId.toString()},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        final List<Field> loadedFields = (data['fields'] as List)
            .map((json) => Field.fromJson(json))
            .toList();

        if (mounted) {
          setState(() {
            _fields = loadedFields;
            _isLoading = false;
          });
        }
      } else {
        throw Exception(data['message'] ?? 'Fehler beim Laden der Felder.');
      }
    } else {
      throw Exception('Serverfehler beim Laden der Felder: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meine Felder',
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
      body: Column(
        children: [
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamed('/fieldcreate')
                  .then((_) => _fetchAndLoadFields()); // Felder neu laden, wenn wir zurückkommen
            },
            child: const Text(
              "Feld hinzufügen",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 5),
          // NEU: Conditional Rendering basierend auf dem Ladezustand
          Expanded(
            child: _buildBody(),
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
        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
      );
    }

    if (_fields.isEmpty) {
      return const Center(
        child: Text('Sie haben noch keine Felder hinzugefügt.'),
      );
    }

    // NEU: Anzeige der Felder
    return ListView.builder(
      itemCount: _fields.length,
      itemBuilder: (context, index) {
        final field = _fields[index];
        
        // Die Card ist jetzt das äußerste Widget, das den Platz inklusive Margin belegt
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          
          // NEU: Stack füllt die Card aus und positioniert den Balken
          child: Stack(
            children: [
              // 1. Das ListTile füllt den gesamten verfügbaren Platz im Stack
              ListTile(
                leading: const Icon(Icons.grass),
                title: Text(field.fieldname, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${field.company}\n${field.street} ${field.housenumber}\n${field.postalcode}, ${field.city}\nStatus: ${field.checkstatename}'
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/fielddetails',
                    arguments: field,
                  );
                },
              ),
              
              // 2. Der farbige Balken (Positioned am rechten Rand der Card)
              Positioned(
                // Top und Bottom werden nicht mehr auf 5 gesetzt, da der Stack
                // die gesamte Höhe des ListTile übernimmt. Wir nutzen nur die right-Position.
                top: 0, 
                bottom: 0, 
                right: 0.5, // An den rechten Rand der Card legen
                child: Container(
                  width: 7, // Breite des Balkens
                  color: _getColorForStatus(field.checkstateColor), 
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}