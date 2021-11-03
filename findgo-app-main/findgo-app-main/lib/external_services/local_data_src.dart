import 'dart:convert';

import 'package:findgo/data_models/lat_lon.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../core/exception.dart';
import '../core/success.dart';
import '../data_models/store.dart';

const jwtKey = 'jwt';
const refreshTokenKey = 'refreshToken';
const currentUserKey = 'currentUser';

const followedStoreKey = "followed_stores";
const notifyStoreKey = "notify_stores";

const savedSpecialsKey = "saved_specials";
const themeKey = "theme";

const locationKey = "locatation";
const locationRangeKey = "locatation_range";

class LocalDataSource {
  final Box hiveBox;
  String _userUuid = "";

  LocalDataSource(this.hiveBox);

  Future<void> _getUserUuid() async {
    try {
      final token = await jwt;
      // print("token: $token");
      _userUuid = Jwt.parseJwt(token)["uuid"] as String;
      // print("userUuid: $_userUuid");
    } catch (e) {
      print(e);
    }
  }

  // Followed Store Uuids
  Future<void> addFollowedStore(String storeUuid) async {
    final storesList = await getFollowedStores();
    storesList.add(storeUuid);
    await setFollowedStores(storesList);
  }

  Future<void> removeFollowedStore(String storeUuid) async {
    final storesList = await getFollowedStores();
    storesList.remove(storeUuid);
    await setFollowedStores(storesList);
  }

  Future<Set<String>> getFollowedStores() async {
    await _getUserUuid();

    final followedStoreUuidList =
        hiveBox.get("${followedStoreKey}_$_userUuid", defaultValue: <String>[])
            as List<String>;
    // print ("getFollowedStores COMPLETE $followedStoreUuidList");
    return followedStoreUuidList.toSet();
  }

  Future<void> setFollowedStores(Set<String> followedStoreUuidList) async {
    await hiveBox.put(
        "${followedStoreKey}_$_userUuid", followedStoreUuidList.toList());
    // print ("setFollowedStores COMPLETE");
  }

  // Notifications From Stores
  Future<void> addNotifyStore(String storeUuid) async {
    final storesList = await getNotifyStores();
    storesList.add(storeUuid);
    await setNotifyStores(storesList);
  }

  Future<void> removeNotifyStore(String storeUuid) async {
    final storesList = await getNotifyStores();
    storesList.remove(storeUuid);
    await setNotifyStores(storesList);
  }

  Future<Set<String>> getNotifyStores() async {
    await _getUserUuid();

    final notifyStoreUuidList =
        hiveBox.get("${notifyStoreKey}_$_userUuid", defaultValue: <String>[])
            as List<String>;
    // print ("getNotifyStores COMPLETE $notifyStoreUuidList");
    return notifyStoreUuidList.toSet();
  }

  Future<void> setNotifyStores(Set<String> notifyStoreUuidList) async {
    await hiveBox.put(
        "${notifyStoreKey}_$_userUuid", notifyStoreUuidList.toList());
    // print ("setNotifyStores COMPLETE");
  }

  Future<void> checkFollowedStores(List<Store> storeList) async {
    final followedStoreUuids = await getFollowedStores();
    final followedStoreCount = followedStoreUuids.length;
    // print("followedStoreCount $followedStoreCount");

    final List<String> removeAtUuid = [];

    if (followedStoreUuids.isNotEmpty) return;

    for (final storeUuid in followedStoreUuids) {
      final found = storeList.any((store) => store.uuid == storeUuid);
      if (!found) removeAtUuid.add(storeUuid);
    }

    for (final storeUuid in removeAtUuid) {
      followedStoreUuids.remove(storeUuid);
    }

    print(
        "followedStoreCount $followedStoreCount : ${followedStoreUuids.length}");
    if (followedStoreCount != followedStoreUuids.length) {
      setFollowedStores(followedStoreUuids);
    }
  }

  Future<void> clearLocalStorage() async {
    hiveBox.deleteFromDisk();
  }

