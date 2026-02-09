import 'package:pewpew_connect/service/imports.dart';


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

  @override
  Widget build(BuildContext context) {

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

            const SizedBox(height: 0),

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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openRouteMap,
                icon: const Icon(Icons.directions),
                label: const Text('Route starten'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildFieldAddress(Fields2 field) {
    final parts = <String>[];
    if (field.street != null && field.street!.trim().isNotEmpty) {
      final hn = field.housenumber?.trim() ?? '';
      final streetLine = '${field.street!.trim()} ${hn.trim()}'.trim();
      if (streetLine.isNotEmpty) parts.add(streetLine);
    }
    final postalRaw = field.postalcode?.trim() ?? '';
    final postalDigits = postalRaw.replaceAll(RegExp(r'\D'), '');
    final postal = RegExp(r'^\d{4,6}$').hasMatch(postalDigits) ? postalDigits : '';
    final cityLine = '$postal ${field.city?.trim() ?? ''}'.trim();
    if (cityLine.isNotEmpty) parts.add(cityLine);

    if (parts.isEmpty && field.city != null && field.city!.trim().isNotEmpty) {
      parts.add(field.city!.trim());
    }
    return parts.join(', ');
  }

  void _openRouteMap() {
    final address = _buildFieldAddress(_currentField);
    debugPrint(
      'Route debug | fieldId=${_currentField.id} | name=${_currentField.fieldname} | '
      'company=${_currentField.company ?? ''} | street=${_currentField.street ?? ''} | '
      'housenumber=${_currentField.housenumber ?? ''} | postalcode=${_currentField.postalcode ?? ''} | '
      'city=${_currentField.city ?? ''} | fullAddress=$address',
    );
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keine Adresse vorhanden.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FieldMapPage(
          destinationName: _currentField.fieldname,
          destinationAddress: address,
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