import 'package:http/http.dart' as http;
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NEU: Firmenname als hervorgehobener Titel
            Text(
              widget.field.company,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),
            
            // NEU: Informationen in Cards gruppiert
            _buildDetailCard(
              icon: Icons.location_on,
              title: 'Adresse',
              content: '${widget.field.street} ${widget.field.housenumber}, ${widget.field.city}',
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
    );
  }
}