  // Auth
  Future<String> get jwt async {
    try {
      // Get jwt
      // var jwt = html.window.localStorage[jwtKey]; // Web
      // var jwt = prefs.getString(jwtKey); // Web - shared prefs
      // var jwt = await secureStorage.read(key: jwtKey); // Mobile
      var jwt = await hiveBox.get(jwtKey, defaultValue: "null") as String;

      // Check jwt not null
      if (jwt == "null") {
        throw AuthorizationException('No token stored');
      }

      if (jwt[0] == "'") jwt = jwt.substring(1, jwt.length);
      if (jwt[jwt.length - 1] == "'") jwt = jwt.substring(0, jwt.length - 1);

      // log("[FETCHED JWT] : $jwt");
      return jwt;
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<String> get refreshToken async {
    try {
      // Get jwt
      // var refreshToken = html.window.localStorage[refreshTokenKey]; // Web
      // var refreshToken = prefs.getString(refreshTokenKey); // Web - shared prefs
      // var refreshToken = await secureStorage.read(key: refreshTokenKey); // Mobile
      var refreshToken =
          await hiveBox.get(refreshTokenKey, defaultValue: "null") as String;

      print(refreshToken);

      // Check jwt not null
      if (refreshToken == "null") {
        throw AuthorizationException('No token stored');
      }

      if (refreshToken[0] == "'")
        refreshToken = refreshToken.substring(1, refreshToken.length);
      if (refreshToken[refreshToken.length - 1] == "'")
        refreshToken = refreshToken.substring(0, refreshToken.length - 1);

      //print("[FETCHED REFRESH TOKEN] : $refreshToken");
      return refreshToken;
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<ThemeMode> get themeMode async {
    final theme = await hiveBox.get(themeKey, defaultValue: "light") as String;
    return theme == "dark" ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setTheme(String theme) async {
    //print("[STORING JWT] : $jwt");
    await hiveBox.put(themeKey, theme);
  }

  // Future<User> get currentUser async {
  //   try {
  //     // final response = html.window.localStorage[currentUserKey];
  //     if (response == null || response == 'null') { throw CacheException('No token stored'); }
  //     // if (response == null || response == 'null') { return kUnauthorizedUser; }
  //
  //     final jsonUser = jsonDecode(response); // Web
  //     //log("jsonUser $jsonUser");
  //     final currentUser = User.fromJson(jsonUser as Map<String, dynamic>);
  //     //log("currentUser $currentUser");
  //
  //     if (currentUser.uuid == "-1") { throw CacheException('No token stored');  }
  //
  //     //log("[FETCHED CURRENT USER] : $currentUser");
  //     return currentUser;
  //   } catch(e) {
  //     throw CacheException(e.toString());
  //   }
  // }

  Future<Success> storeJwt(String jwt) async {
    //print("[STORING JWT] : $jwt");
    try {
      // html.window.localStorage[jwtKey] = jwt; // Web
      // prefs.setString(jwtKey, jwt); // Web - Shared Prefs
      // await secureStorage.write(key: jwtKey, value: jwt); // Mobile
      await hiveBox.put(jwtKey, jwt);

      return CacheSuccess();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<Success> storeRefreshToken(String refreshToken) async {
    // print("[STORING REFRESH TOKEN] : $refreshToken");
    try {
      // html.window.localStorage[refreshTokenKey] = refreshToken; // Web
      // prefs.setString(refreshTokenKey, refreshToken); // Web - Shared Prefs
      //await secureStorage.write(key: refreshTokenKey, value: refreshToken); // Mobile
      await hiveBox.put(refreshTokenKey, refreshToken);

      return CacheSuccess();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  // Saved
  Future<Set<String>> getSavedSpecials() async {
    await _getUserUuid();
    final savedSpecialsUuidList = await hiveBox
            .get("${savedSpecialsKey}_$_userUuid", defaultValue: <String>[])
        as List<String>;
    // print ("getFollowedStores COMPLETE $followedStoreUuidList");
    // print ("getSavedSpecials COMPLETE: $savedSpecialsUuidList");
    return savedSpecialsUuidList.toSet();
  }

  Future<void> setSavedSpecials(Set<String> savedSpecialsUuidList) async {
    await _getUserUuid();
    await hiveBox.put(
      "${savedSpecialsKey}_$_userUuid",
      savedSpecialsUuidList.toList(),
    );
    // print ("setSavedSpecials COMPLETE: $savedSpecialsUuidList");
  }

  Future<void> addSavedSpecial(String specialUuid) async {
    final specialSet = await getSavedSpecials();
    // print("Save Special: $specialUuid");
    specialSet.add(specialUuid);
    await setSavedSpecials(specialSet);
  }

  Future<void> removeSavedSpecial(String specialUuid) async {
    final specialSet = await getSavedSpecials();
    specialSet.remove(specialUuid);
    await setSavedSpecials(specialSet);
  }

  // INFO: LOCATION DATA
  Future<void> storeCurrentLocation(LatLng latLng) async {
    await _getUserUuid();
    await hiveBox.put("${locationKey}_$_userUuid", jsonEncode(latLng.toJson));
  }

  Future<LatLng> fetchLastLocation() async {
    await _getUserUuid();
    final locationJson = await hiveBox.get(
      "${locationKey}_$_userUuid",
      defaultValue: '{"lat: null, lng: null"}',
    ) as String;
    return LatLng.fromJson(jsonDecode(locationJson) as Map<String, dynamic>);
  }

  Future<void> storeLocationRange(double? locationRange) async {
    await _getUserUuid();
    await hiveBox.put("${locationRangeKey}_$_userUuid", locationRange);
  }

  Future<double?> fetchLocationRange() async {
    await _getUserUuid();
    return await hiveBox.get(
      "${locationRangeKey}_$_userUuid",
    ) as double?;
  }
}
