class LatLng {
  LatLng({
    required this.lat,
    required this.lng,
  });

  final double? lat;
  final double? lng;

  const LatLng.nil()
      : lat = null,
        lng = null;

  bool get isNil => lat == null || lng == null;
  bool get isNotNil => lat != null && lng != null;

  LatLng copyWith({
    double? lat,
    double? lng,
  }) =>
      LatLng(
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
      );

  factory LatLng.fromJson(Map<String, dynamic> json) => LatLng(
        lng: json["lng"] != null
            ? double.tryParse(json["lng"].toString())
            : null,
        lat: json["lat"] != null
            ? double.tryParse(json["lat"].toString())
            : null,
      );

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lng,
      };

  @override
  String toString() => "lat: $lat, lng: $lng";

  @override
  bool operator ==(dynamic other) {
    return (other is LatLng) && other.lat == lat && other.lng == lng;
  }

  @override
  int get hashCode => lat.hashCode ^ lng.hashCode;
}
