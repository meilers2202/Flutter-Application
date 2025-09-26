import 'package:flutter/material.dart';

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
      body: ListView(
        children: [
          ListTile(
            title: Text(
              'Benutzer verwalten',
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontSize:15,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Alle Benutzer einsehen'
            ),
            leading: Icon(
              Icons.group,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            onTap: () {
              Navigator.of(context).pushNamed('/admin/users');
            },
          ),
          const Divider(),
          ListTile(
            title: Text(
              'Field-Owner List',
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
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
          const Divider(),
          ListTile(
            title: Text(
              'Field List',
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
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
          const Divider(),
          ListTile(
            title: Text(
              'Blocklist',
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
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
          const Divider(),
          ListTile(
            title: Text(
              'Teams',
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
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
        ],
      ),
    );
  }
}