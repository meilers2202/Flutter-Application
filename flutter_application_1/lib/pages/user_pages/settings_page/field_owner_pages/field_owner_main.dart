import 'package:flutter/material.dart';


const String ipAddress = 'localhost';

class FieldOwnerMainPage extends StatefulWidget {
  const FieldOwnerMainPage({super.key});

  @override
  State<FieldOwnerMainPage> createState() => _FieldOwnerMainPageState();
}

class _FieldOwnerMainPageState extends State<FieldOwnerMainPage> {

  @override
  void initState() {
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Field Owner',
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/fieldcreate');
              },
              child: const Text(
                "Feld hinzufügen",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )
              ),
            ),
          ],
        ),
      )
    );
  }
}