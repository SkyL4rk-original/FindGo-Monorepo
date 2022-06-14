import 'dart:convert';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:findgo_admin/core/util.dart';

// deleted                          == 0
// inactive & time until over       == 1
// active & Notification Sent       == 2
// waitingActivate                  == 8
// active & Notification Not Sent   == 9
// repeated                         == 3

enum SpecialStatus { pending, active, inactive, repeated }

enum SpecialType { special, discount, event, featured }

const constSetType = <SpecialType>{SpecialType.special};

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
    required this.validUntil,
    this.activatedAt,
    this.description = "",
    this.imageUrl = "",
    this.image,
    this.videoUrl = "",
    this.video,
    this.typeSet = constSetType,
    this.status = SpecialStatus.pending,
    this.impressions = 0,
    this.clicks = 0,
    this.websiteClicks = 0,
    this.shareClicks = 0,
    this.savedClicks = 0,
    this.phoneClicks = 0,
    this.copied = false,
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
  DateTime validUntil;
  DateTime? activatedAt;
  String description;
  String imageUrl;
  Uint8List? image;
  String videoUrl;
  Uint8List? video;
  Set<SpecialType> typeSet;
  SpecialStatus status;
  int impressions;
  int clicks;
  int websiteClicks;
  int shareClicks;
  int savedClicks;
  int phoneClicks;
  bool copied;

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
    DateTime? activatedAt,
    String? description,
    String? imageUrl,
    Uint8List? image,
    String? videoUrl,
    Uint8List? video,
    Set<SpecialType>? typeSet,
    SpecialStatus? status,
    int? impressions,
    int? clicks,
    int? websiteClicks,
    int? shareClicks,
    int? savedClicks,
    int? phoneClicks,
    bool? copied,
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
        activatedAt: activatedAt ?? this.activatedAt,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        image: image ?? this.image,
        videoUrl: videoUrl ?? this.videoUrl,
        video: video ?? this.video,
        typeSet: typeSet ?? Set.from(this.typeSet),
        status: status ?? this.status,
        impressions: impressions ?? this.impressions,
        clicks: clicks ?? this.clicks,
        websiteClicks: websiteClicks ?? this.websiteClicks,
        shareClicks: shareClicks ?? this.shareClicks,
        savedClicks: savedClicks ?? this.savedClicks,
        phoneClicks: phoneClicks ?? this.phoneClicks,
        copied: copied ?? this.copied,
      );

  static Set<SpecialType> _parseType(String typeStringList) {
    final Set<SpecialType> specialTypeSet = {};
    final statusList = typeStringList.split(",");

    for (String type in statusList) {
      type = type.trim();
      SpecialType specialType = SpecialType.special;
      if (type == "1") {
        specialType = SpecialType.event;
      } else if (type == "2") {
        specialType = SpecialType.discount;
      } else if (type == "3") {
        specialType = SpecialType.featured;
      }

      specialTypeSet.add(specialType);
    }
    return specialTypeSet;
  }

  static SpecialStatus _parseStatus(String status) {
    SpecialStatus specialStatus = SpecialStatus.inactive;
    // if (status == "1") specialStatus = SpecialStatus.inactive; // 0 == deleted
    if (status == "8") {
      specialStatus = SpecialStatus.pending;
    } else if (status == "2" || status == "9") {
      specialStatus = SpecialStatus.active;
    } else if (status == "3") {
      specialStatus = SpecialStatus.repeated;
    }
    return specialStatus;
  }

  static String _typeToStringList(Set<SpecialType> typeSet) {
    String typesAsString = "";

    for (final type in typeSet) {
      int specialType = 0; // SpecialType.brand
      if (type == SpecialType.event) {
        specialType = 1;
      } else if (type == SpecialType.discount) {
        specialType = 2;
      } else if (type == SpecialType.featured) {
        specialType = 3;
      }

      typesAsString = "$specialType,$typesAsString";
    }

    return typesAsString.substring(0, typesAsString.length - 1);
  }

  static int _statusToInt(SpecialStatus status) {
    switch (status) {
      case SpecialStatus.inactive:
        return 1;
      case SpecialStatus.active:
        return 2;
      case SpecialStatus.repeated:
        return 3;
      case SpecialStatus.pending:
        return 8;
      default:
        return 0; // deleted
    }
  }

  String get typeToString => typeSet.toString().substring(12);
  String get statusToString {
    switch (status) {
      case SpecialStatus.pending:
        return "Pending";
      case SpecialStatus.active:
        return "Active";
      case SpecialStatus.inactive:
        return "Inactive";
      case SpecialStatus.repeated:
        return "Repeated";
      default:
        return "No Status";
    }
  }

  factory Special.fromJson(Map<String, dynamic> json) => Special(
        uuid: json["specialUuid"] as String,
        storeUuid: json["storeUuid"] as String,
        storeImageUrl: json["storeImageUrl"] as String,
        storeCategory: json["storeCategory"] as String,
        storePhoneNumber: json["storePhoneNumber"] as String,
        storeWebsite: json["storeWebsite"] as String,
        storeName: json["storeName"] as String,
        name: json["name"] as String,
        price: int.tryParse(json["price"] as String) ?? 0,
        description: json["description"] as String,
        validFrom: DateTime.parse("${json["validFrom"] as String}Z").toLocal(),
        validUntil:
            DateTime.parse("${json["validUntil"] as String}Z").toLocal(),
        activatedAt: json["activatedAt"] != null &&
                json["activatedAt"] != "0000-00-00 00:00:00"
            ? DateTime.tryParse("${json["activatedAt"] as String}Z")!.toLocal()
            : null,
        imageUrl: json["imageUrl"] as String,
        videoUrl: (json["videoUrl"] as String?) ?? "",
        typeSet: _parseType(json["type"] as String),
        status: _parseStatus(json["status"] as String),
        impressions: json["impressions"] != null
            ? int.tryParse(json["impressions"] as String) ?? 0
            : 0,
        clicks: json["clicks"] != null
            ? int.tryParse(json["clicks"] as String) ?? 0
            : 0,
        websiteClicks: json["websiteClicks"] != null
            ? int.tryParse(json["websiteClicks"] as String) ?? 0
            : 0,
        phoneClicks: json["phoneClicks"] != null
            ? int.tryParse(json["phoneClicks"] as String) ?? 0
            : 0,
        savedClicks: json["savedClicks"] != null
            ? int.tryParse(json["savedClicks"] as String) ?? 0
            : 0,
        shareClicks: json["shareClicks"] != null
            ? int.tryParse(json["shareClicks"] as String) ?? 0
            : 0,
      );

  // impressions: int.tryParse(json["impressions"] as String) ?? 0,
  // clicks: int.tryParse(json["clicks"] as String) ?? 0,
  // websiteClicks: int.tryParse(json["websiteClicks"] as String) ?? 0,
  // phoneClicks: int.tryParse(json["phoneClicks"] as String) ?? 0,
  // savedClicks: int.tryParse(json["savedClicks"] as String) ?? 0,
  // shareClicks: int.tryParse(json["shareClicks"] as String) ?? 0,

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
        "storeName": storeName,
        "storeImageUrl": storeImageUrl,
        "storeCategory": storeCategory,
        "storePhoneNumber": storePhoneNumber,
        "storeWebsite": storeWebsite,
        "name": name,
        "price": price,
        // "validFrom": validFrom.toUtc().toIso8601String(),
        // "validUntil": validUntil != null ? validUntil!.toUtc().toIso8601String(): null,
        // "activatedAt": activatedAt != null && _statusToInt(status) != 1 ? activatedAt!.toUtc().toIso8601String(): "0000-00-00 00:00:00Z",
        "validFrom": Util.convertDateTimeToUtcISO(validFrom),
        "validUntil": Util.convertDateTimeToUtcISO(validUntil),
        "activatedAt": activatedAt != null && _statusToInt(status) != 1
            ? Util.convertDateTimeToUtcISO(activatedAt!)
            : "0000-00-00 00:00:00",
        "description": description,
        "imageUrl": imageUrl,
        "image": image != null ? base64Encode(image!) : null,
        "videoUrl": videoUrl,
        "video": video != null ? base64Encode(video!) : null,
        "type": _typeToStringList(typeSet),
        "status": _statusToInt(status),
        "impressions": impressions,
        "clicks": clicks,
        "websiteClicks": websiteClicks,
        "phoneClicks": phoneClicks,
        "savedClicks": savedClicks,
        "shareClicks": shareClicks,
      };

  /// COMPARE ///
  final Function(Set<SpecialType>, Set<SpecialType>) _unOrdDeepEq =
      const DeepCollectionEquality.unordered().equals;
  bool isUpdated(Special other) {
    final equalType = _unOrdDeepEq(other.typeSet, typeSet) as bool;

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
        // other.status != status ||
        !equalType;
  }

  // @override
  // int compareTo(MyObject other) {
  //   int result = name?.compareTo(other?.name) ?? 0;
  //   if (result == 0) {
  //     int type1 = int.tryParse(type?.replaceAll(_regExp, '') ?? 0);
  //     int type2 = int.tryParse(other?.type?.replaceAll(_regExp, '') ?? 0);
  //     result = type1.compareTo(type2);
  //   }
  //   return result;
  // }

  @override
  bool operator ==(dynamic other) {
    return (other is Special) && other.uuid == uuid;
  }

  @override
  int get hashCode => uuid.hashCode;
}

