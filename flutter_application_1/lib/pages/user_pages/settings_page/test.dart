// lib/pages/user_pages/settings_page/image_upload_page.dart

import 'package:pewpew_connect/service/imports.dart';

class ImageUploadPage extends StatefulWidget {
  const ImageUploadPage({super.key});

  @override
  State<ImageUploadPage> createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  XFile? _pickedImage; // 👈 Lokale Datei, keine URL!

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    
    if (picked != null) {
      setState(() {
        _pickedImage = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bild auswählen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_pickedImage != null)
              SizedBox(
                width: 250,
                height: 450,
                child: Image.file(
                  File(_pickedImage!.path), // 👈 Lokales Bild anzeigen
                  fit: BoxFit.contain,
                ),
              )
            else
              const Text('Noch kein Bild ausgewählt'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Bild aus Galerie wählen'),
            ),
          ],
        ),
      ),
    );
  }
}