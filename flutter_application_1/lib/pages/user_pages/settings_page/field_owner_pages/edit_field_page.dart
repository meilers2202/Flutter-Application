import 'package:http/http.dart' as http;
import 'package:pewpew_connect/service/imports.dart';

class EditFieldPage extends StatefulWidget {
  final Field field;

  const EditFieldPage({
    super.key,
    required this.field,
  });

  @override
  State<EditFieldPage> createState() => _EditFieldPageState();
}

class _EditFieldPageState extends State<EditFieldPage> {
  final _formKey = GlobalKey<FormState>();

  // Controller für die Felder, initialisiert mit den aktuellen Werten
  late TextEditingController _fieldnameController;
  late TextEditingController _descriptionController;
  late TextEditingController _rulesController;
  late TextEditingController _streetController;
  late TextEditingController _housenumberController;
  late TextEditingController _postalcodeController;
  late TextEditingController _cityController;
  late TextEditingController _companyController;
  bool _teamsLoading = true;
  List<Map<String, dynamic>> _teams = [];
  int? _selectedHomeTeamId;
  List<Map<String, dynamic>> _images = [];
  bool _imagesLoading = true;
  String? _imagesError;
  bool _imageUploading = false;

  @override
  void initState() {
    super.initState();
    // Initialisierung der Controller mit den Werten des übergebenen Feldes
    _fieldnameController = TextEditingController(text: widget.field.fieldname);
    _descriptionController = TextEditingController(text: widget.field.description);
    _rulesController = TextEditingController(text: widget.field.rules);
    _streetController = TextEditingController(text: widget.field.street);
    _housenumberController = TextEditingController(text: widget.field.housenumber);
    _postalcodeController = TextEditingController(text: widget.field.postalcode);
    _cityController = TextEditingController(text: widget.field.city);
    _companyController = TextEditingController(text: widget.field.company);
    _selectedHomeTeamId = widget.field.homeTeamId;
    _fetchTeams();
    _fetchImages();
  }

  Future<void> _fetchTeams() async {
    final url = Uri.parse('$ipAddress/get_teams.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && mounted) {
          final rawTeams = (data['teams'] as List?) ?? [];
          setState(() {
            _teams = rawTeams
                .map((t) => Map<String, dynamic>.from(t as Map))
                .toList();
            _teamsLoading = false;
          });
        } else if (mounted) {
          setState(() => _teamsLoading = false);
        }
      } else if (mounted) {
        setState(() => _teamsLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _teamsLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _fieldnameController.dispose();
    _descriptionController.dispose();
    _rulesController.dispose();
    _streetController.dispose();
    _housenumberController.dispose();
    _postalcodeController.dispose();
    _cityController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _fetchImages() async {
    final url = Uri.parse('$ipAddress/get_field_images.php');
    try {
      final response = await http.post(url, body: {'field_id': widget.field.id.toString()});
      if (!mounted) return;
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2000,
      );
      if (picked == null) return;
      await _uploadImage(File(picked.path));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bildauswahl fehlgeschlagen: $e')),
      );
    }
  }

