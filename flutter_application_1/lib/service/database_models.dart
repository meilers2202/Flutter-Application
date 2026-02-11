class User {
  final int id;
  final String username;
  final String email;
  final String? city;
  final int? groupId;
  final String role; // 'admin', 'user', etc.
  final int? teamRole; // Verweist auf roles.id (z.B. Teamleader)
  final DateTime createdAt;
  final bool policyAccepted;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.city,
    this.groupId,
    required this.role,
    this.teamRole,
    required this.createdAt,
    required this.policyAccepted,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()),
      username: json['username'] as String,
      email: json['email'] as String,
      city: json['city'] as String?,
      groupId: json['group_id'] != null ? int.parse(json['group_id'].toString()) : null,
      role: json['role'] as String,
      teamRole: json['teamrole'] != null ? int.parse(json['teamrole'].toString()) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      policyAccepted: (json['policy_accepted'].toString() == '1' || json['policy_accepted'] == true),
    );
  }
}

class Field {
  final int id;
  final String fieldname;
  final String? description;
  final String? rules;
  final String? street;
  final String? housenumber;
  final String? postalcode;
  final String? city;
  final String? company;
  final int? homeTeamId;
  final String? homeTeamName;
  final int fieldOwnerId; // Verweist auf users.id
  final int checkstate; // Verweist auf checkstate.id

  Field({
    required this.id,
    required this.fieldname,
    this.description,
    this.rules,
    this.street,
    this.housenumber,
    this.postalcode,
    this.city,
    this.company,
    this.homeTeamId,
    this.homeTeamName,
    required this.fieldOwnerId,
    required this.checkstate,
  });

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: int.parse(json['id'].toString()),
      fieldname: json['fieldname'] as String,
      description: json['description'] as String?,
      rules: json['rules'] as String?,
      street: json['street'] as String?,
      housenumber: json['housenumber'] as String?,
      postalcode: json['postalcode'] as String?,
      city: json['city'] as String?,
      company: json['company'] as String?,
      homeTeamId: json['home_team_id'] != null ? int.tryParse(json['home_team_id'].toString()) : null,
      homeTeamName: json['home_team_name'] as String?,
      fieldOwnerId: int.parse(json['field_owner_id'].toString()),
      checkstate: int.parse(json['checkstate'].toString()),
    );
  }
}

class Group {
  final int id;
  final String name;

  Group({
    required this.id,
    required this.name,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: int.parse(json['id'].toString()),
      name: json['name'] as String,
    );
  }
}
class FieldCheckState {
  final int id;
  final String statusName;
  final String colorHint;

  FieldCheckState({
    required this.id,
    required this.statusName,
    required this.colorHint,
  });

  factory FieldCheckState.fromJson(Map<String, dynamic> json) {
    return FieldCheckState(
      id: int.parse(json['id'].toString()),
      statusName: json['status_name'] as String,
      colorHint: json['color_hint'] as String,
    );
  }
}

class Role {
  final int id;
  final String name;

  Role({
    required this.id,
    required this.name,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: int.parse(json['id'].toString()),
      name: json['name'] as String,
    );
  }
}
class FieldOwner {
  final int userId;
  final String name;

  FieldOwner({
    required this.userId,
    required this.name,
  });

  factory FieldOwner.fromJson(Map<String, dynamic> json) {
    return FieldOwner(
      userId: int.parse(json['user_id'].toString()),
      name: json['name'] as String,
    );
  }
}