class Location {
  Location({
    required this.id,
    required this.name,
  });

  int id;
  String name;

  Location copyWith({
    int? id,
    String? name,
  }) =>
      Location(
        id: id ?? this.id,
        name: name ?? this.name,
      );

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        id: int.parse(json["id"] as String),
        name: json["name"] as String,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };

  /// COMPARE ///
  bool isUpdated(Location other) {
    return other.id != id ||
        other.name != name;
  }

  @override
  bool operator ==(dynamic other) {
    return (other is Location) && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
