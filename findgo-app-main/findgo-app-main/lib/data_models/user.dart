class User {
  User({
    required this.uuid,
    this.password = "",
    this.email = "",
    this.firstName = "first",
    this.lastName = "last",
    this.firebaseToken = "",
    this.createdAt, // Convert to DateTime when used
    this.updatedAt,
  });

  final String uuid;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  String firebaseToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// ENCODE / DECODE ///
  factory User.fromJson(Map<String, dynamic> json) => User(
        uuid: json["userUuid"] as String,
        email: json["email"] as String,
        // password : json["password"] as String,
        firstName: json["firstName"] as String,
        lastName: json["lastName"] as String,
        firebaseToken: json["firebaseToken"] as String,
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
        "firstName": firstName,
        "lastName": lastName,
        "firebaseToken": firebaseToken,
        "createdAt": createdAt != null
            ? createdAt!
                .toUtc()
                .toIso8601String()
                .substring(0, createdAt!.toUtc().toIso8601String().length - 1)
            : null,
        "updatedAt": updatedAt != null
            ? updatedAt!
                .toUtc()
                .toIso8601String()
                .substring(0, updatedAt!.toUtc().toIso8601String().length - 1)
            : null,
        "type": "general",
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
    String? firebaseToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      User(
        uuid: uuid ?? this.uuid,
        email: email ?? this.email,
        password: password ?? this.password,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        firebaseToken: firebaseToken ?? this.firebaseToken,
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
