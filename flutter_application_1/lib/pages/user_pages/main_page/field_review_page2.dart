import 'package:flutter/material.dart';
import 'field_page2.dart'; // Wichtig: Importiere das Fields-Model!

class FieldReviewPage2 extends StatefulWidget {
  final Fields2 field;

  const FieldReviewPage2({super.key, required this.field});

  @override
  State<FieldReviewPage2> createState() => _FieldReviewPage2State();
}

class _FieldReviewPage2State extends State<FieldReviewPage2> {
  // Lokale Kopie des Feldes, um den Status aktualisieren zu können
  late Fields2 _currentField;

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

  @override
  Widget build(BuildContext context) {
    String currentStatusText = _getCheckstateText(_currentField.checkstate);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentField.company?.isNotEmpty == true
              ? _currentField.company!
              : _currentField.fieldname,
          style: const TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
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