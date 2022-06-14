import 'dart:convert';

import 'package:findgo/core/constants.dart';
import 'package:findgo/core/exception.dart';
import 'package:findgo/core/success.dart';
import 'package:findgo/data_models/special.dart';
import 'package:findgo/data_models/store.dart';
import 'package:http/http.dart';

class RemoteSpecialsDataSource {
  final Client http;
  final String serverUrl;

  RemoteSpecialsDataSource(this.http, this.serverUrl);

  void _handleError({required Response response}) {
    if (response.body.isEmpty) {
      throw RemoteDataSourceException("Unexpected Remote Server Error");
    }
    final jsonResp = json.decode(response.body) as Map<String, dynamic>;
    final message = jsonResp["Message"] as String;
    if (response.statusCode == 401) {
      throw AuthorizationException(message);
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      throw RemoteDataSourceException(message);
    } else if (response.statusCode >= 500) {
      print("remote server error: $message");
      throw RemoteDataSourceException("Unexpected Remote Server Error");
    }
  }

  // Request
  Future<Set<Special>> getAllSpecials() async {
    final uri = Uri.parse("$serverUrl/getAllActiveSpecials.php");
    print(uri.toString());
    //print("jwt req: " + jwt);

    try {
      // Send get request
      final response = await http
          .get(
            uri,
          )
          .timeout(kTimeOutDuration);

      // MOCK RESPONSE
      // await Future.delayed(const Duration(seconds: 2));
      // final response = Response(jsonEncode(mockSpecialsList), 200,);
      //print(json.decode(response.body).toString());

      // Log status code
      print('[GET ALL SPECIALS] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        //print(response.body);

        final jsonList = json.decode(response.body) as List;
        final specialList = jsonList
            .map(
              (jsonSpecial) =>
                  Special.fromJson(jsonSpecial as Map<String, dynamic>),
            )
            .toSet();

        return specialList;
      } else {
        _handleError(response: response);
      }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<Special> getSpecialByUuid(String uuid) async {
    final uri = Uri.parse("$serverUrl/getSpecialById.php?uuid=$uuid");
    print(uri.toString());
    //print("jwt req: " + jwt);

    try {
      // Send get request5
      final response = await http
          .get(
            uri,
          )
          .timeout(kTimeOutDuration);

      // MOCK RESPONSE
      // await Future.delayed(const Duration(seconds: 2));
      // final response = Response(jsonEncode(mockSpecialsList), 200,);
      //print(json.decode(response.body).toString());

      // Log status code
      print('[GET SPECIAL: $uuid ] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonSpecial = json.decode(response.body);
        final special = Special.fromJson(jsonSpecial as Map<String, dynamic>);

        return special;
      } else {
        _handleError(response: response);
      }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<Set<Store>> getAllStores() async {
    final uri = Uri.parse("$serverUrl/getAllActiveStores.php");
    print(uri.toString());
    //print("jwt req: " + jwt);

    try {
      // Send get request
      final response = await http
          .get(
            uri,
            // headers: {"jwt" : jwt},
          )
          .timeout(kTimeOutDuration);

      // MOCK RESPONSE
      // await Future.delayed(const Duration(seconds: 2));
      // final response = Response(jsonEncode(mockStoreList), 200,);
      //print(json.decode(response.body).toString());

      // Log status code
      print('[GET ALL STORE] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        //print(response.body.toString());

        final jsonList = json.decode(response.body) as List;
        final storeList = jsonList
            .map(
              (jsonStore) => Store.fromJson(jsonStore as Map<String, dynamic>),
            )
            .toSet();

        return storeList;
      } else {
        _handleError(response: response);
      }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<Set<String>> getAllFollowedStores(String jwt) async {
    final uri = Uri.parse("$serverUrl/getFollowedStoreIds.php");
    print(uri.toString());
    //print("jwt req: " + jwt);

    try {
      // Send get request
      final response = await http.get(
        uri,
        headers: {"jwt": jwt},
      ).timeout(kTimeOutDuration);

      // MOCK RESPONSE
      // await Future.delayed(const Duration(seconds: 2));
      // final response = Response(jsonEncode(mockFollowedStoreUuidList), 200,);
      // final response = Response("none", 500,);
      //print(json.decode(response.body).toString());

      // Log status code
      print('[GET FOLLOWED STORE UUIDS] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        //print(response.body.toString());

        final jsonList = json.decode(response.body) as List;
        final followedStoreList =
            jsonList.map((jsonUuid) => jsonUuid as String).toSet();
        // print(followedStoreList);

        return followedStoreList;
      } else {
        _handleError(response: response);
      }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<ServerSuccess> followStore(
    String jwt,
    String storeUuid, {
    required bool status,
  }) async {
    final uri = Uri.parse("$serverUrl/followStore.php");
    print(uri.toString());

    final followMap = {
      "storeUuid": storeUuid,
      "status": status ? 1 : 0,
    };

    try {
      // Send get request
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json", "jwt": jwt},
            body: json.encode(followMap),
          )
          .timeout(
            kTimeOutDuration,
          );

      // MOCK RESPONSE
      // final response = Response("", 200);

      // Log status code
      print('[FOLLOW ? UNFOLLOW STORE] Response Code: ${response.statusCode}');

      if (response.statusCode == 201) {
        return ServerSuccess();
      } else {
        _handleError(response: response);
      }

      throw RemoteDataSourceException("Unexpected Error");
    } catch (error) {
      print(error.toString());
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<Set<String>> getAllNotifyStores(String jwt) async {
    final uri = Uri.parse("$serverUrl/getNotifyStoreIds.php");
    print(uri.toString());
    //print("jwt req: " + jwt);

    try {
      // Send get request
      final response = await http.get(
        uri,
        headers: {"jwt": jwt},
      ).timeout(kTimeOutDuration);

      // MOCK RESPONSE
      // await Future.delayed(const Duration(seconds: 2));
      // final response = Response(jsonEncode(mockFollowedStoreUuidList), 200,);
      // final response = Response("none", 500,);
      //print(json.decode(response.body).toString());

      // Log status code
      print('[GET NOTIFY STORE UUIDS] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        //print(response.body.toString());

        final jsonList = json.decode(response.body) as List;
        final followedStoreList =
            jsonList.map((jsonUuid) => jsonUuid as String).toSet();
        // print(followedStoreList);

        return followedStoreList;
      } else {
        _handleError(response: response);
      }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<ServerSuccess> notificationFromStore(
    String jwt,
    String storeUuid, {
    required bool status,
  }) async {
    final uri = Uri.parse("$serverUrl/notificationFromStore.php");
    print(uri.toString());

    final followMap = {
      "storeUuid": storeUuid,
      "status": status ? 1 : 0,
    };

    try {
      // Send get request
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json", "jwt": jwt},
            body: json.encode(followMap),
          )
          .timeout(
            kTimeOutDuration,
          );

      // MOCK RESPONSE
      // final response = Response("", 200);

      // Log status code
      print('[NOTIFY ? UN-NOTIFY STORE] Response Code: ${response.statusCode}');

      if (response.statusCode == 201) {
        return ServerSuccess();
      } else {
        _handleError(response: response);
      }

      throw RemoteDataSourceException("Unexpected Error");
    } catch (error) {
      print(error.toString());
      throw RemoteDataSourceException(error.toString());
    }
  }

  // Stats
  Future<ServerSuccess> addSpecialStatIncrement(
    String jwt,
    String specialUuid,
    SpecialStat specialStat,
  ) async {
    // return ServerSuccess();
    final uri = Uri.parse("$serverUrl/addSpecialStatIncrement.php");
    print(uri.toString());

    late String type;
    switch (specialStat) {
      case SpecialStat.impression:
        {
          type = "impressions";
        }
        break;

      case SpecialStat.click:
        {
          type = "clicks";
        }
        break;

      case SpecialStat.phoneClick:
        {
          type = "phoneClicks";
        }
        break;

      case SpecialStat.savedClick:
        {
          type = "savedClicks";
        }
        break;

      case SpecialStat.shareClick:
        {
          type = "shareClicks";
        }
        break;

      case SpecialStat.websiteClick:
        {
          type = "websiteClicks";
        }
        break;

      default:
        {
          throw RemoteDataSourceException(
            "Unexpected Error: No special stats type selected",
          );
        }
    }

    final clickedMap = {"specialUuid": specialUuid, "type": type};

    try {
      // Send get request
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json", "jwt": jwt},
            body: json.encode(clickedMap),
          )
          .timeout(
            kTimeOutDuration,
          );

      // MOCK RESPONSE
      // final response = Response("", 200);

      // Log status code
      print(
        '[SPECIAL INCREMENT CLICKED] Response Code: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return ServerSuccess();
      } else {
        _handleError(response: response);
      }

      throw RemoteDataSourceException("Unexpected Error");
    } catch (error) {
      print(error.toString());
      throw RemoteDataSourceException(error.toString());
    }
  }
}

