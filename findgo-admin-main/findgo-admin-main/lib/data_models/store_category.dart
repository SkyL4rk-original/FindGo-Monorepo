class StoreCategory {
  StoreCategory({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  StoreCategory copyWith({
    int? id,
    String? name,
  }) =>
      StoreCategory(
        id: id ?? this.id,
        name: name ?? this.name,
      );

  factory StoreCategory.fromJson(Map<String, dynamic> json) => StoreCategory(
    id: int.parse(json["ID"] as String),
    name: json["name"] as String,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}