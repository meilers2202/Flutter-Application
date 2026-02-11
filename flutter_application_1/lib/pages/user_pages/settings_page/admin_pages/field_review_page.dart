import 'package:http/http.dart' as http;
import 'package:pewpew_connect/service/imports.dart';

class FieldReviewPage extends StatefulWidget {
  final Fields field;

  const FieldReviewPage({super.key, required this.field});

  @override
  State<FieldReviewPage> createState() => _FieldReviewPageState();
}

class _FieldReviewPageState extends State<FieldReviewPage> {
  // Lokale Kopie des Feldes, um den Status aktualisieren zu können
  late Fields _currentField;
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _images = [];
  List<Map<String, dynamic>> _pricingPackages = [];
  bool _eventsLoading = true;
  bool _imagesLoading = true;
  bool _pricingLoading = true;
  String? _eventsError;
  String? _imagesError;
  String? _pricingError;

  @override
  void initState() {
    super.initState();
    _currentField = widget.field;
    _fetchEvents();
    _fetchImages();
    _fetchPricing();
  }

  Future<void> _fetchEvents() async {
    final url = Uri.parse('$ipAddress/get_field_events.php');
    try {
      final response = await http.post(url, body: {'field_id': _currentField.id.toString()});
      if (response.body.trim().isEmpty) {
        setState(() {
          _eventsLoading = false;
          _eventsError = 'Leere Server-Antwort (get_field_events.php).';
        });
        return;
      }

      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        final rawEvents = (data['events'] as List?) ?? [];
        setState(() {
          _events = rawEvents.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _eventsLoading = false;
          _eventsError = null;
        });
      } else {
        setState(() {
          _eventsLoading = false;
          _eventsError = data['message']?.toString();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _eventsLoading = false;
        _eventsError = e.toString();
      });
    }
  }

  Future<void> _fetchImages() async {
    final url = Uri.parse('$ipAddress/get_field_images.php');
    try {
      final response = await http.post(url, body: {'field_id': _currentField.id.toString()});
      if (response.body.trim().isEmpty) {
        setState(() {
          _imagesLoading = false;
          _imagesError = 'Leere Server-Antwort (get_field_images.php).';
        });
        return;
      }

      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        final rawImages = (data['images'] as List?) ?? [];
        setState(() {
          _images = rawImages.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _imagesLoading = false;
          _imagesError = null;
        });
      } else {
        setState(() {
          _imagesLoading = false;
          _imagesError = data['message']?.toString();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _imagesLoading = false;
        _imagesError = e.toString();
      });
    }
  }

  Future<void> _fetchPricing() async {
    final url = Uri.parse('$ipAddress/get_field_pricing.php');
    try {
      final response = await http.post(url, body: {'field_id': _currentField.id.toString()});
      if (response.body.trim().isEmpty) {
        setState(() {
          _pricingLoading = false;
          _pricingError = 'Leere Server-Antwort (get_field_pricing.php).';
        });
        return;
      }

      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        final raw = (data['packages'] as List?) ?? [];
        setState(() {
          _pricingPackages = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _pricingLoading = false;
          _pricingError = null;
        });
      } else {
        setState(() {
          _pricingLoading = false;
          _pricingError = data['message']?.toString();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pricingLoading = false;
        _pricingError = e.toString();
      });
    }
  }

  DateTime? _tryParseDateTime(String value) {
    if (value.trim().isEmpty) return null;
    final normalized = value.contains('T') ? value : value.replaceFirst(' ', 'T');
    return DateTime.tryParse(normalized);
  }

  String _formatShortDateTime(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    final h = value.hour.toString().padLeft(2, '0');
    final min = value.minute.toString().padLeft(2, '0');
    return '$d.$m $h:$min';
  }

  String _formatEventRangeShort(String startAt, String endAt) {
    final start = _tryParseDateTime(startAt);
    final end = _tryParseDateTime(endAt);
    if (start == null) return startAt;
    if (end == null) return _formatShortDateTime(start);
    return '${_formatShortDateTime(start)} - ${_formatShortDateTime(end)}';
  }

  String _formatPrice(String? price, String? currency) {
    final rawPrice = price?.trim() ?? '';
    if (rawPrice.isEmpty) return '';
    final rawCurrency = currency?.trim() ?? 'EUR';
    return '$rawPrice $rawCurrency';
  }

