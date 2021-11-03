// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Mobile
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import '../core/exception.dart';
import '../core/success.dart';
import '../data_models/user.dart';

const jwtKey = 'jwt';
const refreshTokenKey = 'refreshToken';
const currentUserKey = 'current_user';
const currentOrderCartKey = 'current_order_cart';

const cacheSuccessMessage = '[CACHE STORE JWT] success';

class LocalDataSource {
  //final FlutterSecureStorage secureStorage; // Mobile
  // LocalDataSource(this.secureStorage);

  // Getters
  Future<String> get jwt async {
    try {
      // Get jwt
      var jwt = html.window.localStorage[jwtKey]; // Web
      // var jwt = prefs.getString(jwtKey); // Web - shared prefs
      //final jwt = await secureStorage.read(key: jwtKey); // Mobile

      // Check jwt not null
      if (jwt == null || jwt == 'null') { throw CacheException('No token stored'); }

      if (jwt[0] == "'") jwt = jwt.substring(1, jwt.length);
      if (jwt[jwt.length-1] == "'") jwt = jwt.substring(0, jwt.length-1);

      // log("[FETCHED JWT] : $jwt");
      return jwt;
    } catch(e) {
      throw CacheException(e.toString());
    }
  }

  Future<String> get refreshToken async {
    try {
      // Get jwt
      var refreshToken = html.window.localStorage[refreshTokenKey]; // Web
      // var refreshToken = prefs.getString(refreshTokenKey); // Web - shared prefs
      //final refreshToken = await secureStorage.read(key: refreshTokenKey); // Mobile

      // Check jwt not null
      if (refreshToken == null || refreshToken == 'null') { throw CacheException('No token stored'); }

      if (refreshToken[0] == "'") refreshToken = refreshToken.substring(1, refreshToken.length);
      if (refreshToken[refreshToken.length-1] == "'") refreshToken = refreshToken.substring(0, refreshToken.length-1);

      //print("[FETCHED REFRESH TOKEN] : $refreshToken");
      return refreshToken;
    } catch(e) {
      throw CacheException(e.toString());
    }
  }

  Future<User> get currentUser async {
    try {
      final response = html.window.localStorage[currentUserKey];
      if (response == null || response == 'null') { throw CacheException('No token stored'); }
      // if (response == null || response == 'null') { return kUnauthorizedUser; }

      final jsonUser = jsonDecode(response); // Web
      //log("jsonUser $jsonUser");
      final currentUser = User.fromJson(jsonUser as Map<String, dynamic>);
      //log("currentUser $currentUser");

      if (currentUser.uuid == "-1") { throw CacheException('No token stored');  }

      //log("[FETCHED CURRENT USER] : $currentUser");
      return currentUser;
    } catch(e) {
      throw CacheException(e.toString());
    }
  }

  // Setters
  Future<Success> storeJwt(String jwt) async {
    //print("[STORING JWT] : $jwt");
    try {
      html.window.localStorage[jwtKey] = jwt; // Web
      // prefs.setString(jwtKey, jwt); // Web - Shared Prefs
      //await secureStorage.write(key: jwtKey, value: jwt); // Mobile

      return CacheSuccess();
    } catch(e) {
      throw CacheException(e.toString());
    }
  }

  Future<Success> storeRefreshToken(String refreshToken) async {
    // print("[STORING REFRESH TOKEN] : $refreshToken");
    try {
      html.window.localStorage[refreshTokenKey] = refreshToken; // Web
      // prefs.setString(refreshTokenKey, refreshToken); // Web - Shared Prefs
      //await secureStorage.write(key: refreshTokenKey, value: refreshToken); // Mobile

      return CacheSuccess();
    } catch(e) {
      throw CacheException(e.toString());
    }
  }

  Future<Success> storeCurrentUser(User user) async {
    // log("[STORING CURRENT USER] : $user");
    try {
      final userJson = jsonEncode(user.toJson());
      html.window.localStorage[currentUserKey] = userJson; // Web

      return CacheSuccess();
    } catch(e) {
      throw CacheException(e.toString());
    }
  }

}