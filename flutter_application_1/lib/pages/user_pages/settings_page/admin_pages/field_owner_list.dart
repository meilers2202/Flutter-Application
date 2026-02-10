import 'package:http/http.dart' as http;
import 'package:pewpew_connect/service/imports.dart';

class FieldOwnerList extends StatefulWidget {
  const FieldOwnerList({super.key});

  @override
  State<FieldOwnerList> createState() => _FieldOwnerListState();
}

class _FieldOwnerListState extends State<FieldOwnerList> {
  List<String> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllUsers();
  }

  Future<void> _fetchAllUsers() async {
    final url = Uri.parse('$ipAddress/get_field_owners_data.php');
    try {
      final response = await http.post(url);
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        if (mounted) {
          setState(() {
            _users = List<String>.from(data['users']);
            _isLoading = false;
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
          SnackBar(content: Text('Verbindungsfehler: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Field Owners',
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
          : _users.isEmpty
              ? const Center(
                  child: Text(
                    'Keine Benutzer gefunden.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return ListTile(
                      title: Text(
                        user,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      leading: Icon(
                        Icons.area_chart_outlined,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    );
                  },
                ),
    );
  }
}