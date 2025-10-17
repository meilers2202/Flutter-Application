import 'package:http/http.dart' as http;
import 'package:pewpew_connect/service/imports.dart';
import 'dart:async';

// Annahme: ipAddress ist global definiert oder über DI bereitgestellt

class ImageUploadPage extends StatefulWidget {
  final String username;

  const ImageUploadPage({super.key, required this.username});

  @override
  State<ImageUploadPage> createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  XFile? _pickedImage;
  bool _isUploading = false;

  // 🔴 HARDCODED PFAD NUR FÜR TESTS – IMMER ENTFERNEN IN PRODUKTION!
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery, // oder ImageSource.camera
        maxWidth: 1080,              // optional: Bildgröße begrenzen
        maxHeight: 1080,
        imageQuality: 85,            // Komprimierung (1–100)
      );

      if (pickedFile != null) {
        setState(() {
          _pickedImage = pickedFile;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bild ausgewählt!')),
          );
        }
      }
      // Wenn der Benutzer abbricht (null), passiert nichts
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Auswählen des Bildes: $e')),
        );
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kein Bild ausgewählt.')),
      );
      return;
    }

    final file = File(_pickedImage!.path);
    if (!await file.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ausgewählte Datei existiert nicht mehr.')),
      );
      return;
    }

    if (file.lengthSync() > 5 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datei darf max. 5 MB groß sein.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final url = Uri.parse('$ipAddress/update_profile_pic.php');
      final request = http.MultipartRequest('POST', url);
      request.fields['username'] = widget.username;

      final bytes = await file.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'profile_pic',
        bytes,
        filename: _pickedImage!.name,
      );
      request.files.add(multipartFile);

      // Timeout hinzufügen (schützt vor hängenden Anfragen)
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Upload-Zeitüberschreitung nach 30 Sekunden.');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      // Prüfe auf gültige JSON
      Map<String, dynamic> data;
      try {
        data = json.decode(response.body);
      } catch (e) {
        throw Exception('Ungültige Serverantwort: ${response.body}');
      }

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Profilbild erfolgreich aktualisiert!')),
        );
        if (mounted) Navigator.of(context).pop(true);
      } else {
        final msg = data['message'] ?? 'Unbekannter Serverfehler.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Upload fehlgeschlagen: $msg')),
        );
      }

    } on TimeoutException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⏰ $e')),
      );
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🌐 Keine Internetverbindung.')),
      );
    } on http.ClientException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('📡 Netzwerkfehler: ${e.message}')),
      );
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('💥 Fehler: $errorMsg')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profilbild ändern')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_pickedImage != null)
              SizedBox(
                width: 250,
                height: 250,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_pickedImage!.path),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              const Text('Kein Bild ausgewählt'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Testbild laden (Hardcoded)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isUploading ? Colors.grey : Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              icon: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(
                _isUploading ? 'Lädt...' : 'Bild hochladen',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}