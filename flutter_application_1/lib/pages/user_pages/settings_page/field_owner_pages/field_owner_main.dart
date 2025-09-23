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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}