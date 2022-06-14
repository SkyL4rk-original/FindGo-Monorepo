class StoreStats {
  StoreStats({
    required this.storeUuid,
    required this.followers,
    required this.impressions,
    required this.clicks,
    required this.phoneClicks,
    required this.savedClicks,
    required this.sharedClicks,
    required this.websiteClicks,
  });
  StoreStats.init({
    required this.storeUuid,
    this.followers = 0,
    this.impressions = 0,
    this.clicks = 0,
    this.phoneClicks = 0,
    this.savedClicks = 0,
    this.sharedClicks = 0,
    this.websiteClicks = 0,
  });

  final String storeUuid;
  final int followers;
  final int impressions;
  final int clicks;
  final int phoneClicks;
  final int savedClicks;
  final int sharedClicks;
  final int websiteClicks;

  StoreStats copyWith({
    String? storeUuid,
    int? followers,
    int? impressions,
    int? clicks,
    int? phoneClicks,
    int? savedClicks,
    int? sharedClicks,
    int? websiteClicks,
  }) =>
      StoreStats(
        storeUuid: storeUuid ?? this.storeUuid,
        followers: followers ?? this.followers,
        impressions: impressions ?? this.impressions,
        clicks: clicks ?? this.clicks,
        phoneClicks: phoneClicks ?? this.phoneClicks,
        savedClicks: savedClicks ?? this.savedClicks,
        sharedClicks: sharedClicks ?? this.sharedClicks,
        websiteClicks: websiteClicks ?? this.websiteClicks,
      );

  factory StoreStats.fromJson(Map<String, dynamic> json) => StoreStats(
        storeUuid: json["storeUuid"] as String,
        followers: int.tryParse(json["followers"] as String) ?? -1,
        impressions: int.tryParse(json["impressions"] as String) ?? -1,
        clicks: int.tryParse(json["clicks"] as String) ?? -1,
        phoneClicks: int.tryParse(json["phoneClicks"] as String) ?? -1,
        savedClicks: int.tryParse(json["savedClicks"] as String) ?? -1,
        sharedClicks: int.tryParse(json["sharedClicks"] as String) ?? -1,
        websiteClicks: int.tryParse(json["websiteClicks"] as String) ?? -1,
      );

  Map<String, dynamic> toJson() => {
        "storeUuid": storeUuid,
        "followers": followers,
        "impressions": impressions,
        "clicks": clicks,
        "phoneClicks": phoneClicks,
        "savedClicks": savedClicks,
        "sharedClicks": sharedClicks,
        "websiteClicks": websiteClicks,
      };
}

