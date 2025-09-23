import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String version;

  const AppDrawer({Key? key, required this.version}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Text(
              'App Version: $version',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          // Füge hier weitere ListTiles oder andere Menüpunkte hinzu
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Startseite'),
            onTap: () {
              Navigator.pop(context); // Drawer schließen
              // Hier zu deiner Startseite navigieren
            },
          ),
          // etc.
        ],
      ),
    );
  }
}