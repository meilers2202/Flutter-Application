// database_models.dart

/// ----------------------------------------------------------------------
/// MODEL: User (users Tabelle)
/// ----------------------------------------------------------------------
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

/// ----------------------------------------------------------------------
/// MODEL: Field (fields Tabelle)
/// (Ich verwende hier "Field" statt "Fields", da es ein einzelnes Objekt darstellt)
/// ----------------------------------------------------------------------
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
      fieldOwnerId: int.parse(json['field_owner_id'].toString()),
      checkstate: int.parse(json['checkstate'].toString()),
    );
  }
}

/// ----------------------------------------------------------------------
/// MODEL: Group (groups Tabelle) - Repräsentiert Teams
/// ----------------------------------------------------------------------
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

/// ----------------------------------------------------------------------
/// MODEL: Checkstate (checkstate Tabelle)
/// ----------------------------------------------------------------------
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

/// ----------------------------------------------------------------------
/// MODEL: Role (roles Tabelle) - Für Teamrollen
/// ----------------------------------------------------------------------
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

/// ----------------------------------------------------------------------
/// MODEL: FieldOwner (fieldowner Tabelle) - Abbildung des Field-Besitzers
/// (Dies ist optional, da die Daten auch direkt aus der User-Tabelle gelesen werden könnten. 
/// Es repräsentiert die spezifische Verknüpfungstabelle, falls sie zusätzliche Infos hätte.)
/// ----------------------------------------------------------------------
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