  String _resolveImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '$ipAddress$url';
    return '$ipAddress/$url';
  }

  List<String> _parseRequiredGear(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw.map((item) => item.toString()).where((item) => item.trim().isNotEmpty).toList();
    }
    if (raw is String) {
      if (raw.trim().isEmpty) return [];
      try {
        final decoded = json.decode(raw);
        if (decoded is List) {
          return decoded.map((item) => item.toString()).where((item) => item.trim().isNotEmpty).toList();
        }
      } catch (_) {
        // Fall back to plain string.
      }
      return [raw];
    }
    return [raw.toString()];
  }

  List<String> _parseAreas(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw.map((item) => item.toString()).where((item) => item.trim().isNotEmpty).toList();
    }
    if (raw is String) {
      if (raw.trim().isEmpty) return [];
      try {
        final decoded = json.decode(raw);
        if (decoded is List) {
          return decoded.map((item) => item.toString()).where((item) => item.trim().isNotEmpty).toList();
        }
      } catch (_) {
        // Fall back to plain string.
      }
      return [raw];
    }
    return [raw.toString()];
  }

  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, color: Colors.white, size: 48);
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEventDetails(Map<String, dynamic> event) {
    final title = event['title']?.toString() ?? '';
    final startAt = event['start_at']?.toString() ?? '';
    final endAt = event['end_at']?.toString() ?? '';
    final description = event['description']?.toString() ?? '';
    final scenario = event['scenario']?.toString() ?? '';
    final organizer = event['organizer']?.toString() ?? '';
    final minAge = event['min_age']?.toString() ?? '';
    final medicContact = event['medic_contact']?.toString() ?? '';
    final address = event['location']?.toString() ?? '';
    final lat = event['location_lat']?.toString() ?? '';
    final lng = event['location_lng']?.toString() ?? '';
    final requiredGear = _parseRequiredGear(event['required_gear']);
    final powerLimits = (event['power_limits'] as List?) ?? [];
    final tickets = (event['tickets'] as List?) ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title.isEmpty ? 'Event' : title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatEventRangeShort(startAt, endAt)),
                if (address.isNotEmpty) Text('Adresse: $address'),
                if (lat.isNotEmpty || lng.isNotEmpty) Text('Koordinaten: $lat, $lng'),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Beschreibung: $description'),
                ],
                if (scenario.isNotEmpty) Text('Scenario: $scenario'),
                if (organizer.isNotEmpty) Text('Veranstalter: $organizer'),
                if (minAge.isNotEmpty) Text('Mindestalter: $minAge'),
                if (requiredGear.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Pflicht-Ausrustung:'),
                  for (final gear in requiredGear) Text('- $gear'),
                ],
                if (powerLimits.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Joule/FPS Limits:'),
                  for (final limit in powerLimits)
                    Text(
                      '${limit['class_name'] ?? ''}: '
                      '${(limit['limit_value']?.toString().trim().isNotEmpty ?? false) ? limit['limit_value'] : '-'} '
                      '| Abstand: ${limit['distance'] ?? ''} '
                      '| Pflicht: ${limit['requirement'] ?? ''}',
                    ),
                ],
                if (tickets.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Tickets:'),
                  for (final ticket in tickets)
                    Text(
                      '${ticket['label'] ?? ''} - ${ticket['price'] ?? ''} ${ticket['currency'] ?? ''}',
                    ),
                ],
                if (medicContact.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Notfallkontakt: $medicContact'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Schliessen'),
            ),
          ],
        );
      },
    );
  }

  void _showPricingDetails(Map<String, dynamic> pkg) {
    final name = pkg['name']?.toString() ?? '';
    final price = _formatPrice(pkg['price']?.toString(), pkg['currency']?.toString());
    final description = pkg['description']?.toString() ?? '';
    final playTime = pkg['play_time']?.toString() ?? '';
    final ageRating = pkg['age_rating']?.toString() ?? '';
    final notes = pkg['notes']?.toString() ?? '';
    final areas = _parseAreas(pkg['areas_json']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(name.isEmpty ? 'Paket' : name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (price.isNotEmpty) Text('Preis: $price'),
                if (playTime.isNotEmpty) Text('Spielzeit: $playTime'),
                if (ageRating.isNotEmpty) Text('Altersfreigabe: $ageRating'),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Beschreibung: $description'),
                ],
                if (areas.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Nutzbare Bereiche:'),
                  for (final area in areas) Text('- $area'),
                ],
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Hinweise: $notes'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Schliessen'),
            ),
          ],
        );
      },
    );
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

  // Funktion zum Löschen des Feldes
  Future<void> _deleteField() async {
    final url = Uri.parse('$ipAddress/delete_field.php');

    try {
      final response = await http.post(
        url,
        body: {
          'field_id': widget.field.id.toString(), // ID des Feldes verwenden
        },
      );

      if (!mounted) return;

      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        // Erfolgsmeldung anzeigen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
        // Zurück zur vorherigen Seite navigieren (z.B. der Feldliste)
        Navigator.of(context).pop(); 
      } else {
        // Fehlermeldung anzeigen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verbindungsfehler beim Löschen: $e')),
      );
    }
  }
  

  // Funktion, die den Status in der Datenbank ändert
  Future<void> _updateFieldStatus(int newStatus) async {
    final url = Uri.parse('$ipAddress/update_field_status.php');
    
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
              checkstate: newStatus,
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

  // Sicherheitsabfrage vor dem Löschen
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Feld löschen'),
          content: Text('Sind Sie sicher, dass Sie das Feld "${widget.field.fieldname}" unwiderruflich löschen möchten?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialog schließen
                _deleteField(); // Löschfunktion aufrufen
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Löschen', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String currentStatusText = _getCheckstateText(_currentField.checkstate);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Prüfung', // Feldname im Titel hinzugefügt
          style: const TextStyle(
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

            _buildDetailSection('Bilder', [
              if (_imagesLoading)
                const SizedBox(
                  height: 110,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_imagesError != null)
                Text(_imagesError!, style: const TextStyle(color: Colors.red))
              else if (_images.isEmpty)
                const Text('Keine Bilder vorhanden.')
              else
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _images.map((img) {
                      final rawUrl = img['image_url']?.toString() ?? '';
                      final resolvedUrl = _resolveImageUrl(rawUrl);
                      return GestureDetector(
                        onTap: resolvedUrl.isEmpty ? null : () => _showImagePreview(resolvedUrl),
                        child: Container(
                          width: 150,
                          margin: const EdgeInsets.only(right: 10),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                          child: resolvedUrl.isEmpty
                              ? const Center(child: Icon(Icons.image_not_supported))
                              : Image.network(
                                  resolvedUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(child: Icon(Icons.broken_image));
                                  },
                                ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ], isTextContent: true),

            _buildDetailSection('Events', [
              if (_eventsLoading)
                const Center(child: CircularProgressIndicator())
              else if (_eventsError != null)
                Text(_eventsError!, style: const TextStyle(color: Colors.red))
              else if (_events.isEmpty)
                const Text('Keine Events vorhanden.')
              else
                ..._events.map((event) {
                  final title = event['title']?.toString() ?? '';
                  final startAt = event['start_at']?.toString() ?? '';
                  final endAt = event['end_at']?.toString() ?? '';
                  final dateText = _formatEventRangeShort(startAt, endAt);
                  return InkWell(
                    onTap: () => _showEventDetails(event),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(title)),
                          const SizedBox(width: 10),
                          Text(dateText),
                        ],
                      ),
                    ),
                  );
                }),
            ], isTextContent: true),

            _buildDetailSection('Pricing', [
              if (_pricingLoading)
                const Center(child: CircularProgressIndicator())
              else if (_pricingError != null)
                Text(_pricingError!, style: const TextStyle(color: Colors.red))
              else if (_pricingPackages.isEmpty)
                const Text('Keine Pakete vorhanden.')
              else
                ..._pricingPackages.map((pkg) {
                  final name = pkg['name']?.toString() ?? '';
                  final price = _formatPrice(pkg['price']?.toString(), pkg['currency']?.toString());
                  final playTime = pkg['play_time']?.toString() ?? '';
                  final subtitleParts = <String>[];
                  if (price.isNotEmpty) subtitleParts.add(price);
                  if (playTime.isNotEmpty) subtitleParts.add(playTime);
                  final subtitle = subtitleParts.join(' | ');
                  return InkWell(
                    onTap: () => _showPricingDetails(pkg),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(name)),
                          const SizedBox(width: 10),
                          Text(subtitle),
                        ],
                      ),
                    ),
                  );
                }),
            ], isTextContent: true),
            
            const SizedBox(height: 30),
            
            // Status Aktionen
            const Text(
              'Status ändern:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const Divider(),
            LayoutBuilder(
              builder: (context, constraints) {

                const double spacing = 10;

                // Anzahl Buttons pro Zeile je nach Breite
                final int buttonsPerRow = constraints.maxWidth > 600 ? 4 : 2;

                // verfügbare Breite abzüglich spacing
                final double buttonWidth =
                    (constraints.maxWidth - ((buttonsPerRow - 1) * spacing)) / buttonsPerRow;

                return Wrap(
                  spacing: spacing,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    SizedBox(
                      width: buttonWidth,
                      child: ElevatedButton.icon(
                        onPressed: _currentField.checkstate != 1 ? () => _updateFieldStatus(1) : null,
                        icon: const Icon(Icons.check_circle_outline),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                        ),
                        label: const Text('Genehmigen'),
                      ),
                    ),
                    SizedBox(
                      width: buttonWidth,
                      child: ElevatedButton.icon(
                        onPressed: _currentField.checkstate != 2 ? () => _updateFieldStatus(2) : null,
                        icon: const Icon(Icons.info_outline),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color.fromARGB(255, 249, 170, 0),
                        ),
                        label: const Text('Wird geklärt'),
                      ),
                    ),
                    SizedBox(
                      width: buttonWidth,
                      child: ElevatedButton.icon(
                        onPressed: _currentField.checkstate != 3 ? () => _updateFieldStatus(3) : null,
                        icon: const Icon(Icons.cancel_outlined),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                        ),
                        label: const Text('Ablehnen'),
                      ),
                    ),
                    SizedBox(
                      width: buttonWidth,
                      child: ElevatedButton.icon(
                        onPressed: _confirmDelete,
                        icon: const Icon(Icons.delete_forever, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        label: const Text('LÖSCHEN'),
                      ),
                    ),
                  ],
                );
              },
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