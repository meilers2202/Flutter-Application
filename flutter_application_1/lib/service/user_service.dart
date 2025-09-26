import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pewpew_connect/service/constants.dart';

class UserService {
  // Holt Profilinformationen vom Server
  Future<Map<String, dynamic>> fetchProfileData(String username) async {
    final url = Uri.parse('$ipAddress/get_profile.php');
    try {
      final response = await http.post(
        url,
        body: {'username': username},
      );
      final data = json.decode(response.body);

      if (data['success'] == true) {
        return {
          'success': true,
          'message': 'Profil erfolgreich geladen',
          'user': data['user']
        };
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Verbindungsfehler: $e'};
    }
  }

  // Erstellt ein neues Team
  Future<Map<String, dynamic>> createTeam(String teamName) async {
    final url = Uri.parse('$ipAddress/add_team.php');
    try {
      final response = await http.post(
        url,
        body: {'teamName': teamName},
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Verbindungsfehler: $e'};
    }
  }

  // Holt die Mitglieder eines Teams
  Future<Map<String, dynamic>> fetchTeamMembers(String teamName) async {
    final url = Uri.parse('$ipAddress/get_team_members.php');
    try {
      final response = await http.post(
        url,
        body: {'teamName': teamName},
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Verbindungsfehler: $e'};
    }
  }
}