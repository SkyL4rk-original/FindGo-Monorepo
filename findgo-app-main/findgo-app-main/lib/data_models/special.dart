import 'dart:convert';
import 'dart:typed_data';

enum SpecialStatus { active, inactive, repeated }
enum SpecialType { brand, discount, event, featured }
enum SpecialStat { impression, click, websiteClick, phoneClick, shareClick, savedClick }

const constSetType = <SpecialType>{ SpecialType.brand };

class Special {

  Special({
    required this.uuid,
    required this.storeUuid,
    this.storeName = "",
    this.storeImageUrl = "",
    this.storeCategory = "",
    this.storePhoneNumber = "",
    this.storeWebsite = "",
    this.price = 0,
    this.name = "",
    required this.validFrom,
    this.validUntil,
    this.description = "",
    this.imageUrl = "",
    this.image,
    this.videoUrl = "",
    this.video,
    this.typeSet = constSetType,
    this.status = SpecialStatus.inactive,
  });

  String uuid;
  String storeUuid;
  String storeName;
  String storeImageUrl;
  String storeCategory;
  String storePhoneNumber;
  String storeWebsite;
  int price;
  String name;
  DateTime validFrom;
  DateTime? validUntil;
  String description;
  String imageUrl;
  Uint8List? image;
  String videoUrl;
  Uint8List? video;
  Set<SpecialType> typeSet;
  SpecialStatus status;

  @override
  String toString() {
    return "special: $storeName, $name";
  }

  Special copyWith({
    String? uuid,
    String? storeUuid,
    String? storeName,
    String? storeImageUrl,
    String? storeCategory,
    String? storePhoneNumber,
    String? storeWebsite,
    int? price,
    String? name,
    DateTime? validFrom,
    DateTime? validUntil,
    String? description,
    String? imageUrl,
    Uint8List? image,
    String? videoUrl,
    Uint8List? video,
    Set<SpecialType>? typeSet,
    SpecialStatus? status,
  }) =>
      Special(
        uuid: uuid ?? this.uuid,
        storeUuid: storeUuid ?? this.storeUuid,
        storeName: storeName ?? this.storeName,
        storeImageUrl: storeImageUrl ?? this.storeImageUrl,
        storeCategory: storeCategory ?? this.storeCategory,
        storePhoneNumber: storePhoneNumber ?? this.storePhoneNumber,
        storeWebsite: storeWebsite ?? this.storeWebsite,
        name: name ?? this.name,
        price: price ?? this.price,
        validFrom: validFrom ?? this.validFrom,
        validUntil: validUntil ?? this.validUntil,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        image: image ?? this.image,
        videoUrl: videoUrl ?? this.videoUrl,
        video: video ?? this.video,
        typeSet: typeSet ?? this.typeSet,
        status: status ?? this.status,
      );

  static Set<SpecialType> _parseType(String typeStringList) {
    final Set<SpecialType> specialTypeSet = {};
    final statusList = typeStringList.split(",");

    for (String type in statusList) {
      type = type.trim();
      SpecialType specialType = SpecialType.brand;
      if (type == "1") {
        specialType = SpecialType.event;
      } else if (type == "2") {
        specialType = SpecialType.discount;
      } else if (type == "3") specialType = SpecialType.featured;

      specialTypeSet.add(specialType);
    }
    return specialTypeSet;
  }

  static SpecialStatus _parseStatus(String status) {
    SpecialStatus specialStatus = SpecialStatus.inactive;
    // if (status == "1") specialStatus = SpecialStatus.active;
    if (status == "2") {
      specialStatus = SpecialStatus.active;
    } else if (status == "3") specialStatus = SpecialStatus.repeated;
    return specialStatus;
  }

  static String _typeToStringList(Set<SpecialType> typeSet) {
    String typesAsString = "";

    for (final type in typeSet) {
      int specialType = 0; // SpecialType.brand
      if (type == SpecialType.event) { specialType = 1;
      } else if (type == SpecialType.discount) { specialType = 2;
      } else if (type == SpecialType.featured) { specialType = 3; }

      typesAsString = "$specialType,$typesAsString";
    }

    return typesAsString.substring(0 ,typesAsString.length - 1);
  }

  static int _statusToInt(SpecialStatus status) {
    int specialStatus = 0; // Delete
    if (status == SpecialStatus.inactive) { specialStatus = 1; }
    else if (status == SpecialStatus.active) { specialStatus = 2; }
    else if (status == SpecialStatus.repeated) { specialStatus = 3; }
    return specialStatus;
  }

  String get typeToString => typeSet.toString().substring(12);
  String get statusToString => status.toString().substring(14);


  factory Special.fromJson(Map<String, dynamic> json) => Special(
    uuid: json["specialUuid"] as String,
    storeUuid: json["storeUuid"] as String,
    storeImageUrl: json["storeImageUrl"] as String,
    storeCategory: json["storeCategory"] as String,
    storeName: json["storeName"] as String,
    storePhoneNumber: json["storePhoneNumber"] as String,
    storeWebsite: json["storeWebsite"] as String,
    name: json["name"] as String,
    price: int.parse(json["price"] as String),
    description: json["description"] as String,
    validFrom: DateTime.parse("${json["validFrom"] as String}Z").toLocal(),
    validUntil: json["validUntil"] != null ? DateTime.tryParse("${json["validUntil"] as String}Z")!.toLocal() : null,
    imageUrl: json["imageUrl"] as String,
    videoUrl: (json["videoUrl"] as String?) ?? "",
    typeSet: _parseType(json["type"] as String),
    status: _parseStatus(json["status"] as String),
  );

  // {
  // "specialUuid": "55b7a193-c69f-11eb-b937-001dd8b7399f",
  // "storeUuid": "5fad8f7d-c699-11eb-b937-001dd8b7399f",
  // "storeName": "Test Store",
  // "storeImageUrl": "",
  // "storeCategory": "Health",
  // "name": "dddd",
  // "price": "2200",
  // "description": "sadasd",
  // "imageUrl": "",
  // "type": "1",
  // "status": "1"
  // }

  Map<String, dynamic> toJson() => {
    "specialUuid": uuid,
    "storeUuid": storeUuid,
    "storeImageUrl": storeImageUrl,
    "storeCategory": storeCategory,
    "storeName": storeName,
    "storePhoneNumber": storePhoneNumber,
    "storeWebsite": storeWebsite,
    "name": name,
    "price": price,
    "validFrom": validFrom.toUtc().toIso8601String(),
    "validUntil": validUntil != null ? validUntil!.toUtc().toIso8601String(): null,
    "description": description,
    "imageUrl": imageUrl,
    "image": image != null ? base64Encode(image!) : null,
    "videoUrl": videoUrl,
    "video": video != null ? base64Encode(video!) : null,
    "type": _typeToStringList(typeSet),
    "status": _statusToInt(status),
  };

  /// COMPARE ///
  bool isUpdated(Special other) {
    return other.uuid != uuid ||
        other.name != name ||
        other.description != description ||
        other.price != price ||
        other.validFrom != validFrom ||
        other.validUntil != validUntil ||
        other.imageUrl != imageUrl ||
        other.videoUrl != videoUrl ||
        other.image != null ||
        other.video != null ||
        other.status != status ||
        other.typeSet != typeSet;
  }

  @override
  bool operator ==(dynamic other) {
    return (other is Special) &&
        other.uuid == uuid;
  }

  @override
  int get hashCode =>
      uuid.hashCode;

}