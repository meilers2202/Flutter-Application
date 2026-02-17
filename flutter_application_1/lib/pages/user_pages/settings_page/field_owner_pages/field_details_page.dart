import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:pewpew_connect/service/imports.dart';

class FieldDetailsPage extends StatefulWidget {
  final Field field;

  const FieldDetailsPage({
    super.key,
    required this.field,
  });

  @override
  State<FieldDetailsPage> createState() => _FieldDetailsPageState();
}

class _FieldDetailsPageState extends State<FieldDetailsPage> {
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _images = [];
  List<Map<String, dynamic>> _pricingPackages = [];
  bool _eventsLoading = true;
  bool _imagesLoading = true;
  bool _pricingLoading = true;
  String? _eventsError;
  String? _imagesError;
  String? _pricingError;
  static const List<String> _limitRequirementOptions = [
    'Keine',
    'Nur Semi-Auto',
    'Bolt-Action',
    'Zielfernrohr (min. 4x)',
  ];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
    _fetchImages();
    _fetchPricing();
  }

  Future<void> _fetchEvents() async {
    final url = Uri.parse('$ipAddress/get_field_events.php');
    try {
      final response = await http.post(url, body: {'field_id': widget.field.id.toString()});
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
      final response = await http.post(url, body: {'field_id': widget.field.id.toString()});
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
          _images = rawImages.map((i) => Map<String, dynamic>.from(i as Map)).toList();
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
      final response = await http.post(url, body: {'field_id': widget.field.id.toString()});
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
  
  // Funktion zum Löschen des Feldes
  Future<void> _deleteField() async {
    final url = Uri.parse('$ipAddress/delete_field.php');

    try {
      final response = await http.post(
        url,
        body: {
          'field_id': widget.field.id.toString(),
        },
      );

      if (!mounted) return;
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
        Navigator.of(context).pop(true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Löschen: ${data['message']}')),
        );
      }
    } on FormatException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verbindungsfehler: Server hat keine gültige JSON-Antwort gesendet (Wahrscheinlich PHP-Fehler).')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unerwarteter Fehler beim Löschen: $e')),
      );
    }
  }

  // Sicherheitsabfrage vor dem Löschen (unverändert)
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
                Navigator.of(context).pop(); 
                _deleteField(); 
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Löschen', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
  
  // 🎨 NEUES WIDGET für konsistente Informationsanzeige
  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String content,
    bool isAddress = false,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Color.fromARGB(255, 41, 107, 43), size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const Divider(height: 10, color: Colors.grey),
            const SizedBox(height: 5),
            Text(
              content,
              style: TextStyle(
                fontSize: isAddress ? 16 : 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color.fromARGB(255, 41, 107, 43), size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            const Divider(height: 10, color: Colors.grey),
            const SizedBox(height: 5),
            ...children,
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.field.fieldname,
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/app_bgr.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            const SizedBox(height: 15),
            // NEU: Informationen in Cards gruppiert
            _buildDetailCard(
              icon: Icons.location_on,
              title: 'Adresse',
              content: 'Firma:         ${widget.field.company}\nAnschrift:   ${widget.field.street} ${widget.field.housenumber}\nStadt:          ${widget.field.city}',
              isAddress: true,
            ),
            
            _buildDetailCard(
              icon: Icons.description,
              title: 'Beschreibung',
              content: widget.field.description,
            ),
            
            _buildDetailCard(
              icon: Icons.gavel,
              title: 'Regeln',
              content: widget.field.rules,
            ),

            _buildListCard(
              icon: Icons.photo_library,
              title: 'Bilder',
              children: [
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
                      children: _images
                          .map((img) => _buildImageTile(img['image_url']?.toString() ?? ''))
                          .toList(),
                    ),
                  ),
              ],
            ),

            _buildDetailCard(
              icon: Icons.sports,
              title: 'Heimteam',
              content: widget.field.homeTeamName?.isNotEmpty == true
                  ? widget.field.homeTeamName!
                  : 'Nicht angegeben',
            ),

            _buildListCard(
              icon: Icons.event,
              title: 'Events',
              children: [
                if (_eventsLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_eventsError != null)
                  Text(_eventsError!, style: const TextStyle(color: Colors.red))
                else if (_events.isEmpty)
                  const Text('Keine Events vorhanden.')
                else
                  ..._events.map(
                    (event) {
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
                    },
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showAddEventDialog,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Event hinzufuegen', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 41, 107, 43),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            _buildListCard(
              icon: Icons.payments,
              title: 'Pricing',
              children: [
                if (_pricingLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_pricingError != null)
                  Text(_pricingError!, style: const TextStyle(color: Colors.red))
                else if (_pricingPackages.isEmpty)
                  const Text('Keine Pakete vorhanden.')
                else
                  ..._pricingPackages.map(
                    (pkg) {
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
                    },
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showAddPricingDialog,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('+ Hinzufuegen', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 41, 107, 43),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            
            // BEARBEITEN BUTTON (Design leicht angepasst)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/editfield',
                    arguments: widget.field,
                  ).then((result) { 
                    if (!context.mounted) return;
                    if (result == true) {
                      Navigator.of(context).pop(true);
                    }
                  });
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text('Feld bearbeiten'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 41, 107, 43),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            
            const SizedBox(height: 15),

            // LÖSCHEN BUTTON (Design leicht angepasst)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _confirmDelete,
                icon: const Icon(Icons.delete_forever, color: Colors.white),
                label: const Text('Feld entfernen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 209, 56, 45),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14), // Padding erhöht
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageTile(String imageUrl) {
    final resolvedUrl = _resolveImageUrl(imageUrl);
    return GestureDetector(
      onTap: resolvedUrl.isEmpty ? null : () => _showImagePreview(resolvedUrl),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 10),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
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
  }

  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
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

  String _resolveImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '$ipAddress$url';
    return '$ipAddress/$url';
  }

  String _formatDateTime(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    final h = value.hour.toString().padLeft(2, '0');
    final min = value.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min:00';
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

  String _composeEventLocation({
    required String street,
    required String houseNumber,
    required String postalcode,
    required String city,
    required String state,
    required String country,
  }) {
    final parts = <String>[];
    final line1 = '$street $houseNumber'.trim();
    final line2 = '$postalcode $city'.trim();
    if (line1.isNotEmpty) parts.add(line1);
    if (line2.isNotEmpty) parts.add(line2);
    if (state.trim().isNotEmpty) parts.add(state.trim());
    if (country.trim().isNotEmpty) parts.add(country.trim());
    return parts.join(', ');
  }

  List<String> _buildEventAddressLines(Map<String, dynamic> event) {
    final street = event['location_street']?.toString().trim() ?? '';
    final houseNumber = event['location_house_number']?.toString().trim() ?? '';
    final postalcode = event['location_postalcode']?.toString().trim() ?? '';
    final city = event['location_city']?.toString().trim() ?? '';
    final state = event['location_state']?.toString().trim() ?? '';
    final country = event['location_country']?.toString().trim() ?? '';

    final lines = <String>[];
    final line1 = '$street $houseNumber'.trim();
    final line2 = '$postalcode $city'.trim();
    if (line1.isNotEmpty) lines.add(line1);
    if (line2.isNotEmpty) lines.add(line2);
    if (state.isNotEmpty) lines.add(state);
    if (country.isNotEmpty) lines.add(country);

    if (lines.isNotEmpty) return lines;

    final fallback = event['location']?.toString().trim() ?? '';
    if (fallback.isEmpty) return [];
    return fallback
        .replaceAll('\n', ',')
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
  }

  String _formatLatLng(LatLng value) {
    final lat = value.latitude.toStringAsFixed(5);
    final lng = value.longitude.toStringAsFixed(5);
    return '$lat, $lng';
  }

  Future<DateTime?> _pickDateTime(BuildContext context, DateTime? initialValue) async {
    final now = DateTime.now();
    final initialDate = initialValue ?? now;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (pickedDate == null) return null;
    if (!context.mounted) return null;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialValue ?? now),
    );
    if (pickedTime == null) return null;
    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  Future<void> _createEvent({
    required String title,
    required String description,
    required String scenario,
    required String organizer,
    required DateTime startAt,
    required DateTime endAt,
    required String minAge,
    required List<String> requiredGear,
    required String medicContact,
    required List<_PowerLimitInput> powerLimits,
    required List<_TicketInput> tickets,
    required LatLng location,
    required String locationStreet,
    required String locationHouseNumber,
    required String locationPostalcode,
    required String locationCity,
    required String locationState,
    required String locationCountry,
  }) async {
    final url = Uri.parse('$ipAddress/add_field_event.php');
    try {
      final body = {
        'field_id': widget.field.id.toString(),
        'title': title,
        'description': description,
        'location': _composeEventLocation(
          street: locationStreet,
          houseNumber: locationHouseNumber,
          postalcode: locationPostalcode,
          city: locationCity,
          state: locationState,
          country: locationCountry,
        ),
        'location_street': locationStreet.trim(),
        'location_house_number': locationHouseNumber.trim(),
        'location_postalcode': locationPostalcode.trim(),
        'location_city': locationCity.trim(),
        'location_state': locationState.trim(),
        'location_country': locationCountry.trim(),
        'location_lat': location.latitude.toString(),
        'location_lng': location.longitude.toString(),
        'scenario': scenario,
        'organizer': organizer,
        'start_at': _formatDateTime(startAt),
        'end_at': _formatDateTime(endAt),
        'min_age': minAge,
        'required_gear': jsonEncode(requiredGear),
        'medic_contact': medicContact,
        'power_limits': jsonEncode(powerLimits.map((p) => p.toJson()).toList()),
      };

      if (tickets.isNotEmpty) {
        body['tickets'] = jsonEncode(tickets.map((t) => t.toJson()).toList());
      }

      final response = await http.post(url, body: body);
      if (!mounted) return;
      if (response.body.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leere Server-Antwort (add_field_event.php).')),
        );
        return;
      }

      final Map<String, dynamic> data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Event erstellt.')),
        );
        _fetchEvents();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Fehler beim Erstellen.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verbindungsfehler: $e')),
      );
    }
  }

  Future<void> _updateEvent({
    required int id,
    required String title,
    required String description,
    required String scenario,
    required String organizer,
    required DateTime startAt,
    required DateTime endAt,
    required String minAge,
    required List<String> requiredGear,
    required String medicContact,
    required List<_PowerLimitInput> powerLimits,
    required List<_TicketInput> tickets,
    required LatLng location,
    required String locationStreet,
    required String locationHouseNumber,
    required String locationPostalcode,
    required String locationCity,
    required String locationState,
    required String locationCountry,
  }) async {
    final url = Uri.parse('$ipAddress/update_field_event.php');
    try {
      final body = {
        'id': id.toString(),
        'title': title,
        'description': description,
        'location': _composeEventLocation(
          street: locationStreet,
          houseNumber: locationHouseNumber,
          postalcode: locationPostalcode,
          city: locationCity,
          state: locationState,
          country: locationCountry,
        ),
        'location_street': locationStreet.trim(),
        'location_house_number': locationHouseNumber.trim(),
        'location_postalcode': locationPostalcode.trim(),
        'location_city': locationCity.trim(),
        'location_state': locationState.trim(),
        'location_country': locationCountry.trim(),
        'location_lat': location.latitude.toString(),
        'location_lng': location.longitude.toString(),
        'scenario': scenario,
        'organizer': organizer,
        'start_at': _formatDateTime(startAt),
        'end_at': _formatDateTime(endAt),
        'min_age': minAge,
        'required_gear': jsonEncode(requiredGear),
        'medic_contact': medicContact,
        'power_limits': jsonEncode(powerLimits.map((p) => p.toJson()).toList()),
        'tickets': jsonEncode(tickets.map((t) => t.toJson()).toList()),
      };

      final response = await http.post(url, body: body);
      if (!mounted) return;
      if (response.body.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leere Server-Antwort (update_field_event.php).')),
        );
        return;
      }

      final Map<String, dynamic> data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Event aktualisiert.')),
        );
        _fetchEvents();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Fehler beim Aktualisieren.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verbindungsfehler: $e')),
      );
    }
  }

  Future<void> _deleteEvent(int id) async {
    final url = Uri.parse('$ipAddress/delete_field_event.php');
    try {
      final response = await http.post(url, body: {'id': id.toString()});
      if (!mounted) return;
      if (response.body.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leere Server-Antwort (delete_field_event.php).')),
        );
        return;
      }

      final Map<String, dynamic> data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Event geloescht.')),
        );
        _fetchEvents();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Fehler beim Loeschen.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verbindungsfehler: $e')),
      );
    }
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
    final addressLines = _buildEventAddressLines(event);
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
                if (addressLines.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Adresse:'),
                  for (final line in addressLines) Text('- $line'),
                ],
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
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showEditEventDialog(event);
              },
              child: const Text('Bearbeiten'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Event loeschen?'),
                    content: const Text('Soll dieses Event wirklich geloescht werden?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Abbrechen')),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Loeschen', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  final id = event['id'] is int ? event['id'] : int.parse(event['id'].toString());
                  _deleteEvent(id);
                }
              },
              child: const Text('Loeschen', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createPricingPackage({
    required String name,
    required String price,
    required String currency,
    required String description,
    required String playTime,
    required String ageRating,
    required String notes,
    required List<String> areas,
  }) async {
    final url = Uri.parse('$ipAddress/add_field_pricing.php');
    try {
      final body = {
        'field_id': widget.field.id.toString(),
        'name': name,
        'price': price,
        'currency': currency,
        'description': description,
        'play_time': playTime,
        'age_rating': ageRating,
        'notes': notes,
        'areas': jsonEncode(areas),
      };

      final response = await http.post(url, body: body);
      if (!mounted) return;
      if (response.body.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leere Server-Antwort (add_field_pricing.php).')),
        );
        return;
      }

      final Map<String, dynamic> data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Paket erstellt.')),
        );
        _fetchPricing();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Fehler beim Erstellen.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verbindungsfehler: $e')),
      );
    }
  }

  Future<void> _updatePricingPackage({
    required int id,
    required String name,
    required String price,
    required String currency,
    required String description,
    required String playTime,
    required String ageRating,
    required String notes,
    required List<String> areas,
  }) async {
    final url = Uri.parse('$ipAddress/update_field_pricing.php');
    try {
      final body = {
        'id': id.toString(),
        'name': name,
        'price': price,
        'currency': currency,
        'description': description,
        'play_time': playTime,
        'age_rating': ageRating,
        'notes': notes,
        'areas': jsonEncode(areas),
      };

      final response = await http.post(url, body: body);
      if (!mounted) return;
      if (response.body.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leere Server-Antwort (update_field_pricing.php).')),
        );
        return;
      }

      final Map<String, dynamic> data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Paket aktualisiert.')),
        );
        _fetchPricing();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Fehler beim Aktualisieren.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verbindungsfehler: $e')),
      );
    }
  }

  Future<void> _deletePricingPackage(int id) async {
    final url = Uri.parse('$ipAddress/delete_field_pricing.php');
    try {
      final response = await http.post(url, body: {'id': id.toString()});
      if (!mounted) return;
      if (response.body.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leere Server-Antwort (delete_field_pricing.php).')),
        );
        return;
      }

      final Map<String, dynamic> data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Paket geloescht.')),
        );
        _fetchPricing();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Fehler beim Loeschen.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verbindungsfehler: $e')),
      );
    }
  }

  void _showAddPricingDialog() {
    _showPricingDialog();
  }

  void _showEditPricingDialog(Map<String, dynamic> pkg) {
    _showPricingDialog(package: pkg);
  }

  void _showPricingDialog({Map<String, dynamic>? package}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: package?['name']?.toString() ?? '');
    final priceController = TextEditingController(text: package?['price']?.toString() ?? '');
    final currencyController = TextEditingController(text: package?['currency']?.toString() ?? 'EUR');
    final descriptionController = TextEditingController(text: package?['description']?.toString() ?? '');
    final playTimeController = TextEditingController(text: package?['play_time']?.toString() ?? '');
    final ageRatingController = TextEditingController(text: package?['age_rating']?.toString() ?? '');
    final notesController = TextEditingController(text: package?['notes']?.toString() ?? '');

    final areasControllers = <TextEditingController>[];
    final existingAreas = _parseAreas(package?['areas_json']);
    for (final area in existingAreas) {
      areasControllers.add(TextEditingController(text: area));
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(package == null ? 'Paket hinzufuegen' : 'Paket bearbeiten'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Name des Pakets'),
                        validator: (value) => value == null || value.isEmpty ? 'Name erforderlich' : null,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: priceController,
                              decoration: const InputDecoration(labelText: 'Preis'),
                              keyboardType: TextInputType.number,
                              validator: (value) => value == null || value.isEmpty ? 'Preis erforderlich' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 80,
                            child: TextFormField(
                              controller: currencyController,
                              decoration: const InputDecoration(labelText: 'Waehrung'),
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Beschreibung'),
                        maxLines: 2,
                      ),
                      TextFormField(
                        controller: playTimeController,
                        decoration: const InputDecoration(labelText: 'Spielzeit'),
                      ),
                      TextFormField(
                        controller: ageRatingController,
                        decoration: const InputDecoration(labelText: 'Altersfreigabe'),
                      ),
                      TextFormField(
                        controller: notesController,
                        decoration: const InputDecoration(labelText: 'Hinweise'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Nutzbare Bereiche', style: Theme.of(context).textTheme.titleMedium),
                      ),
                      if (areasControllers.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 6.0, bottom: 6.0),
                          child: Text('Keine Bereiche hinzugefuegt.'),
                        ),
                      for (int i = 0; i < areasControllers.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: areasControllers[i],
                                decoration: InputDecoration(labelText: 'Bereich ${i + 1}'),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      final removed = areasControllers.removeAt(i);
                                      removed.dispose();
                                    });
                                  },
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  label: const Text('Bereich entfernen', style: TextStyle(color: Colors.red)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => setState(() => areasControllers.add(TextEditingController())),
                          icon: const Icon(Icons.add),
                          label: const Text('Bereich hinzufuegen'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Abbrechen'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    final areas = areasControllers
                        .map((controller) => controller.text.trim())
                        .where((value) => value.isNotEmpty)
                        .toList();

                    if (package == null) {
                      _createPricingPackage(
                        name: nameController.text.trim(),
                        price: priceController.text.trim(),
                        currency: currencyController.text.trim().isEmpty ? 'EUR' : currencyController.text.trim(),
                        description: descriptionController.text.trim(),
                        playTime: playTimeController.text.trim(),
                        ageRating: ageRatingController.text.trim(),
                        notes: notesController.text.trim(),
                        areas: areas,
                      );
                    } else {
                      _updatePricingPackage(
                        id: package['id'] is int ? package['id'] : int.parse(package['id'].toString()),
                        name: nameController.text.trim(),
                        price: priceController.text.trim(),
                        currency: currencyController.text.trim().isEmpty ? 'EUR' : currencyController.text.trim(),
                        description: descriptionController.text.trim(),
                        playTime: playTimeController.text.trim(),
                        ageRating: ageRatingController.text.trim(),
                        notes: notesController.text.trim(),
                        areas: areas,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 41, 107, 43)),
                  child: const Text('Speichern', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
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
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showEditPricingDialog(pkg);
              },
              child: const Text('Bearbeiten'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Paket loeschen?'),
                    content: const Text('Soll dieses Paket wirklich geloescht werden?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Abbrechen')),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Loeschen', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  final id = pkg['id'] is int ? pkg['id'] : int.parse(pkg['id'].toString());
                  _deletePricingPackage(id);
                }
              },
              child: const Text('Loeschen', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showAddEventDialog() {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationStreetController = TextEditingController();
    final locationHouseNumberController = TextEditingController();
    final locationPostalcodeController = TextEditingController();
    final locationCityController = TextEditingController();
    final locationStateController = TextEditingController();
    final locationCountryController = TextEditingController();
    final scenarioController = TextEditingController();
    final organizerController = TextEditingController();
    final minAgeController = TextEditingController();
    final medicContactController = TextEditingController();
    final requiredGearControllers = <TextEditingController>[];

    DateTime? startAt;
    DateTime? endAt;
    LatLng? locationLatLng;

    final powerLimits = <_PowerLimitInput>[];

    final tickets = <_TicketInput>[];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Event hinzufuegen'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Titel'),
                        validator: (value) => value == null || value.isEmpty ? 'Titel erforderlich' : null,
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Beschreibung'),
                        maxLines: 3,
                        validator: (value) => value == null || value.isEmpty ? 'Beschreibung erforderlich' : null,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Ort', style: Theme.of(context).textTheme.titleMedium),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              locationLatLng == null
                                  ? 'Keine Position gesetzt.'
                                  : _formatLatLng(locationLatLng!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await Navigator.of(context).push<_EventLocationResult>(
                                MaterialPageRoute(
                                  builder: (_) => _EventLocationPickerPage(
                                    initialLocation: locationLatLng,
                                  ),
                                ),
                              );
                              if (picked != null) {
                                setState(() {
                                  locationLatLng = picked.location;
                                  locationStreetController.text = picked.street;
                                  locationHouseNumberController.text = picked.houseNumber;
                                  locationPostalcodeController.text = picked.postalcode;
                                  locationCityController.text = picked.city;
                                  locationStateController.text = picked.state;
                                  locationCountryController.text = picked.country;
                                });
                              }
                            },
                            icon: const Icon(Icons.map_outlined),
                            label: const Text('Karte'),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: locationStreetController,
                        decoration: const InputDecoration(labelText: 'Strasse'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Strasse erforderlich' : null,
                      ),
                      TextFormField(
                        controller: locationHouseNumberController,
                        decoration: const InputDecoration(labelText: 'Hausnummer'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Hausnummer erforderlich' : null,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: locationPostalcodeController,
                              decoration: const InputDecoration(labelText: 'PLZ'),
                              validator: (value) => value == null || value.trim().isEmpty ? 'PLZ erforderlich' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: locationCityController,
                              decoration: const InputDecoration(labelText: 'Ort'),
                              validator: (value) => value == null || value.trim().isEmpty ? 'Ort erforderlich' : null,
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: locationStateController,
                        decoration: const InputDecoration(labelText: 'Bundesland/Region (optional)'),
                      ),
                      TextFormField(
                        controller: locationCountryController,
                        decoration: const InputDecoration(labelText: 'Land'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Land erforderlich' : null,
                      ),
                      TextFormField(
                        controller: scenarioController,
                        decoration: const InputDecoration(labelText: 'Spielmodus/Scenario'),
                        validator: (value) => value == null || value.isEmpty ? 'Scenario erforderlich' : null,
                      ),
                      TextFormField(
                        controller: organizerController,
                        decoration: const InputDecoration(labelText: 'Veranstalter/Team'),
                        validator: (value) => value == null || value.isEmpty ? 'Veranstalter erforderlich' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final picked = await _pickDateTime(context, startAt);
                                if (picked != null) {
                                  setState(() => startAt = picked);
                                }
                              },
                              child: Text(startAt == null ? 'Start waehlen' : _formatDateTime(startAt!)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final picked = await _pickDateTime(context, endAt);
                                if (picked != null) {
                                  setState(() => endAt = picked);
                                }
                              },
                              child: Text(endAt == null ? 'Ende waehlen' : _formatDateTime(endAt!)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: minAgeController,
                        decoration: const InputDecoration(labelText: 'Mindestalter'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty ? 'Mindestalter erforderlich' : null,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Pflicht-Ausrustung', style: Theme.of(context).textTheme.titleMedium),
                      ),
                      if (requiredGearControllers.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 6.0, bottom: 6.0),
                          child: Text('Keine Pflicht-Ausrustung hinzugefuegt.'),
                        ),
                      for (int i = 0; i < requiredGearControllers.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: requiredGearControllers[i],
                                decoration: InputDecoration(labelText: 'Eintrag ${i + 1}'),
                                validator: (value) => value == null || value.isEmpty ? 'Eintrag erforderlich' : null,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      final removed = requiredGearControllers.removeAt(i);
                                      removed.dispose();
                                    });
                                  },
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  label: const Text('Eintrag entfernen', style: TextStyle(color: Colors.red)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() => requiredGearControllers.add(TextEditingController()));
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Pflicht-Ausrustung hinzufuegen'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Joule/FPS Limits', style: Theme.of(context).textTheme.titleMedium),
                      ),
                      const SizedBox(height: 6),
                      for (int i = 0; i < powerLimits.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: powerLimits[i].classController,
                                decoration: InputDecoration(labelText: 'Klasse ${i + 1}'),
                                validator: (value) => value == null || value.isEmpty ? 'Klasse erforderlich' : null,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: powerLimits[i].limitController,
                                      decoration: const InputDecoration(labelText: 'Limit'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      controller: powerLimits[i].distanceController,
                                      decoration: const InputDecoration(labelText: 'Abstand'),
                                      validator: (value) => value == null || value.isEmpty ? 'Abstand erforderlich' : null,
                                    ),
                                  ),
                                ],
                              ),
                              DropdownButtonFormField<String>(
                                initialValue: powerLimits[i].requirementValue,
                                decoration: const InputDecoration(labelText: 'Pflicht'),
                                items: _limitRequirementOptions
                                    .map(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() => powerLimits[i].requirementValue = value);
                                },
                                validator: (value) => value == null || value.isEmpty ? 'Pflicht erforderlich' : null,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      final removed = powerLimits.removeAt(i);
                                      removed.dispose();
                                    });
                                  },
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  label: const Text('Eintrag entfernen', style: TextStyle(color: Colors.red)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(
                              () => powerLimits.add(
                                _PowerLimitInput(requirement: _limitRequirementOptions.first),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Klasse hinzufuegen'),
                        ),
                      ),
                      TextFormField(
                        controller: medicContactController,
                        decoration: const InputDecoration(labelText: 'Sanitaeter/Notfallkontakt'),
                        validator: (value) => value == null || value.isEmpty ? 'Kontakt erforderlich' : null,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Tickets', style: Theme.of(context).textTheme.titleMedium),
                      ),
                      const SizedBox(height: 6),
                      if (tickets.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6.0),
                          child: Text('Noch keine Tickets hinzugefuegt.'),
                        ),
                      for (int i = 0; i < tickets.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: tickets[i].labelController,
                                decoration: InputDecoration(labelText: 'Ticket ${i + 1} Titel'),
                                validator: (value) => value == null || value.isEmpty ? 'Tickettitel erforderlich' : null,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: tickets[i].priceController,
                                      decoration: const InputDecoration(labelText: 'Preis'),
                                      keyboardType: TextInputType.number,
                                      validator: (value) => value == null || value.isEmpty ? 'Preis erforderlich' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 80,
                                    child: TextFormField(
                                      controller: tickets[i].currencyController,
                                      decoration: const InputDecoration(labelText: 'Waehrung'),
                                    ),
                                  ),
                                ],
                              ),
                              TextFormField(
                                controller: tickets[i].notesController,
                                decoration: const InputDecoration(labelText: 'Notizen (optional)'),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      final removed = tickets.removeAt(i);
                                      removed.dispose();
                                    });
                                  },
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  label: const Text('Ticket entfernen', style: TextStyle(color: Colors.red)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() => tickets.add(_TicketInput()));
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Ticket hinzufuegen'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Abbrechen'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    if (startAt == null || endAt == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bitte Start und Ende setzen.')),
                      );
                      return;
                    }
                    if (locationLatLng == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bitte die Position auf der Karte setzen.')),
                      );
                      return;
                    }
                    if (requiredGearControllers.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bitte Pflicht-Ausrustung hinzufuegen.')),
                      );
                      return;
                    }
                    final requiredGear = requiredGearControllers
                        .map((controller) => controller.text.trim())
                        .where((value) => value.isNotEmpty)
                        .toList();
                    if (requiredGear.length != requiredGearControllers.length) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bitte alle Pflicht-Ausrustungseintraege ausfuellen.')),
                      );
                      return;
                    }
                    if (endAt!.isBefore(startAt!)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ende darf nicht vor Start liegen.')),
                      );
                      return;
                    }
                    if (powerLimits.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bitte mindestens ein Limit erfassen.')),
                      );
                      return;
                    }

                    _createEvent(
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      scenario: scenarioController.text.trim(),
                      organizer: organizerController.text.trim(),
                      startAt: startAt!,
                      endAt: endAt!,
                      minAge: minAgeController.text.trim(),
                      requiredGear: requiredGear,
                      medicContact: medicContactController.text.trim(),
                      powerLimits: powerLimits,
                      tickets: tickets,
                      location: locationLatLng!,
                      locationStreet: locationStreetController.text.trim(),
                      locationHouseNumber: locationHouseNumberController.text.trim(),
                      locationPostalcode: locationPostalcodeController.text.trim(),
                      locationCity: locationCityController.text.trim(),
                      locationState: locationStateController.text.trim(),
                      locationCountry: locationCountryController.text.trim(),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 41, 107, 43)),
                  child: const Text('Speichern', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditEventDialog(Map<String, dynamic> event) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: event['title']?.toString() ?? '');
    final descriptionController = TextEditingController(text: event['description']?.toString() ?? '');
    final locationStreetController = TextEditingController(text: event['location_street']?.toString() ?? '');
    final locationHouseNumberController = TextEditingController(text: event['location_house_number']?.toString() ?? '');
    final locationPostalcodeController = TextEditingController(text: event['location_postalcode']?.toString() ?? '');
    final locationCityController = TextEditingController(text: event['location_city']?.toString() ?? '');
    final locationStateController = TextEditingController(text: event['location_state']?.toString() ?? '');
    final locationCountryController = TextEditingController(text: event['location_country']?.toString() ?? '');
    final scenarioController = TextEditingController(text: event['scenario']?.toString() ?? '');
    final organizerController = TextEditingController(text: event['organizer']?.toString() ?? '');
    final minAgeController = TextEditingController(text: event['min_age']?.toString() ?? '');
    final medicContactController = TextEditingController(text: event['medic_contact']?.toString() ?? '');
    final requiredGearControllers = <TextEditingController>[];

    final startAt = _tryParseDateTime(event['start_at']?.toString() ?? '');
    final endAt = _tryParseDateTime(event['end_at']?.toString() ?? '');
    final lat = double.tryParse(event['location_lat']?.toString() ?? '');
    final lng = double.tryParse(event['location_lng']?.toString() ?? '');
    LatLng? locationLatLng = (lat != null && lng != null) ? LatLng(lat, lng) : null;

    final requiredGear = _parseRequiredGear(event['required_gear']);
    for (final item in requiredGear) {
      requiredGearControllers.add(TextEditingController(text: item));
    }

    final powerLimits = <_PowerLimitInput>[];
    final rawLimits = (event['power_limits'] as List?) ?? [];
    for (final raw in rawLimits) {
      final map = raw as Map<String, dynamic>;
      final requirement = map['requirement']?.toString();
      final input = _PowerLimitInput(
        requirement: _limitRequirementOptions.contains(requirement) ? requirement : _limitRequirementOptions.first,
      );
      input.classController.text = map['class_name']?.toString() ?? '';
      input.limitController.text = map['limit_value']?.toString() ?? '';
      input.distanceController.text = map['distance']?.toString() ?? '';
      powerLimits.add(input);
    }

    final tickets = <_TicketInput>[];
    final rawTickets = (event['tickets'] as List?) ?? [];
    for (final raw in rawTickets) {
      final map = raw as Map<String, dynamic>;
      final input = _TicketInput();
      input.labelController.text = map['label']?.toString() ?? '';
      input.priceController.text = map['price']?.toString() ?? '';
      input.currencyController.text = map['currency']?.toString() ?? 'EUR';
      input.notesController.text = map['notes']?.toString() ?? '';
      tickets.add(input);
    }

    DateTime? startAtValue = startAt;
    DateTime? endAtValue = endAt;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Event bearbeiten'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Titel'),
                        validator: (value) => value == null || value.isEmpty ? 'Titel erforderlich' : null,
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Beschreibung'),
                        maxLines: 3,
                        validator: (value) => value == null || value.isEmpty ? 'Beschreibung erforderlich' : null,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Ort', style: Theme.of(context).textTheme.titleMedium),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              locationLatLng == null
                                  ? 'Keine Position gesetzt.'
                                  : _formatLatLng(locationLatLng!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await Navigator.of(context).push<_EventLocationResult>(
                                MaterialPageRoute(
                                  builder: (_) => _EventLocationPickerPage(
                                    initialLocation: locationLatLng,
                                  ),
                                ),
                              );
                              if (picked != null) {
                                setState(() {
                                  locationLatLng = picked.location;
                                  locationStreetController.text = picked.street;
                                  locationHouseNumberController.text = picked.houseNumber;
                                  locationPostalcodeController.text = picked.postalcode;
                                  locationCityController.text = picked.city;
                                  locationStateController.text = picked.state;
                                  locationCountryController.text = picked.country;
                                });
                              }
                            },
                            icon: const Icon(Icons.map_outlined),
                            label: const Text('Karte'),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: locationStreetController,
                        decoration: const InputDecoration(labelText: 'Strasse'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Strasse erforderlich' : null,
                      ),
                      TextFormField(
                        controller: locationHouseNumberController,
                        decoration: const InputDecoration(labelText: 'Hausnummer'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Hausnummer erforderlich' : null,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: locationPostalcodeController,
                              decoration: const InputDecoration(labelText: 'PLZ'),
                              validator: (value) => value == null || value.trim().isEmpty ? 'PLZ erforderlich' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: locationCityController,
                              decoration: const InputDecoration(labelText: 'Ort'),
                              validator: (value) => value == null || value.trim().isEmpty ? 'Ort erforderlich' : null,
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: locationStateController,
                        decoration: const InputDecoration(labelText: 'Bundesland/Region (optional)'),
                      ),
                      TextFormField(
                        controller: locationCountryController,
                        decoration: const InputDecoration(labelText: 'Land'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Land erforderlich' : null,
                      ),
                      TextFormField(
                        controller: scenarioController,
                        decoration: const InputDecoration(labelText: 'Spielmodus/Scenario'),
                        validator: (value) => value == null || value.isEmpty ? 'Scenario erforderlich' : null,
                      ),
                      TextFormField(
                        controller: organizerController,
                        decoration: const InputDecoration(labelText: 'Veranstalter/Team'),
                        validator: (value) => value == null || value.isEmpty ? 'Veranstalter erforderlich' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final picked = await _pickDateTime(context, startAtValue);
                                if (picked != null) {
                                  setState(() => startAtValue = picked);
                                }
                              },
                              child: Text(startAtValue == null ? 'Start waehlen' : _formatDateTime(startAtValue!)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final picked = await _pickDateTime(context, endAtValue);
                                if (picked != null) {
                                  setState(() => endAtValue = picked);
                                }
                              },
                              child: Text(endAtValue == null ? 'Ende waehlen' : _formatDateTime(endAtValue!)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: minAgeController,
                        decoration: const InputDecoration(labelText: 'Mindestalter'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty ? 'Mindestalter erforderlich' : null,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Pflicht-Ausrustung', style: Theme.of(context).textTheme.titleMedium),
                      ),
                      if (requiredGearControllers.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 6.0, bottom: 6.0),
                          child: Text('Keine Pflicht-Ausrustung hinzugefuegt.'),
                        ),
                      for (int i = 0; i < requiredGearControllers.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: requiredGearControllers[i],
                                decoration: InputDecoration(labelText: 'Eintrag ${i + 1}'),
                                validator: (value) => value == null || value.isEmpty ? 'Eintrag erforderlich' : null,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      final removed = requiredGearControllers.removeAt(i);
                                      removed.dispose();
                                    });
                                  },
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  label: const Text('Eintrag entfernen', style: TextStyle(color: Colors.red)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() => requiredGearControllers.add(TextEditingController()));
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Pflicht-Ausrustung hinzufuegen'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Joule/FPS Limits', style: Theme.of(context).textTheme.titleMedium),
                      ),
                      const SizedBox(height: 6),
                      for (int i = 0; i < powerLimits.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: powerLimits[i].classController,
                                decoration: InputDecoration(labelText: 'Klasse ${i + 1}'),
                                validator: (value) => value == null || value.isEmpty ? 'Klasse erforderlich' : null,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: powerLimits[i].limitController,
                                      decoration: const InputDecoration(labelText: 'Limit'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      controller: powerLimits[i].distanceController,
                                      decoration: const InputDecoration(labelText: 'Abstand'),
                                      validator: (value) => value == null || value.isEmpty ? 'Abstand erforderlich' : null,
                                    ),
                                  ),
                                ],
                              ),
                              DropdownButtonFormField<String>(
                                initialValue: powerLimits[i].requirementValue,
                                decoration: const InputDecoration(labelText: 'Pflicht'),
                                items: _limitRequirementOptions
                                    .map(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() => powerLimits[i].requirementValue = value);
                                },
                                validator: (value) => value == null || value.isEmpty ? 'Pflicht erforderlich' : null,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      final removed = powerLimits.removeAt(i);
                                      removed.dispose();
                                    });
                                  },
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  label: const Text('Eintrag entfernen', style: TextStyle(color: Colors.red)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(
                              () => powerLimits.add(
                                _PowerLimitInput(requirement: _limitRequirementOptions.first),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Klasse hinzufuegen'),
                        ),
                      ),
                      TextFormField(
                        controller: medicContactController,
                        decoration: const InputDecoration(labelText: 'Sanitaeter/Notfallkontakt'),
                        validator: (value) => value == null || value.isEmpty ? 'Kontakt erforderlich' : null,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Tickets', style: Theme.of(context).textTheme.titleMedium),
                      ),
                      const SizedBox(height: 6),
                      if (tickets.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6.0),
                          child: Text('Noch keine Tickets hinzugefuegt.'),
                        ),
                      for (int i = 0; i < tickets.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: tickets[i].labelController,
                                decoration: InputDecoration(labelText: 'Ticket ${i + 1} Titel'),
                                validator: (value) => value == null || value.isEmpty ? 'Tickettitel erforderlich' : null,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: tickets[i].priceController,
                                      decoration: const InputDecoration(labelText: 'Preis'),
                                      keyboardType: TextInputType.number,
                                      validator: (value) => value == null || value.isEmpty ? 'Preis erforderlich' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 80,
                                    child: TextFormField(
                                      controller: tickets[i].currencyController,
                                      decoration: const InputDecoration(labelText: 'Waehrung'),
                                    ),
                                  ),
                                ],
                              ),
                              TextFormField(
                                controller: tickets[i].notesController,
                                decoration: const InputDecoration(labelText: 'Notizen (optional)'),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      final removed = tickets.removeAt(i);
                                      removed.dispose();
                                    });
                                  },
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  label: const Text('Ticket entfernen', style: TextStyle(color: Colors.red)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() => tickets.add(_TicketInput()));
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Ticket hinzufuegen'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Abbrechen'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    if (startAtValue == null || endAtValue == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bitte Start und Ende setzen.')),
                      );
                      return;
                    }
                    if (locationLatLng == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bitte die Position auf der Karte setzen.')),
                      );
                      return;
                    }
                    if (requiredGearControllers.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bitte Pflicht-Ausrustung hinzufuegen.')),
                      );
                      return;
                    }
                    final requiredGear = requiredGearControllers
                        .map((controller) => controller.text.trim())
                        .where((value) => value.isNotEmpty)
                        .toList();
                    if (requiredGear.length != requiredGearControllers.length) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bitte alle Pflicht-Ausrustungseintraege ausfuellen.')),
                      );
                      return;
                    }
                    if (endAtValue!.isBefore(startAtValue!)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ende darf nicht vor Start liegen.')),
                      );
                      return;
                    }
                    if (powerLimits.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bitte mindestens ein Limit erfassen.')),
                      );
                      return;
                    }

                    _updateEvent(
                      id: event['id'] is int ? event['id'] : int.parse(event['id'].toString()),
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      scenario: scenarioController.text.trim(),
                      organizer: organizerController.text.trim(),
                      startAt: startAtValue!,
                      endAt: endAtValue!,
                      minAge: minAgeController.text.trim(),
                      requiredGear: requiredGear,
                      medicContact: medicContactController.text.trim(),
                      powerLimits: powerLimits,
                      tickets: tickets,
                      location: locationLatLng!,
                      locationStreet: locationStreetController.text.trim(),
                      locationHouseNumber: locationHouseNumberController.text.trim(),
                      locationPostalcode: locationPostalcodeController.text.trim(),
                      locationCity: locationCityController.text.trim(),
                      locationState: locationStateController.text.trim(),
                      locationCountry: locationCountryController.text.trim(),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 41, 107, 43)),
                  child: const Text('Speichern', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _EventLocationResult {
  final LatLng location;
  final String? address;
  final String street;
  final String houseNumber;
  final String postalcode;
  final String city;
  final String state;
  final String country;

  const _EventLocationResult({
    required this.location,
    this.address,
    this.street = '',
    this.houseNumber = '',
    this.postalcode = '',
    this.city = '',
    this.state = '',
    this.country = '',
  });
}

class _EventLocationPickerPage extends StatefulWidget {
  final LatLng? initialLocation;

  const _EventLocationPickerPage({
    this.initialLocation,
  });

  @override
  State<_EventLocationPickerPage> createState() => _EventLocationPickerPageState();
}

class _EventLocationPickerPageState extends State<_EventLocationPickerPage> {
  static const List<Map<String, String>> _tileServers = [
    {
      'template': 'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
      'probe': 'https://tile.openstreetmap.de/0/0/0.png',
    },
    {
      'template': 'https://a.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
      'probe': 'https://a.tile.openstreetmap.fr/hot/0/0/0.png',
    },
    {
      'template': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      'probe': 'https://tile.openstreetmap.org/0/0/0.png',
    },
  ];

  final MapController _mapController = MapController();
  LatLng? _selected;
  String? _selectedAddress;
  String _street = '';
  String _houseNumber = '';
  String _postalcode = '';
  String _city = '';
  String _state = '';
  String _country = '';
  bool _isResolvingAddress = false;
  bool _isLoading = true;
  int _tileUrlIndex = 0;
  bool _tileFallbackNotified = false;
  bool _tileServerUnavailable = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    LatLng center = widget.initialLocation ?? const LatLng(51.1657, 10.4515);
    if (widget.initialLocation == null) {
      final permissionOk = await _ensureLocationPermission();
      if (permissionOk) {
        try {
          final lastKnown = await Geolocator.getLastKnownPosition();
          if (lastKnown != null) {
            center = LatLng(lastKnown.latitude, lastKnown.longitude);
          }

          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
          );
          center = LatLng(position.latitude, position.longitude);
        } catch (_) {
          // Keep default center.
        }
      }
    }

    await _selectAvailableTileServer();

    if (!mounted) return;
    setState(() {
      _selected = widget.initialLocation ?? center;
      _isLoading = false;
    });

    final selected = _selected;
    if (selected != null) {
      _resolveAddress(selected);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selected != null) {
        _mapController.move(_selected!, 14);
      }
    });
  }

  Future<bool> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnack('Standortdienste sind deaktiviert.');
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnack('Standortberechtigung verweigert.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnack('Standortberechtigung dauerhaft verweigert.');
      return false;
    }

    return true;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleTileLoadError() {
    if (!mounted) return;
    if (_tileUrlIndex < _tileServers.length - 1) {
      setState(() => _tileUrlIndex++);
      if (!_tileFallbackNotified) {
        _tileFallbackNotified = true;
        _showSnack('Kartenserver nicht erreichbar, alternativer Server wird verwendet.');
      }
      return;
    }

    if (!_tileFallbackNotified) {
      _tileFallbackNotified = true;
      _showSnack('Kartenkacheln konnten nicht geladen werden. Bitte Internet/DNS prüfen.');
    }
  }

  Future<void> _selectAvailableTileServer() async {
    for (var i = 0; i < _tileServers.length; i++) {
      final probeUrl = _tileServers[i]['probe'] ?? '';
      if (probeUrl.isEmpty) continue;
      try {
        final resp = await http
            .get(Uri.parse(probeUrl), headers: {'User-Agent': 'pewpew-connect/1.0'})
            .timeout(const Duration(seconds: 3));
        if (resp.statusCode >= 200 && resp.statusCode < 400) {
          if (!mounted) return;
          setState(() {
            _tileUrlIndex = i;
            _tileServerUnavailable = false;
          });
          return;
        }
      } catch (_) {
        // try next server
      }
    }

    if (!mounted) return;
    setState(() {
      _tileServerUnavailable = true;
    });
    _showSnack('Keine Kartenserver erreichbar. Bitte Internet/DNS prüfen.');
  }

  Future<void> _resolveAddress(LatLng location) async {
    setState(() => _isResolvingAddress = true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${location.latitude}&lon=${location.longitude}',
      );
      final resp = await http.get(uri, headers: {'User-Agent': 'pewpew-connect/1.0'});
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        final address = data['display_name']?.toString();
        final rawAddress = data['address'];
        final addressMap = rawAddress is Map ? rawAddress.cast<String, dynamic>() : <String, dynamic>{};
        final cityValue = (addressMap['city'] ?? addressMap['town'] ?? addressMap['village'] ?? addressMap['municipality'])?.toString() ?? '';
        if (mounted) {
          setState(() {
            _selectedAddress = address;
            _street = (addressMap['road'] ?? addressMap['pedestrian'] ?? addressMap['footway'] ?? '').toString();
            _houseNumber = (addressMap['house_number'] ?? '').toString();
            _postalcode = (addressMap['postcode'] ?? '').toString();
            _city = cityValue;
            _state = (addressMap['state'] ?? '').toString();
            _country = (addressMap['country'] ?? '').toString();
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _selectedAddress = 'Keine Adresse gefunden (offline/Netzwerkfehler).';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isResolvingAddress = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Position waehlen',
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
        actions: [
          TextButton(
            onPressed: selected == null
                ? null
                : () => Navigator.of(context).pop(
                      _EventLocationResult(
                        location: selected,
                        address: _selectedAddress,
                        street: _street,
                        houseNumber: _houseNumber,
                        postalcode: _postalcode,
                        city: _city,
                        state: _state,
                        country: _country,
                      ),
                    ),
            child: const Text('Speichern', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: selected ?? const LatLng(51.1657, 10.4515),
                    initialZoom: 14,
                    minZoom: 5,
                    maxZoom: 19,
                    onTap: (tapPosition, latLng) {
                      setState(() => _selected = latLng);
                      _resolveAddress(latLng);
                    },
                  ),
                  children: [
                    if (!_tileServerUnavailable)
                      TileLayer(
                        urlTemplate: _tileServers[_tileUrlIndex]['template']!,
                        userAgentPackageName: 'com.pewpew.connect',
                        minZoom: 5,
                        maxZoom: 19,
                        keepBuffer: 2,
                        errorTileCallback: (_, __, ___) => _handleTileLoadError(),
                      ),
                    if (selected != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: selected,
                            width: 44,
                            height: 44,
                            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution('OpenStreetMap contributors'),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _isResolvingAddress
                          ? 'Adresse wird ermittelt...'
                          : (_selectedAddress?.trim().isNotEmpty == true
                              ? _selectedAddress!
                              : 'Keine Adresse gefunden.'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _TicketInput {
  final TextEditingController labelController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController currencyController = TextEditingController(text: 'EUR');
  final TextEditingController notesController = TextEditingController();

  void dispose() {
    labelController.dispose();
    priceController.dispose();
    currencyController.dispose();
    notesController.dispose();
  }

  Map<String, dynamic> toJson() {
    return {
      'label': labelController.text.trim(),
      'price': priceController.text.trim(),
      'currency': currencyController.text.trim().isEmpty ? 'EUR' : currencyController.text.trim(),
      'notes': notesController.text.trim(),
    };
  }
}

class _PowerLimitInput {
  final TextEditingController classController;
  final TextEditingController limitController;
  final TextEditingController distanceController;
  String? requirementValue;

  _PowerLimitInput({String? requirement})
      : classController = TextEditingController(),
        limitController = TextEditingController(),
        distanceController = TextEditingController(),
        requirementValue = requirement;

  void dispose() {
    classController.dispose();
    limitController.dispose();
    distanceController.dispose();
  }

  Map<String, dynamic> toJson() {
    return {
      'class_name': classController.text.trim(),
      'limit_value': limitController.text.trim(),
      'distance': distanceController.text.trim(),
      'requirement': requirementValue?.trim() ?? '',
    };
  }
}