import 'dart:convert';
import 'dart:typed_data';

import 'package:findgo_admin/data_models/lat_lon.dart';

// 1 == active / 2 == inactive
enum StoreStatus { active, inactive }

class Store {
  Store({
    required this.uuid,
    required this.imageUrl,
    this.image,
    required this.category,
    this.categoryId = 13,
    required this.name,
    required this.description,
    this.phoneNumber = "",
    this.website = "",
    this.streetAddress = "",
    this.latLng = const LatLng.nil(),
    this.status = StoreStatus.inactive,
  });

  String uuid;
  String imageUrl;
  Uint8List? image;
  String category;
  int categoryId;
  String name;
  String description;
  String phoneNumber;
  String website;
  String streetAddress;
  LatLng latLng;
  StoreStatus status;

  Store copyWith({
    String? uuid,
    String? imageUrl,
    Uint8List? image,
    String? category,
    int? categoryId,
    String? name,
    String? description,
    String? phoneNumber,
    String? website,
    String? streetAddress,
    LatLng? latLng,
    StoreStatus? status,
  }) =>
      Store(
        uuid: uuid ?? this.uuid,
        imageUrl: imageUrl ?? this.imageUrl,
        image: image ?? this.image,
        category: category ?? this.category,
        categoryId: categoryId ?? this.categoryId,
        name: name ?? this.name,
        description: description ?? this.description,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        website: website ?? this.website,
        streetAddress: streetAddress ?? this.streetAddress,
        latLng: latLng ?? this.latLng,
        status: status ?? this.status,
      );

  static StoreStatus _parseStatus(String status) {
    StoreStatus storeStatus = StoreStatus.inactive; // 2 = inactive
    if (status == "1") storeStatus = StoreStatus.active; // 1 = active
    return storeStatus;
  }

  static int _statusToInt(StoreStatus status) {
    switch (status) {
      case StoreStatus.active:
        return 1;
      case StoreStatus.inactive:
        return 2;
      default:
        return 0; // deleted
    }
  }

  factory Store.fromJson(Map<String, dynamic> json) => Store(
        uuid: json["storeUuid"] as String,
        imageUrl: json["imageUrl"] as String,
        category: json["category"] as String,
        categoryId: int.parse(json["categoryId"] as String),
        name: json["name"] as String,
        description: json["description"] as String,
        phoneNumber: json["phoneNumber"] as String,
        website: json["website"] as String,
        status: _parseStatus(json["status"] as String),
        streetAddress: json["streetAddress"] as String? ?? "",
        latLng: LatLng.fromJson(json),
      );

  Map<String, dynamic> toJson() => {
        "storeUuid": uuid,
        "imageUrl": imageUrl,
        "image": image != null ? base64Encode(image!) : null,
        "category": category,
        "name": name,
        "description": description,
        "categoryId": categoryId,
        "phoneNumber": phoneNumber,
        "website": website,
        "streetAddress": streetAddress,
        "status": _statusToInt(status),
        ...latLng.toJson(),
      };

  /// COMPARE ///
  bool isUpdated(Store other) {
    return other.uuid != uuid ||
        other.name != name ||
        other.category != category ||
        other.description != description ||
        other.website != website ||
        other.phoneNumber != phoneNumber ||
        other.streetAddress != streetAddress ||
        other.latLng != latLng ||
        other.imageUrl != imageUrl ||
        other.image != null;
  }

  @override
  bool operator ==(dynamic other) {
    return (other is Store) && other.uuid == uuid;
  }

  @override
  int get hashCode => uuid.hashCode;
}
