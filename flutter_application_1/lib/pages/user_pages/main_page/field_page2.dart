import 'package:http/http.dart' as http;
import 'package:pewpew_connect/service/imports.dart';

class Fields2 {
  final int id;
  final String fieldname;
  final String? description;
  final String? rules;
  final String? street;
  final String? housenumber;
  final String? postalcode;
  final String? city;
  final String? company;
  final int fieldOwnerId;
  final int checkstate;

  Fields2({
    required this.id,
    required this.fieldname,
    this.description,
    this.rules,
    this.street,
    this.housenumber,
    this.postalcode,
    this.city,
    this.company,
    required this.fieldOwnerId,
    required this.checkstate,
  });

  // Factory-Methode zum Erstellen eines Field-Objekts aus JSON-Daten
  factory Fields2.fromJson(Map<String, dynamic> json) {
    return Fields2(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      fieldname: json['fieldname'] as String,
      description: json['description'] as String?,
      rules: json['rules'] as String?,
      street: json['street'] as String?,
      housenumber: json['housenumber'] as String?,
      postalcode: json['postalcode'] as String?,
      city: json['city'] as String?,
      company: json['company'] as String?,
      fieldOwnerId: json['field_owner_id'] is int ? json['field_owner_id'] : int.parse(json['field_owner_id'].toString()),
      checkstate: json['checkstate'] is int ? json['checkstate'] : int.parse(json['checkstate'].toString()),
    );
  }
}

class FieldListPage extends StatefulWidget {
  const FieldListPage({super.key});

  @override
  State<FieldListPage> createState() => _FieldListState();
}

class _FieldListState extends State<FieldListPage> {
  List<Fields2> _fields = []; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllFields();
  }

  // Ruft alle Felder vom Backend ab (Bleibt unverändert)
  Future<void> _fetchAllFields() async {
    final trace = await PerformanceService.instance.startTrace('field_list_load');
    final url = Uri.parse('$ipAddress/get_fields.php');
    try {
      final response = await http.post(url); 
      
      if (response.statusCode != 200) {
        throw Exception('HTTP Error ${response.statusCode}');
      }
      
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        if (mounted) {
          setState(() {
            _fields = (data['fields'] as List)
                .map((fieldJson) => Fields2.fromJson(fieldJson))
                .where((field) => field.checkstate == 1) // Nur genehmigte Felder
                .toList();
            _isLoading = false;
          });
          AnalyticsService.instance.logEvent('field_list_loaded', parameters: {
            'count': _fields.length,
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verbindungs- oder Parsfehler: $e')),
        );
      }
    }
    await PerformanceService.instance.stopTrace(trace);
  }

  // Die _updateFieldStatus-Funktion wird nun nur noch von FieldReviewPage aufgerufen,
  // aber wir behalten sie hier, falls sie für andere Zwecke gebraucht wird.
  // Ich habe sie entfernt, da sie logisch zur FieldReviewPage gehört.
  // Wenn Sie die Funktion hier benötigen, fügen Sie sie wieder ein.
  
  // Hilfsfunktion zur Übersetzung des Status-Integers (Bleibt unverändert)
  String _getCheckstateText(int state) {
    switch (state) {
      case 0: return 'In Prüfung';
      case 1: return 'Genehmigt';
      case 2: return 'In Klärung';
      case 3: return 'Abgelehnt';
      default: return 'Unbekannt';
    }
  }
  
  // ACHTUNG: Die _showStatusDialog Funktion wurde entfernt,
  // da wir stattdessen zur FieldReviewPage navigieren.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alle Spielfelder',
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _fields.isEmpty
              ? const Center(
                  child: Text(
                    'Keine Felder gefunden.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: _fields.length,
                  itemBuilder: (context, index) {
                    final field = _fields[index];
                    final checkStateText = _getCheckstateText(field.checkstate);
                    
                    return ListTile(
                      title: Text(
                        field.fieldname,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Ort: ${field.city} | Status: $checkStateText',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      leading: Icon(
                        Icons.terrain,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      // NEU: Navigation zur Detailseite beim Tippen
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // Übergibt das aktuelle Feld-Objekt an die neue Seite
                            builder: (context) => FieldReviewPage2(field: field), 
                          ),
                        ).then((_) {
                          // Lädt die Liste neu, wenn wir von der Detailseite zurückkehren
                          // So wird der aktualisierte Status sofort angezeigt
                          _fetchAllFields(); 
                        });
                      }
                    );
                  },
                ),
    );
  }
}