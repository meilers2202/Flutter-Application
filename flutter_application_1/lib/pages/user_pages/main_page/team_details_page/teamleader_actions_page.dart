import 'package:pewpew_connect/service/imports.dart';
import 'package:pewpew_connect/pages/user_pages/main_page/team_details_page/team_members.dart';

class TeamLeaderActionsPage extends StatelessWidget {
  final String teamName;
  final String currentUsername;
  final List<String> members;
  final String? userEmail;
  final String? userCity;
  final String? userMemberSince;
  final String? userRole;
  final void Function({
    required String username,
    required bool stayLoggedIn,
    String? email,
    String? city,
    String? team,
    String? memberSince,
    String? role,
    String? teamrole,
  }) onTeamChange;

  const TeamLeaderActionsPage({
    super.key,
    required this.teamName,
    required this.currentUsername,
    required this.members,
    required this.onTeamChange,
    this.userEmail,
    this.userCity,
    this.userMemberSince,
    this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Teamleader Aktionen',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verfügbare Aktionen:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TeamMembersViewPage(
                        teamName: teamName,
                        currentUsername: currentUsername,
                        members: members,
                        onTeamChange: onTeamChange,
                        userEmail: userEmail,
                        userCity: userCity,
                        userMemberSince: userMemberSince,
                        userRole: userRole,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.group, color: Colors.white),
                label: const Text('Mitglieder anzeigen'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 41, 107, 43),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
