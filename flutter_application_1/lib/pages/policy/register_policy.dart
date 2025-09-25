import 'package:flutter/material.dart';

const String ipAddress = 'localhost';

class RegisterPolicy extends StatefulWidget {
  const RegisterPolicy({super.key});

  @override
  State<RegisterPolicy> createState() => _RegisterPolicyState();
}

class _RegisterPolicyState extends State<RegisterPolicy> {

  @override
  void initState() {
    super.initState();
    // Keine Logik nötig, da die Daten statisch sind
  }

  // Widget, das die Richtlinieninhalte darstellt
  Widget _buildPolicyText() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Allgemeine Geschäftsbedingungen und Datenschutz',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 15),
          
          Text(
            'Mit der Registrierung bei unserer Plattform stimmen Sie den folgenden Bedingungen zu:',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 10),

          // --- 1. Nutzungsbedingungen ---
          Text(
            '1. Nutzungsbedingungen',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          Text(
            'Die Nutzung der Plattform ist nur Personen gestattet, die das 18. Lebensjahr vollendet haben. Sie verpflichten sich, keine illegalen, beleidigenden oder irreführenden Inhalte zu veröffentlichen. Die Plattform behält sich das Recht vor, Accounts bei Verstößen ohne Vorwarnung zu sperren.',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 15),

          // --- 2. Datenverarbeitung (Datenschutz) ---
          Text(
            '2. Datenschutz und Datensicherheit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          Text(
            'Zur Durchführung der Registrierung und zur Bereitstellung unserer Dienste erheben wir folgende Daten: Benutzername, E-Mail-Adresse und gegebenenfalls weitere, von Ihnen freiwillig angegebene Informationen. Diese Daten werden ausschließlich zur Verwaltung Ihres Kontos und zur Bereitstellung der Plattformfunktionen verwendet. Wir geben Ihre Daten nicht ohne Ihre Zustimmung an Dritte weiter, es sei denn, dies ist gesetzlich vorgeschrieben.',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 15),

          // --- 3. Haftungsausschluss ---
          Text(
            '3. Haftungsausschluss',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          Text(
            'Die Plattform übernimmt keine Haftung für die Richtigkeit und Vollständigkeit der von Nutzern eingestellten Felder und Inhalte.',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 30),
          
          Text(
            'Letzte Aktualisierung: September 2025',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          SizedBox(height: 20), // Abstand zu den Buttons
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registrierungsrichtlinien',
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
          children: [
            Expanded(
              child: _buildPolicyText(), // Text nimmt den Hauptteil ein
            ),
            
            // NEU: Button-Leiste am unteren Rand
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Button 1: Ablehnen (Kehrt zurück und gibt 'false' zurück)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Bei Ablehnung: Kehre zur vorherigen Seite zurück und gib 'false' zurück
                        Navigator.of(context).pop(false); 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'Ablehnen',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  
                  // Button 2: Akzeptieren (Kehrt zurück und gibt 'true' zurück)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Bei Akzeptieren: Kehre zur vorherigen Seite zurück und gib 'true' zurück
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 90, 111, 78),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'Akzeptieren',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}