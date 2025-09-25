import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'field_page.dart'; // Wichtig: Importiere das Fields-Model!

// Kopiere die Konstante ipAddress hierher oder mach sie global
const String ipAddress = 'localhost'; 

class FieldReviewPage extends StatefulWidget {
  final Fields field;

  const FieldReviewPage({super.key, required this.field});

  @override
  State<FieldReviewPage> createState() => _FieldReviewPageState();
}

class _FieldReviewPageState extends State<FieldReviewPage> {
  // Lokale Kopie des Feldes, um den Status aktualisieren zu können
  late Fields _currentField;

  @override
  void initState() {
    super.initState();
    _currentField = widget.field;
  }

  // Funktion zur Übersetzung des Status-Integers (übernommen aus field_page.dart)
  String _getCheckstateText(int state) {
    switch (state) {
      case 0: return 'In Prüfung';
      case 1: return 'Genehmigt';
      case 2: return 'In Klärung';
      case 3: return 'Abgelehnt';
      default: return 'Unbekannt';
    }
  }

  // Funktion, die den Status in der Datenbank ändert
  Future<void> _updateFieldStatus(int newStatus) async {
    final url = Uri.parse('http://$ipAddress/update_field_status.php');
    
    try {
      final response = await http.post(
        url,
        body: {
          'field_id': _currentField.id.toString(),
          'new_status': newStatus.toString(),
        },
      );
      
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        if (mounted) {
          // Status im lokalen Widget aktualisieren
          setState(() {
            _currentField = Fields(
              // Alle alten Daten kopieren, nur checkstate ändern
              id: _currentField.id,
              fieldname: _currentField.fieldname,
              description: _currentField.description,
              rules: _currentField.rules,
              street: _currentField.street,
              housenumber: _currentField.housenumber,
              postalcode: _currentField.postalcode,
              city: _currentField.city,
              company: _currentField.company,
              fieldOwnerId: _currentField.fieldOwnerId,
              checkstate: newStatus, // NEUER STATUS
            );
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erfolg: Status auf ${_getCheckstateText(newStatus)} geändert.')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler beim Status-Update: ${data['message']}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verbindungsfehler beim Status-Update: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentStatusText = _getCheckstateText(_currentField.checkstate);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Prüfung',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Aktueller Status-Bereich
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Aktueller Status:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal)),
                    Text(
                      currentStatusText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _currentField.checkstate == 1 ? Colors.green : (_currentField.checkstate == 3 ? Colors.red : Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Detail-Sektionen
            _buildDetailSection('Feld-Details', [
              _buildDetailRow('Feldname:', _currentField.fieldname),
              _buildDetailRow('Ort:', '${_currentField.city}, ${_currentField.postalcode}'),
              _buildDetailRow('Adresse:', '${_currentField.street} ${_currentField.housenumber ?? ''}'),
              if (_currentField.company != null && _currentField.company!.isNotEmpty)
                _buildDetailRow('Firma/Organisation:', _currentField.company!),
            ]),
            
            _buildDetailSection('Beschreibung', [
              Text(_currentField.description ?? 'Keine Beschreibung vorhanden.'),
            ], isTextContent: true),

            if (_currentField.rules != null && _currentField.rules!.isNotEmpty)
              _buildDetailSection('Regeln', [
                Text(_currentField.rules!),
              ], isTextContent: true),
            
            const SizedBox(height: 30),
            const Text(
              'Status ändern:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const Divider(),

            // Aktions-Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _currentField.checkstate != 1 ? () => _updateFieldStatus(1) : null, // Status 1: Genehmigt
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Genehmigen'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, 
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _currentField.checkstate != 3 ? () => _updateFieldStatus(3) : null, // Status 3: Abgelehnt
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Ablehnen'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, 
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Hilfs-Widget für Detail-Abschnitte (Sauberere Darstellung)
  Widget _buildDetailSection(String title, List<Widget> children, {bool isTextContent = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),
        if (isTextContent) ...children else ...[
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
          ),
        ],
        const SizedBox(height: 5),
      ],
    );
  }
  
  // Hilfs-Widget für Detail-Zeilen
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium, // Standardtextstil
          children: <TextSpan>[
            TextSpan(text: label, style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: ' $value'),
          ],
        ),
      ),
    );
  }
}