  Future<void> _uploadImage(File file) async {
    final url = Uri.parse('$ipAddress/add_field_image.php');
    setState(() => _imageUploading = true);
    try {
      final request = http.MultipartRequest('POST', url)
        ..fields['field_id'] = widget.field.id.toString()
        ..files.add(await http.MultipartFile.fromPath('image', file.path));

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Upload-Zeitueberschreitung'),
      );

      final response = await http.Response.fromStream(streamedResponse);
      final body = response.body;
      if (!mounted) return;

      if (body.trim().isEmpty) {
        setState(() => _imageUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leere Server-Antwort (add_field_image.php).')),
        );
        return;
      }

      final Map<String, dynamic> data = json.decode(body);
      setState(() => _imageUploading = false);
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Bild hinzugefuegt.')),
        );
        _fetchImages();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Fehler beim Hochladen.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _imageUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verbindungsfehler: $e')),
      );
    }
  }

  Future<void> _deleteImage(int imageId) async {
    final url = Uri.parse('$ipAddress/delete_field_image.php');
    try {
      final response = await http.post(url, body: {'id': imageId.toString()});
      if (!mounted) return;
      if (response.body.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leere Server-Antwort (delete_field_image.php).')),
        );
        return;
      }

      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Bild geloescht.')),
        );
        _fetchImages();
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

  Future<void> _updateField() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final url = Uri.parse('$ipAddress/update_field.php');

    try {
      final response = await http.post(
        url,
        body: {
          'id': widget.field.id.toString(), // WICHTIG: Die ID muss gesendet werden
          'fieldname': _fieldnameController.text,
          'description': _descriptionController.text,
          'rules': _rulesController.text,
          'street': _streetController.text,
          'housenumber': _housenumberController.text,
          'postalcode': _postalcodeController.text,
          'city': _cityController.text,
          'company': _companyController.text,
          'home_team_id': _selectedHomeTeamId?.toString() ?? '',
        },
      );

      if (!mounted) return;
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Feld erfolgreich aktualisiert: ${data['message']}')),
        );
        // Nach erfolgreicher Aktualisierung zur vorherigen Seite zurückkehren
        Navigator.of(context).pop(true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Aktualisieren: ${data['message']}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verbindungsfehler: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        
        title: Text(
          'Feld bearbeiten: \n${widget.field.fieldname}',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/app_bgr2.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (isDark)
              Container(color: Colors.black.withValues(alpha: 0.45)),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/app_bgr.jpg'),
                fit: BoxFit.cover,
                colorFilter: isDark
                  ? ColorFilter.mode(Colors.black.withValues(alpha: 0.5), BlendMode.darken)
                  : null,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildTextField(_companyController, 'Firma', isMultiLine: false),
                      _buildHomeTeamDropdown(),
                      _buildTextField(_fieldnameController, 'Feldname', isMultiLine: false),
                      _buildTextField(_descriptionController, 'Beschreibung', isMultiLine: true),
                      _buildTextField(_rulesController, 'Regeln', isMultiLine: true),
                      const Divider(height: 30),
                      _buildTextField(_streetController, 'Straße', isMultiLine: false),
                      _buildTextField(_housenumberController, 'Hausnummer', isMultiLine: false),
                      _buildTextField(_postalcodeController, 'PLZ', isMultiLine: false),
                      _buildTextField(_cityController, 'Stadt', isMultiLine: false),
                      const SizedBox(height: 20),

                      _buildImageSection(),
                      const SizedBox(height: 20),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateField,
                          child: const Text('ÄNDERUNGEN SPEICHERN'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {required bool isMultiLine}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? Colors.black.withValues(alpha: 0.65) : Colors.white.withValues(alpha: 0.8);
    final labelColor = isDark ? Colors.white70 : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: isMultiLine ? 5 : 1,
        minLines: isMultiLine ? 3 : 1,
        keyboardType: isMultiLine ? TextInputType.multiline : TextInputType.text,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: labelColor),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          // Min width 100, max width 500, default 200
          constraints: BoxConstraints(
            minWidth: 100,
            maxWidth: 500,
          ),
          fillColor: fillColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Bitte geben Sie $labelText ein.';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildHomeTeamDropdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? Colors.black.withValues(alpha: 0.65) : Colors.white.withValues(alpha: 0.8);
    final labelColor = isDark ? Colors.white70 : Colors.black87;
    if (_teamsLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(height: 56, child: Center(child: CircularProgressIndicator())),
      );
    }

    final items = <DropdownMenuItem<int?>>[
      const DropdownMenuItem<int?>(
        value: null,
        child: Text('Kein Heimteam'),
      ),
      ..._teams.map((t) {
        final id = int.tryParse(t['id'].toString());
        final name = t['name']?.toString() ?? 'Unbekannt';
        return DropdownMenuItem<int?>(
          value: id,
          child: Text(name),
        );
      }),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<int?>(
        initialValue: _selectedHomeTeamId,
        items: items,
        onChanged: (value) => setState(() => _selectedHomeTeamId = value),
        decoration: InputDecoration(
          labelText: 'Heimteam',
          labelStyle: TextStyle(color: labelColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          constraints: const BoxConstraints(
            minWidth: 100,
            maxWidth: 500,
          ),
          fillColor: fillColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),
      ),
    );
  }

Widget _buildImageSection() {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final fillColor = isDark ? Colors.black.withValues(alpha: 0.65) : Colors.white.withValues(alpha: 0.8);
  final labelColor = isDark ? Colors.white70 : Colors.black87;
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
      borderRadius: BorderRadius.circular(8.0),
      color: fillColor,
    ),
    padding: const EdgeInsets.all(12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bilder',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: labelColor),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _imageUploading ? null : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library, color: Colors.white),
                label: const Text('Aus Galerie', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 41, 107, 43)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _imageUploading ? null : () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.photo_camera, color: Colors.white),
                label: const Text('Kamera', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 41, 107, 43)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_imageUploading)
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: LinearProgressIndicator(),
          ),
        if (_imagesLoading)
          const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()))
        else if (_imagesError != null)
          Text(_imagesError!, style: const TextStyle(color: Colors.red))
        else if (_images.isEmpty)
          Text('Keine Bilder vorhanden.', style: TextStyle(color: labelColor))
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _images.map(_buildEditableImageTile).toList(),
          ),
      ],
    ),
  );
}

  Widget _buildEditableImageTile(Map<String, dynamic> image) {
    final id = int.tryParse(image['id']?.toString() ?? '');
    final resolvedUrl = _resolveImageUrl(image['image_url']?.toString() ?? '');
    return Stack(
      children: [
        Container(
          width: 140,
          height: 90,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.black12,
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
        Positioned(
          top: 6,
          right: 6,
          child: InkWell(
            onTap: id == null ? null : () => _deleteImage(id),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  String _resolveImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '$ipAddress$url';
    return '$ipAddress/$url';
  }
}