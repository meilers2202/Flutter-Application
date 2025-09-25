import 'package:flutter/material.dart';
// Importieren Sie die Field-Klasse aus Ihrer field_owner_main.dart
// Der Importpfad muss angepasst werden!
import '../field_owner_pages/field_owner_main.dart'; 

class FieldDetailsPage extends StatelessWidget {
  final Field field;

  const FieldDetailsPage({
    super.key,
    required this.field,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: Text(
          field.fieldname,
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
          children: [
            Text(
              field.company,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Adresse:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
            Text('${field.street} ${field.housenumber}, ${field.city}'),
            const SizedBox(height: 20),
            Text(
              'Beschreibung:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
            Text(field.description),
            const SizedBox(height: 20),
            // Hier könnten Sie weitere Details wie Regeln oder Bearbeitungs-Buttons hinzufügen
            Text(
              'Regeln:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
            Text(field.rules),
            ElevatedButton(
              onPressed: () {
                // NEUE LOGIK: Navigieren zur Bearbeitungsseite
                Navigator.of(context).pushNamed(
                  '/editfield',
                  arguments: field, // Das aktuelle Feld-Objekt übergeben
                );
              },
              child: const Text('Feld bearbeiten'),
            ),
          ],
        ),
      ),
    );
  }
}