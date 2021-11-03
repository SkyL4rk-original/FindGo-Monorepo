import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart' as cl;

import 'lat_lon.dart';

class Store with ClusterItem {
  Store({
    required this.uuid,
    required this.imageUrl,
    required this.category,
    required this.name,
    required this.description,
    required this.phoneNumber,
    required this.website,
    required this.streetAddress,
    required this.latLng,
  });

  final String uuid;
  final String imageUrl;
  final String category;
  final String name;
  final String description;
  final String phoneNumber;
  final String website;
  final String streetAddress;
  final LatLng latLng;

  Store copyWith({
    String? uuid,
    String? imageUrl,
    String? category,
    String? name,
    String? description,
    String? phoneNumber,
    String? website,
    String? streetAddress,
    LatLng? latLng,
  }) =>
      Store(
        uuid: uuid ?? this.uuid,
        imageUrl: imageUrl ?? this.imageUrl,
        category: category ?? this.category,
        name: name ?? this.name,
        description: description ?? this.description,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        website: website ?? this.website,
        streetAddress: streetAddress ?? this.streetAddress,
        latLng: latLng ?? this.latLng,
      );

  factory Store.fromJson(Map<String, dynamic> json) => Store(
        uuid: json["storeUuid"] as String,
        imageUrl: json["imageUrl"] as String,
        category: json["category"] as String,
        name: json["name"] as String,
        description: json["description"] as String,
        phoneNumber: json["phoneNumber"] as String,
        website: json["website"] as String,
        streetAddress: json["streetAddress"] as String? ?? "",
        latLng: LatLng.fromJson(json),
      );

  Map<String, dynamic> toJson() => {
        "storeUuid": uuid,
        "imageUrl": imageUrl,
        "category": category,
        "name": name,
        "description": description,
        "phoneNumber": phoneNumber,
        "website": website,
        "streetAddress": streetAddress,
        ...latLng.toJson(),
      };

  /// COMPARE ///
  @override
  bool operator ==(dynamic other) {
    return (other is Store) && other.uuid == uuid;
  }

  @override
  int get hashCode => uuid.hashCode;

  @override
  cl.LatLng get location => cl.LatLng(latLng.lat!, latLng.lng!);
}
