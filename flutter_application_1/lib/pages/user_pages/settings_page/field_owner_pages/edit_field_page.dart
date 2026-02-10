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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildTextField(_companyController, 'Firma', isMultiLine: false),
              _buildTextField(_fieldnameController, 'Feldname', isMultiLine: false),
              _buildTextField(_descriptionController, 'Beschreibung', isMultiLine: true),
              _buildTextField(_rulesController, 'Regeln', isMultiLine: true),
              const Divider(height: 30),
              _buildTextField(_streetController, 'Straße', isMultiLine: false),
              _buildTextField(_housenumberController, 'Hausnummer', isMultiLine: false),
              _buildTextField(_postalcodeController, 'PLZ', isMultiLine: false),
              _buildTextField(_cityController, 'Stadt', isMultiLine: false),
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
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {required bool isMultiLine}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: isMultiLine ? 5 : 1,
        minLines: isMultiLine ? 3 : 1,
        keyboardType: isMultiLine ? TextInputType.multiline : TextInputType.text,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
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
}