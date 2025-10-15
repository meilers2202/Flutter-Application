import 'package:pewpew_connect/service/imports.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Space',
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/images/app_bgr.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 2,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: ListTile(
                  title: Text(
                    'Benutzer verwalten',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text('Alle Benutzer einsehen'),
                  leading: Icon(
                    Icons.group,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed('/admin/users');
                  },
                ),
              ),
              const Divider(),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 2,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: ListTile(
                  title: Text(
                    'Field-Owner List',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize:15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Alle Field-Owner einsehen'
                  ),
                  leading: Icon(
                    Icons.area_chart_outlined,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed('/admin/fieldowners');
                  },
                ),
              ),
              const Divider(),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 2,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: ListTile(
                  title: Text(
                    'Field List',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize:15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Felder prüfen & verwalten'
                  ),
                  leading: Icon(
                    Icons.area_chart_outlined,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed('/admin/fields');
                  },
                ),
              ),
              const Divider(),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 2,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: ListTile(
                  title: Text(
                    'Blocklist',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize:15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Liste geblockter User'
                  ),
                  leading: Icon(
                    Icons.person_off,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed('/admin/blocklist');
                  },
                ),
              ),
              const Divider(),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 2,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: ListTile(
                  title: Text(
                    'Teams',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize:15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Teams prüfen & verwalten'
                  ),
                  leading: Icon(
                    Icons.groups,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed('/admin/teams');
                  },
                ),
              ),
              const Divider(),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 2,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: ListTile(
                  title: Text(
                    'Rollen',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize:15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Rolle verwalten'
                  ),
                  leading: Icon(
                    Icons.groups,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const IngameRolesAdminPage()));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}