import 'package:http/http.dart' as http;
import 'package:pewpew_connect/service/imports.dart';
import 'package:latlong2/latlong.dart';

class FieldMapPage extends StatefulWidget {
  final String? destinationName;
  final String? destinationAddress;
  final String? currentUsername;

  const FieldMapPage({
    super.key,
    this.destinationName,
    this.destinationAddress,
    this.currentUsername,
  });

  @override
  State<FieldMapPage> createState() => _FieldMapPageState();
}

class _FieldMapPageState extends State<FieldMapPage> {
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionSub;
  final Distance _distanceCalc = const Distance();

  LatLng? _currentLatLng;
  LatLng? _destinationLatLng;
  String? _distanceText;
  String? _durationText;
  String? _infoError;
  String? _statusMessage;
  double? _accuracyMeters;

  bool _isLoading = true;
  bool _followUser = true;
  double _currentZoom = 14.0;
  DateTime? _lastUiUpdate;
  DateTime? _lastCameraMove;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    final trace = await PerformanceService.instance.startTrace('map_load');
    try {
      final permissionOk = await _ensureLocationPermission();
      if (!permissionOk) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      _currentLatLng = LatLng(position.latitude, position.longitude);
      _accuracyMeters = position.accuracy;

      if (widget.destinationAddress != null && widget.destinationAddress!.trim().isNotEmpty) {
        _destinationLatLng = await _geocodeAddress(widget.destinationAddress!.trim());
        _updateDistanceEstimate();
        _infoError = _destinationLatLng == null ? 'Adresse nicht gefunden.' : null;
      } else {
        _infoError = 'Keine Zieladresse vorhanden.';
      }

      _startPositionStream();

      if (mounted) setState(() => _isLoading = false);
    } finally {
      await PerformanceService.instance.stopTrace(trace);
    }
  }

  Future<bool> _ensureLocationPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack('Standortdienste sind deaktiviert. Bitte aktivieren.');
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
        _showSnack('Standortberechtigung dauerhaft verweigert. Bitte App-Berechtigungen ändern.');
        return false;
      }

      return true;
    } catch (e) {
      _showSnack('Fehler bei Standort-Berechtigungen: $e');
      return false;
    }
  }

  void _startPositionStream() {
    _positionSub?.cancel();
    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );

    _positionSub = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen((position) {
      _currentLatLng = LatLng(position.latitude, position.longitude);
      _accuracyMeters = _normalizeAccuracy(position.accuracy);
      _updateDistanceEstimate();
      final now = DateTime.now();
      final lastUi = _lastUiUpdate;
      if (lastUi == null || now.difference(lastUi).inMilliseconds >= 120) {
        if (mounted) setState(() {});
        _lastUiUpdate = now;
      }

      if (_followUser && _currentLatLng != null) {
        final lastMove = _lastCameraMove;
        if (lastMove == null || now.difference(lastMove).inMilliseconds >= 220) {
          final current = _currentLatLng;
          if (current != null) _mapController.move(current, _currentZoom);
          _lastCameraMove = now;
        }
      }
    });
  }

  Future<LatLng?> _geocodeAddress(String address) async {
    _setStatus('Ziel wird gesucht...');

    final List<String> queries = [
      address,
      '$address, Deutschland',
      '$address, Germany',
    ];

    final parts = address.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      final cityOnly = parts.last;
      queries.add(cityOnly);
      queries.add('$cityOnly, Deutschland');
    }

    for (final query in queries.toSet()) {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=jsonv2&limit=1&q=${Uri.encodeComponent(query)}',
      );

      try {
        final resp = await _getWithRetry(uri);
        if (resp == null || resp.statusCode != 200) continue;

        final data = json.decode(resp.body) as List<dynamic>;
        if (data.isEmpty) continue;

        final entry = data[0] as Map<String, dynamic>;
        final lat = double.tryParse(entry['lat']?.toString() ?? '');
        final lon = double.tryParse(entry['lon']?.toString() ?? '');
        if (lat == null || lon == null) continue;

        _setStatus(null);
        return LatLng(lat, lon);
      } catch (_) {
        // ignore and try next query
      }

      // be gentle with Nominatim rate limits
      await Future<void>.delayed(const Duration(milliseconds: 1100));
    }

    _setStatus(null);
    return null;
  }

  Future<void> _saveCurrentCity() async {
    if (widget.currentUsername == null || widget.currentUsername == 'Gast') {
      _showSnack('Bitte zuerst einloggen.');
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${position.latitude}&lon=${position.longitude}',
      );
      final resp = await http.get(uri, headers: {'User-Agent': 'pewpew-connect/1.0'});
      if (resp.statusCode != 200) {
        _showSnack('Fehler beim Reverse-Geocoding.');
        return;
      }

      final data = json.decode(resp.body) as Map<String, dynamic>;
      final address = data['address'] as Map<String, dynamic>? ?? {};
      String detected = (address['city'] ?? address['town'] ?? address['village'] ?? data['display_name'] ?? '').toString();

      if (detected.isEmpty) {
        _showSnack('Kein Standort gefunden.');
        return;
      }

      if (!mounted) return;
      final save = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Standort erkannt'),
          content: Text('Erkannter Standort: $detected\nSoll dieser als Standort gespeichert werden?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Abbrechen')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Speichern')),
          ],
        ),
      );

      if (save == true) {
        final resp2 = await http.post(
          Uri.parse('$ipAddress/change_city.php'),
          body: {'username': widget.currentUsername!, 'new_city': detected},
        );
        final data2 = json.decode(resp2.body) as Map<String, dynamic>;
        if (!mounted) return;
        if (data2['success'] == true) {
          _showSnack(data2['message']?.toString() ?? 'Standort gespeichert');
          Navigator.pop(context, detected);
        } else {
          _showSnack(data2['message']?.toString() ?? 'Fehler beim Speichern');
        }
      }
    } catch (e) {
      _showSnack('Fehler beim Ermitteln des Standorts: $e');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _setStatus(String? message) {
    if (!mounted) return;
    setState(() => _statusMessage = message);
  }

  double _normalizeAccuracy(double accuracy) {
    return accuracy.clamp(3.0, 150.0);
  }

  Future<http.Response?> _getWithRetry(
    Uri uri, {
    int attempts = 2,
    int timeoutSeconds = 10,
  }) async {
    for (var i = 0; i < attempts; i++) {
      try {
        final resp = await http
            .get(uri, headers: {'User-Agent': 'pewpew-connect/1.0'})
            .timeout(Duration(seconds: timeoutSeconds));
        return resp;
      } on TimeoutException {
        if (i == attempts - 1) return null;
      } catch (_) {
        if (i == attempts - 1) return null;
      }
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
    return null;
  }

  String _formatDistance(num meters) {
    if (meters < 1000) return '${meters.round()} m';
    final km = meters / 1000.0;
    return '${km.toStringAsFixed(1).replaceAll('.', ',')} km';
  }

  String _formatDurationMinutes(num minutes) {
    final rounded = minutes.round();
    if (rounded < 1) return '<1 min';
    if (rounded < 60) return '$rounded min';
    final hours = rounded ~/ 60;
    final remMin = rounded % 60;
    return '$hours h $remMin min';
  }

  void _updateDistanceEstimate() {
    final current = _currentLatLng;
    final dest = _destinationLatLng;
    if (current == null || dest == null) return;
    final meters = _distanceCalc(current, dest);
    _distanceText = _formatDistance(meters);
    _durationText = _estimateDuration(meters);
  }

  String _estimateDuration(num meters) {
    final km = meters / 1000.0;
    final speedKmh = km < 5 ? 25.0 : 50.0;
    final minutes = (km / speedKmh) * 60.0;
    return 'ca. ${_formatDurationMinutes(minutes)}';
  }

  Future<void> _openExternalMaps() async {
    final origin = _currentLatLng;
    final dest = _destinationLatLng;
    if (origin == null || dest == null) {
      _showSnack('Start oder Ziel fehlt.');
      return;
    }

    AnalyticsService.instance.logEvent('route_started', parameters: {
      'destination': widget.destinationName ?? 'unknown',
    });

    final directionsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=${origin.latitude},${origin.longitude}&destination=${dest.latitude},${dest.longitude}',
    );

    if (!await launchUrl(directionsUrl, mode: LaunchMode.externalApplication)) {
      _showSnack('Konnte Google Maps nicht oeffnen.');
    }
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];
    final current = _currentLatLng;
    if (current != null) {
      markers.add(
        Marker(
          point: current,
          width: 40,
          height: 40,
          child: const Icon(Icons.my_location, color: Colors.blue, size: 28),
        ),
      );
    }

    final dest = _destinationLatLng;
    if (dest != null) {
      markers.add(
        Marker(
          point: dest,
          width: 40,
          height: 40,
          child: const Icon(Icons.location_on, color: Colors.red, size: 32),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentLatLng;
    final accuracy = _accuracyMeters;
    final initial = current ?? const LatLng(0, 0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.destinationName ?? 'Karte',
          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
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
            tooltip: 'Standort speichern',
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _saveCurrentCity,
          ),
          IconButton(
            tooltip: _followUser ? 'Kamera fixieren' : 'Kamera folgen',
            icon: Icon(_followUser ? Icons.my_location : Icons.location_searching, color: Colors.white),
            onPressed: () {
              setState(() => _followUser = !_followUser);
              final currentPos = _currentLatLng;
              if (_followUser && currentPos != null) {
                _mapController.move(currentPos, _currentZoom);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initial,
              initialZoom: _currentZoom,
              minZoom: 5,
              maxZoom: 19,
              onPositionChanged: (position, hasGesture) {
                _currentZoom = position.zoom;
                if (hasGesture && _followUser) setState(() => _followUser = false);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.pewpew.connect',
                minZoom: 5,
                maxZoom: 19,
                keepBuffer: 2,
              ),
              if (current != null && accuracy != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: current,
                      useRadiusInMeter: true,
                      radius: accuracy,
                      color: Colors.blue.withValues(alpha: 0.15),
                      borderColor: Colors.blue.withValues(alpha: 0.4),
                      borderStrokeWidth: 1,
                    ),
                  ],
                ),
              MarkerLayer(markers: _buildMarkers()),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          if (_statusMessage != null)
            Positioned(
              left: 12,
              right: 12,
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _statusMessage ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_isLoading)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black26,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          if (_distanceText != null || _durationText != null || _infoError != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: _RouteInfoCard(
                distance: _distanceText,
                duration: _durationText,
                error: _infoError,
                onNavigate: _openExternalMaps,
              ),
            ),
          Positioned(
            right: 12,
            bottom: (_distanceText != null || _durationText != null) ? 170 : 12,
            child: FloatingActionButton(
              heroTag: 'center',
              onPressed: () {
                if (current != null) {
                  _mapController.move(current, 15);
                }
              },
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteInfoCard extends StatelessWidget {
  final String? distance;
  final String? duration;
  final String? error;
  final VoidCallback onNavigate;

  const _RouteInfoCard({
    this.distance,
    this.duration,
    this.error,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.pin_drop, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${distance ?? '-'} / ${duration ?? '-'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Entfernung als Luftlinie, Dauer als Schaetzung',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  error ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: onNavigate,
                  icon: const Icon(Icons.directions),
                  label: const Text('Route in Maps starten'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
