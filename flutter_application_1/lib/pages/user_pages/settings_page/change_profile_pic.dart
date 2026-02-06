import 'package:http/http.dart' as http;
import 'package:pewpew_connect/service/imports.dart'; 

class ImageUploadPage extends StatefulWidget {
  final String username;

  const ImageUploadPage({super.key, required this.username});

  @override
  State<ImageUploadPage> createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  File? _selectedImage;
  bool _isProcessing = false;

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile == null) return;
      await _cropImage(pickedFile.path);
    } catch (e) {
      _showSnackBar('Fehler beim Auswählen: $e', isError: true);
    }
  }

  Future<void> _cropImage(String path) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Bild zuschneiden',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Zuschneiden',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _selectedImage = File(croppedFile.path);
        });
      }
    } catch (e) {
      _showSnackBar('Fehler beim Zuschneiden: $e', isError: true);
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;
    setState(() => _isProcessing = true);

    try {
      final url = Uri.parse('$ipAddress/update_profile_pic.php');
      final request = http.MultipartRequest('POST', url);
      request.fields['username'] = widget.username;
      request.files.add(
        await http.MultipartFile.fromPath('profile_pic', _selectedImage!.path),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Upload-Zeitüberschreitung'),
      );

      final response = await http.Response.fromStream(streamedResponse);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _showSnackBar('Profilbild erfolgreich aktualisiert!');
        if (mounted) Navigator.of(context).pop(true);
      } else {
        _showSnackBar('Fehler: ${data['message']}', isError: true);
      }
    } catch (e) {
      _showSnackBar('Upload-Fehler: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : const Color.fromARGB(255, 41, 107, 43),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // WICHTIG: Hintergrundfarbe des Scaffolds auf transparent setzen
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Profilbild ändern', 
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_selectedImage != null && !_isProcessing)
            IconButton(
              icon: const Icon(Icons.check, size: 32, color: Colors.white),
              onPressed: _uploadImage,
            ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/app_bgr2.jpg'), 
              fit: BoxFit.cover
            ),
          ),
        ),
      ),
      // Der Container füllt den gesamten Body und setzt den Hintergrund
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/app_bgr.jpg'),
            fit: BoxFit.cover,
            opacity: 0.8, // Deine gewünschte Opacity
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _isProcessing ? null : _pickImage,
                  child: CircleAvatar(
                    radius: 110,
                    backgroundColor: Colors.white24,
                    backgroundImage: _selectedImage != null 
                        ? FileImage(_selectedImage!) 
                        : null,
                    child: _selectedImage == null
                        ? const Icon(Icons.camera_alt, size: 60, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 50),
                if (_isProcessing)
                  const CircularProgressIndicator(color: Colors.white)
                else ...[
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: Text(_selectedImage == null ? 'Bild auswählen' : 'Bild ändern'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.8),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                  if (_selectedImage != null) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Klicke auf den grünen Haken oben,\num die Änderungen zu speichern.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white, 
                        fontStyle: FontStyle.italic,
                        shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}