import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';

import '../core/constants.dart';
import '../core/exception.dart';
import '../core/success.dart';
import '../data_models/user.dart';

const kType = "general";

class RemoteAuthSource {
  final Client http;
  final String serverUrl;

  RemoteAuthSource(this.http, this.serverUrl);


  void _handleError({required Response response}) {
    String message = "Unexpected Error";
    if (response.body != "") {
      final jsonResp = json.decode(response.body);
      message = jsonResp["Message"] as String;
    }
    if (response.statusCode == 401) {
      throw AuthorizationException(message);
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      throw RemoteDataSourceException(message);
    } else if (response.statusCode >= 500) {
      log("remote server error: $message");
      throw RemoteDataSourceException("Unexpected Remote Server Error");
    }
  }

  Future<String> getTerms() async {
    final uri = Uri.parse("$serverUrl/terms.php");
    print(uri.toString());
    //print("jwt req: " + jwt);

    try {
      // Send get request
      final response = await http.get(
        uri,
        // headers: {"jwt" : jwt},
      ).timeout(kTimeOutDuration);

      // MOCK RESPONSE
      // await Future.delayed(const Duration(seconds: 2));
      // final response = Response(jsonEncode(mockStoreList), 200,);
      //print(json.decode(response.body).toString());

      // Log status code
      print('[GET TERMS] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        return response.body;

      } else { _handleError( response: response); }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<String> getJwtFromRefreshToken(String refreshToken) async {
    final uri = Uri.parse("$serverUrl/refreshToken.php");
    log(uri.toString());

    final refreshMap = {
      "refreshToken" : refreshToken,
      "type" : kType,
    };

    try {
      // Send post request
      final response = await http.post(
          uri,
          headers: {"Content-Type": "application/json"},
          body: json.encode(refreshMap))
          .timeout(kTimeOutDuration
      );
      // MOCK RESPONSE
      // final response = Response("", 200, headers: {"jwt" : "12345"});

      // Log status code
      log('[REFRESH TOKEN] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print("refresh token header: ${response.headers['jwt']}");
        return response.headers['jwt'] ??  "";

      } else { _handleError( response: response); }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<Map<String, String>> updateRefreshToken(String refreshToken) async {
    final uri = Uri.parse("$serverUrl/updateRefreshToken.php");
    log(uri.toString());

    final refreshMap = {
      "refreshToken" : refreshToken,
      "type" : kType
    };

    try {
      // Send post request
      final response = await http.patch(
          uri,
          headers: {"Content-Type": "application/json"},
          body: json.encode(refreshMap))
          .timeout(kTimeOutDuration
      );
      // MOCK RESPONSE
      // final response = Response("", 200, headers: {"jwt" : "12345"});

      // Log status code
      log('[UPDATE REFRESH TOKEN] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // print("jwt token header: ${response.headers["jwt"]}");
        // print("refresh token header: ${response.headers["refreshtoken"]}");
        // print("all token header: ${response.headers}");
        return {
          "jwt" : response.headers["jwt"] ?? "",
          "refreshToken" : response.headers["refreshtoken"] ?? "",
        };

      } else { _handleError( response: response); }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<User> getCurrentUser(String jwt, String fbToken) async {
    final uri = Uri.parse("$serverUrl/getUser.php?type=$kType");
    log(uri.toString());

    try {
      // Send get request
      final response = await http.get(
          uri,
          headers: {"jwt": jwt, "fb-token": fbToken}
      ).timeout(kTimeOutDuration
      );
      // MOCK RESPONSE
      // final response = Response(jsonEncode(mockUser), 200, headers: {"jwt": jwt});
      // print(json.decode(response.body).toString());

      // Log status code
      log('[GET USER] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResp = json.decode(response.body);
        final user = User.fromJson(jsonResp as Map<String, dynamic>);

        //log("uuid: ${user.uuid}");
        //log("headers: ${response.headers}");
        //log("token header: ${response.headers['jwt']}");
        //log("token: ${jsonResp['token']}");
        return user;

      } else { _handleError( response: response); }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<ServerSuccess<User>> login(User user) async {
    final uri = Uri.parse("$serverUrl/loginUser.php");
    log(uri.toString());

    try {

      final userMap = {
        "email" : user.email,
        "password" : user.password,
        "firebaseToken" : user.firebaseToken,
        "type" : kType
      };

      // Send get request
      final response = await http
          .post(uri,
          headers: {"Content-Type": "application/json"},
          body: json.encode(userMap))
          .timeout(kTimeOutDuration
      );

      // MOCK RESPONSE
      // final response = Response(
      //     jsonEncode(mockUser),
      //     200,
      //     headers: {"jwt": "23456", "refresh-token": "23456"}
      // );

      // Log status code
      log('[LOGIN] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResp = json.decode(response.body);
        final user = User.fromJson(jsonResp as Map<String, dynamic>);

        final jwt = response.headers['jwt'] ?? "";
        final refreshToken = response.headers['refresh-token'] ?? "";
        // print("jwt: $jwt");
        // print("refresh-token: $refreshToken");
        return ServerSuccess(jwt: jwt, refreshToken: refreshToken, object: user);

      } else { _handleError( response: response); }

      throw RemoteDataSourceException("Unexpected Error");
    } catch (error) {
      log(error.toString());
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<ServerSuccess<User>> register(User user) async {
    final uri = Uri.parse("$serverUrl/registerUser.php");
    log(uri.toString());

    final userMap = user.toJson();
    log(userMap.toString());

    try {
      // Send get request
      final response = await http
          .post(uri,
          headers: {"Content-Type": "application/json"},
          body: json.encode(userMap))
          .timeout(kTimeOutDuration
      );

      // MOCK RESPONSE
      // final response = Response(
      //     jsonEncode(mockUser),
      //     201,
      //     headers: {"jwt": "23456", "refresh-token": "23456"}
      // );

      // Log status code
      log('[REGISTER] Response Code: ${response.statusCode}');

      if (response.statusCode == 201) {
        final jsonResp = json.decode(response.body);
        final user = User.fromJson(jsonResp as Map<String, dynamic>);

        final jwt = response.headers['jwt'] ?? "";
        final refreshToken = response.headers['refresh-token'] ?? "";
        // print("jwt: $jwt");
        // print("refresh-token: $refreshToken");
        return ServerSuccess(jwt: jwt, refreshToken: refreshToken, object: user);

      } else if (response.statusCode == 200 || response.statusCode == 409) {
        throw RemoteDataSourceException("Email already in use");
      } else { _handleError( response: response); }

      throw RemoteDataSourceException("Unexpected Error");
    } catch (error) {
      log(error.toString());
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<ServerSuccess> logout(String email, String refreshToken) async {
    final uri = Uri.parse("$serverUrl/logout.php");
    log(uri.toString());

    final userMap = {
      "email" : email,
      "refreshToken" : refreshToken,
      "type" : kType,
    };

    try {
      // Send get request
      final response = await http
          .post(uri,
          headers: {"Content-Type": "application/json"},
          body: json.encode(userMap))
          .timeout(kTimeOutDuration
      );

      // MOCK RESPONSE
      // final response = Response("", 200);

      // Log status code
      log('[LOGOUT] Response Code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 401) {
        return ServerSuccess();

      } else { _handleError( response: response); }

      throw RemoteDataSourceException("Unexpected Error");
    } catch (error) {
      log(error.toString());
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<User> updateEmail(String jwt, User user) async {
    final uri = Uri.parse("$serverUrl/updateUserEmail.php");
    log(uri.toString());

    final userMap = {
      "password" : user.password,
      "newEmail" : user.email,
      "type" : kType,
    };

    try {
      // Send post request
      final response = await http
          .patch(uri,
        headers: {"Content-Type": "application/json", "jwt" : jwt},
        body: json.encode(userMap),
      ).timeout(kTimeOutDuration);

      // Log status code
      log('[UPDATE USER EMAIL] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        return user;
      } else { _handleError( response: response); }

      throw RemoteDataSourceException("Unexpected Error");
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }

  }

  Future<User> updatePassword(String jwt, User user, String newPassword) async {
    final uri = Uri.parse("$serverUrl/updateUserPassword.php");
    log(uri.toString());

    final userMap = {
      "password" : user.password,
      "newPassword" : newPassword,
      "type" : kType,
    };

    try {
      // Send post request
      final response = await http
          .patch(uri,
        headers: {"Content-Type": "application/json", "jwt" : jwt},
        body: json.encode(userMap),
      ).timeout(kTimeOutDuration);

      // Log status code
      log('[UPDATE USER PASSWORD] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        return user;
      } else { _handleError( response: response); }

      throw RemoteDataSourceException("Unexpected Error");
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<User> updateUsername(String jwt, User user) async {
    final uri = Uri.parse("$serverUrl/updateUserUsername.php");
    log(uri.toString());

    final userMap = {
      "password" : user.password,
      "firstName" : user.firstName,
      "lastName" : user.lastName,
      "type" : kType,
    };

    try {
      // Send post request
      final response = await http
          .patch(uri,
        headers: {"Content-Type": "application/json", "jwt" : jwt},
        body: json.encode(userMap),
      ).timeout(kTimeOutDuration);

      // Log status code
      log('[UPDATE USERNAME] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        return user;
      } else { _handleError( response: response); }

      throw RemoteDataSourceException("Unexpected Error");
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<ServerSuccess> passwordResetRequest(String email) async {
    final uri = Uri.parse("$serverUrl/passwordResetRequest.php");
    log(uri.toString());

    final emailMap = {
      "email" : email,
      "type" : kType,
    };

    try {
      // Send post request
      final response = await
      http.post(uri,
        headers: {"Content-Type": "application/json"},
        body: json.encode(emailMap),
      ).timeout(kTimeOutDuration);

      // Log status code
      log('[PASSWORD RESET REQUEST] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        return ServerSuccess();
      } else { _handleError( response: response); }

      throw RemoteDataSourceException("Unexpected Error");
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<ServerSuccess> passwordReset(String password, String passwordResetCode) async {
    final uri = Uri.parse("$serverUrl/passwordReset.php");
    log(uri.toString());

    final resetPasswordMap = {
      "password" : password,
      "code" : passwordResetCode,
      "type" : kType,
    };

    try {
      // Send post request
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: json.encode(resetPasswordMap),
      ).timeout(kTimeOutDuration);

      // Log status code
      log('[PASSWORD RESET] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        return ServerSuccess();
      } else { _handleError( response: response); }

      throw RemoteDataSourceException("Unexpected Error");
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }

  }

  Future<ServerSuccess> deleteAccount(String jwt, User user) async {
    final uri = Uri.parse("$serverUrl/deleteAccount.php");
    log(uri.toString());

    final userMap = {
      "password" : user.password,
      "email" : user.email,
      "type" : kType,
    };

    try {
      // Send post request
      final response = await http
          .patch(uri,
        headers: {"Content-Type": "application/json", "jwt" : jwt},
        body: json.encode(userMap),
      ).timeout(kTimeOutDuration);

      // Log status code
      log('[DELETE ACCOUNT] Response Code: ${response.statusCode}');

      if (response.statusCode == 204) {
        return ServerSuccess();
      } else { _handleError( response: response); }

      throw RemoteDataSourceException("Unexpected Error");
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }
}