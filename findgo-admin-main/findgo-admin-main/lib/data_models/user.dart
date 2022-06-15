import 'package:findgo_admin/core/util.dart';

class User {
  User({
    required this.uuid,
    this.password = "",
    this.email = "",
    this.firstName = "first",
    this.lastName = "last",
    this.role = "noRole",
    this.active = false,
    this.storeUuid = "",
    this.createdAt, // Convert to DateTime when used
    this.updatedAt,
  });

  final String uuid;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String role;
  final String storeUuid;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isSuperUser => role == "superAdmin";

  /// ENCODE / DECODE ///
  factory User.fromJson(Map<String, dynamic> json) => User(
        uuid: json["userUuid"] as String,
        email: json["email"] as String,
        // password : json["password"] as String,
        firstName: json["firstName"] as String,
        lastName: json["lastName"] as String,
        role: json["role"] as String,
        storeUuid: json["storeUuid"] as String,
        active: json["status"] as String == "1",
        createdAt: json["createdAt"] != null
            ? DateTime.parse(json["createdAt"] as String)
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.parse(json["updatedAt"] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        "userUuid": uuid,
        "email": email,
        "password": password,
        "status": active,
        "firstName": firstName,
        "lastName": lastName,
        "role": role,
        "storeUuid": storeUuid,
        // "createdAt" : createdAt!.toUtc().toIso8601String(),
        // "updatedAt" : updatedAt!.toUtc().toIso8601String(),
        "createdAt": createdAt != null
            ? Util.convertDateTimeToUtcISO(createdAt!)
            : "0000-00-00 00:00:00",
        "updatedAt": updatedAt != null
            ? Util.convertDateTimeToUtcISO(updatedAt!)
            : "0000-00-00 00:00:00",
        "type": "admin",
      };

  @override
  String toString() {
    return "$uuid $email";
  }

  /// COPY ///
  User copyWith({
    String? uuid,
    String? email,
    String? password,
    String? firstName,
    String? lastName,
    String? storeUuid,
    String? role,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      User(
        uuid: uuid ?? this.uuid,
        email: email ?? this.email,
        password: password ?? this.password,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        role: role ?? this.role,
        active: active ?? this.active,
        storeUuid: storeUuid ?? this.storeUuid,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  /// COMPARE ///
  @override
  bool operator ==(dynamic other) {
    return (other is User) && other.uuid == uuid && other.email == email;
  }

  @override
  int get hashCode => uuid.hashCode ^ email.hashCode;
}
