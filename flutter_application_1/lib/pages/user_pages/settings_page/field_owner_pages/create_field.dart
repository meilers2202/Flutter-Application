import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String ipAddress = 'localhost';

class CreateField extends StatefulWidget {
  final String currentUsername;

  const CreateField({
    super.key,
    required this.currentUsername,
  });

  @override
  State<CreateField> createState() => _CreateFieldState();
}

class _CreateFieldState extends State<CreateField> {
  final _fieldnameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rulesController = TextEditingController();
  final _streetController = TextEditingController();
  final _housenumberController = TextEditingController();
  final _postalcodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _companyController = TextEditingController();

  int? _currentUserId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    final url = Uri.parse('http://$ipAddress/get_user_id_by_username.php');
    try {
      final response = await http.post(
        url,
        body: {'username': widget.currentUsername},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && mounted) {
          setState(() {
            _currentUserId = data['userId'];
            _isLoading = false;
          });
        } else if (mounted) {
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
          SnackBar(content: Text('Fehler beim Abrufen der Benutzer-ID: $e')),
        );
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

  Future<void> _createField() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Benutzer-ID nicht verfügbar.')),
      );
      return;
    }

    const String ipAddress = 'localhost';
    final url = Uri.parse('http://$ipAddress/create_field.php');

    try {
      final response = await http.post(
        url,
        body: {
          'fieldname': _fieldnameController.text,
          'description': _descriptionController.text,
          'rules': _rulesController.text,
          'street': _streetController.text,
          'housenumber': _housenumberController.text,
          'postalcode': _postalcodeController.text,
          'city': _cityController.text,
          'company': _companyController.text,
          'field_owner_id': _currentUserId.toString(),
        },
      );

      if (!mounted) return;

      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Field',
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Fielddetails",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            _buildTextField(_companyController, 'Firma'),
            const SizedBox(height: 15),
            _buildTextField(_fieldnameController, 'Feldname'),
            const SizedBox(height: 15),
            _buildMultiLineTextField(_descriptionController, 'Beschreibung'),
            const SizedBox(height: 15),
            _buildMultiLineTextField(_rulesController, 'Regeln'),
            const SizedBox(height: 10),
            const Divider(),
            const Text(
              "Location",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(_streetController, 'Straße'),
            const SizedBox(height: 20),
            _buildTextField(_housenumberController, 'Hausnummer'),
            const SizedBox(height: 20),
            _buildTextField(_postalcodeController, 'PLZ'),
            const SizedBox(height: 20),
            _buildTextField(_cityController, 'Stadt'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createField,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color.fromARGB(255, 22, 59, 13),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'ERSTELLEN',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: Colors.grey),
      ),
      style: const TextStyle(color: Colors.black),
    );
  }

  Widget _buildMultiLineTextField(
      TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      maxLines: 5,
      minLines: 3,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: Colors.grey),
      ),
      style: const TextStyle(color: Colors.black),
    );
  }
}