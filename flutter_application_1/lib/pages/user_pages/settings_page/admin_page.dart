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
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            leading: Icon(
              Icons.group,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            onTap: () {
              Navigator.of(context).pushNamed('/admin/users');
            },
          ),
          ListTile(
            title: Text(
              'Field-Owner List',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            leading: Icon(
              Icons.area_chart_outlined,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            onTap: () {
              Navigator.of(context).pushNamed('/admin/fieldowners');
            },
          ),
          ListTile(
            title: Text(
              'Field List',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            leading: Icon(
              Icons.area_chart_outlined,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            onTap: () {
              Navigator.of(context).pushNamed('/admin/fields');
            },
          ),
          ListTile(
            title: Text(
              'Blocklist',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            leading: Icon(
              Icons.person_off,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            onTap: () {
              Navigator.of(context).pushNamed('/admin/blocklist');
            },
          ),
          ListTile(
            title: Text(
              'Teams',
              style: Theme.of(context).textTheme.bodyMedium,
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