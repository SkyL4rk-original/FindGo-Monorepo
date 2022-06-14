// none == 0, superAdmin == 1 / admin == 2 / designer == 3
enum ManagedUserRole { none, superAdmin, admin, designer }

class ManagedUser {
  ManagedUser({
    required this.uuid,
    this.email = "",
    this.firstName = "first",
    this.lastName = "last",
    this.role = ManagedUserRole.none,
  });

  final String uuid;
  final String email;
  final String firstName;
  final String lastName;
  final ManagedUserRole role;

  /// ENCODE / DECODE ///
  static ManagedUserRole _parseManagedUserRole(String role) {
    switch (role) {
      case "1":
        return ManagedUserRole.superAdmin;
      case "2":
        return ManagedUserRole.admin;
      case "3":
        return ManagedUserRole.designer;
      default:
        return ManagedUserRole.none;
    }
  }

  int managedUserRoleToInt(ManagedUserRole role) {
    switch (role) {
      case ManagedUserRole.superAdmin:
        return 1;
      case ManagedUserRole.admin:
        return 2;
      case ManagedUserRole.designer:
        return 3;
      default:
        return 0;
    }
  }

  String managedUserRoleToString() {
    switch (role) {
      case ManagedUserRole.superAdmin:
        return "Super Admin";
      case ManagedUserRole.admin:
        return "Admin";
      case ManagedUserRole.designer:
        return "Designer";
      default:
        return "None";
    }
  }

  factory ManagedUser.fromJson(Map<String, dynamic> json) => ManagedUser(
        uuid: json["userUuid"] as String,
        email: json["email"] as String,
        firstName: json["firstName"] as String,
        lastName: json["lastName"] as String,
        role: _parseManagedUserRole(json["role"] as String? ?? "0"),
      );

  Map<String, dynamic> toJson() => {
        "userUuid": uuid,
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
        "role": managedUserRoleToInt(role),
      };

  @override
  String toString() {
    return "$uuid $email $role";
  }

  /// COPY ///
  ManagedUser copyWith({
    String? uuid,
    String? email,
    String? firstName,
    String? lastName,
    ManagedUserRole? role,
  }) =>
      ManagedUser(
        uuid: uuid ?? this.uuid,
        email: email ?? this.email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        role: role ?? this.role,
      );

  /// COMPARE ///
  @override
  bool operator ==(dynamic other) {
    return (other is ManagedUser) && other.uuid == uuid;
  }

  @override
  int get hashCode => uuid.hashCode;
}
