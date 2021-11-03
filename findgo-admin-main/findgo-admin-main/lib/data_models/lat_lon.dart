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
  bool operator ==(dynamic other) {
    return (other is LatLng) && other.lat == lat && other.lng == lng;
  }

  @override
  int get hashCode => lat.hashCode ^ lng.hashCode;
}

class SearchedPlace {
  SearchedPlace({
    required this.description,
    required this.placeId,
  });

  final String description;
  final String placeId;

  factory SearchedPlace.fromJson(Map<String, dynamic> json) => SearchedPlace(
        description: json["description"] as String? ?? "error-description",
        placeId: json["place_id"] as String? ?? "error-id",
      );
}

class SelectedPlace {
  SelectedPlace({
    required this.streetAddress,
    required this.latLon,
  });

  final String streetAddress;
  final LatLng latLon;

  factory SelectedPlace.fromJson(Map<String, dynamic> json) => SelectedPlace(
        streetAddress:
            json["formatted_address"] as String? ?? "error-description",
        latLon: LatLng.fromJson(
          json["geometry"]["location"] as Map<String, dynamic>,
        ),
      );
}
