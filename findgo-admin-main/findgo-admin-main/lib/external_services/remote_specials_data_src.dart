import 'dart:convert';

import 'package:findgo_admin/data_models/lat_lon.dart';
import 'package:findgo_admin/data_models/store_stats.dart';
import 'package:http/http.dart';

import '../core/constants.dart';
import '../core/exception.dart';
import '../core/success.dart';
import '../core/util.dart';
import '../data_models/location.dart';
import '../data_models/special.dart';
import '../data_models/store.dart';
import '../data_models/store_category.dart';

class RemoteSpecialsDataSource {
  final Client http;
  final String serverUrl;

  RemoteSpecialsDataSource(this.http, this.serverUrl);

  void _handleError({required Response response}) {
    if (response.body.isEmpty) {
      throw RemoteDataSourceException("Unexpected Remote Server Error");
    }
    final jsonResp = json.decode(response.body);
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

  // STORES

  Future<Store> createStore(String jwt, Store store) async {
    final uri = Uri.parse("$serverUrl/createStore.php");
    // print(uri.toString());
    //print("jwt req: " + jwt);

    try {
      final createStoreMap = store.toJson();
      // print(createStoreMap);

      // Send post request
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json", "jwt": jwt},
            body: json.encode(createStoreMap),
          )
          .timeout(kTimeOutDuration);

      // MOCK RESPONSE
      await Future.delayed(const Duration(seconds: 1));
      // final response = Response('{"storeUuid" : "20", "imageUrl : """}', 201);
      // final response = Response('{"storeUuid" : "20", "imageUrl : """}', 500);
      // print(json.decode(response.body).toString());

      // Log status code
      print('[CREATE STORE] Response Code: ${response.statusCode}');
      // print(response.body);

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        store.uuid = jsonResponse["storeUuid"] as String;
        store.imageUrl = jsonResponse["imageUrl"] as String;
        return store;
      } else {
        _handleError(response: response);
      }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  // LOCATIONS

  Future<Location> createLocation(String jwt, Location location) async {
    final uri = Uri.parse("$serverUrl/createLocation.php");
    // print(uri.toString());
    //print("jwt req: " + jwt);

    try {
      final createLocationMap = location.toJson();
      // print(createLocationMap);

      // Send post request
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json", "jwt": jwt},
            body: json.encode(createLocationMap),
          )
          .timeout(kTimeOutDuration);

      // MOCK RESPONSE
      await Future.delayed(const Duration(seconds: 1));
      // final response = Response('{"locationUuid" : "20", "imageUrl : """}', 201);
      // final response = Response('{"locationUuid" : "20", "imageUrl : """}', 500);
      // print(json.decode(response.body).toString());

      // Log status code
      print('[CREATE LOCATION] Response Code: ${response.statusCode}');
      // print(response.body);

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        location.id = int.parse(jsonResponse["id"] as String);
        return location;
      } else {
        _handleError(response: response);
      }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<Set<Store>> getAllStores(String jwt) async {
    final uri = Uri.parse("$serverUrl/getAllStores.php");
    print(uri.toString());
    //print("jwt req: " + jwt);

    try {
      // Send get request
      final response = await http.get(
        uri,
        headers: {"jwt": jwt},
      ).timeout(kTimeOutDuration);

      // MOCK RESPONSE
      // await Future.delayed(const Duration(seconds: 1));
      // final response = Response(jsonEncode(mockStoreList), 200,);
      //print(json.decode(response.body).toString());

      // Log status code
      print('[GET ALL STORE] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        //print(response.body.toString());

        final jsonList = json.decode(response.body) as List;
        print("==========");
        final storeList = jsonList
            .map(
              (jsonStore) => Store.fromJson(jsonStore as Map<String, dynamic>),
            )
            .toSet();
        print("==========");

        return storeList;
      } else {
        _handleError(response: response);
      }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<Set<Location>> getAllLocations(String jwt) async {
    final uri = Uri.parse("$serverUrl/getAllLocations.php");
    print(uri.toString());
    //print("jwt req: " + jwt);

    try {
      // Send get request
      final response = await http.get(
        uri,
        headers: {"jwt": jwt},
      ).timeout(kTimeOutDuration);

      // MOCK RESPONSE
      // await Future.delayed(const Duration(seconds: 1));
      // final response = Response(jsonEncode(mockLocationList), 200,);
      //print(json.decode(response.body).toString());

      // Log status code
      print('[GET ALL LOCATION] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        //print(response.body.toString());

        final jsonList = json.decode(response.body) as List;
        final storeList = jsonList
            .map(
              (jsonLocation) => Location.fromJson(jsonLocation as Map<String, dynamic>),
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

  Future<Store> updateStore(String jwt, Store store) async {
    final uri = Uri.parse("$serverUrl/updateStore.php");
    print(uri.toString());
    //print("jwt req: " + jwt);

    try {
      final updatedStoreMap = store.toJson();
      // print(updatedStoreMap);

      // Send post request
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json", "jwt": jwt},
            body: json.encode(updatedStoreMap),
          )
          .timeout(kTimeOutDuration);

      // MOCK RESPONSE
      // await Future.delayed(const Duration(seconds: 2));
      // final response = Response('{"imageUrl : """}', 200);
      //print(json.decode(response.body).toString());

      // Log status code
      print('[UPDATE STORE] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        store.image = null;
        store.imageUrl = jsonResponse["imageUrl"] as String;
        return store;
      } else {
        _handleError(response: response);
      }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<Location> updateLocation(String jwt, Location location) async {
    final uri = Uri.parse("$serverUrl/updateLocation.php");
    print(uri.toString());
    //print("jwt req: " + jwt);

    try {
      final updatedLocationMap = location.toJson();
      // print(updatedLocationMap);

      // Send post request
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json", "jwt": jwt},
            body: json.encode(updatedLocationMap),
          )
          .timeout(kTimeOutDuration);

      // MOCK RESPONSE
      // await Future.delayed(const Duration(seconds: 2));
      // final response = Response('{"imageUrl : """}', 200);
      //print(json.decode(response.body).toString());

      // Log status code
      print('[UPDATE LOCATION] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return location;
      } else {
        _handleError(response: response);
      }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<ServerSuccess> deleteStore(String jwt, Store store) async {
    final uri = Uri.parse("$serverUrl/deleteStore.php");
    print(uri.toString());

    try {
      final deleteStoreMap = {
        "storeUuid": store.uuid,
        "imageUrl": store.imageUrl,
      };

      // Send post request
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json", "jwt": jwt},
            body: json.encode(deleteStoreMap),
          )
          .timeout(kTimeOutDuration);

      // MOCK RESPONSE
      // await Future.delayed(const Duration(seconds: 1));
      // final response = Response("", 204,);
      //print(json.decode(response.body).toString());

      // Log status code
      print('[DELETE STORE] Response Code: ${response.statusCode}');

      if (response.statusCode == 204) {
        return ServerSuccess();
      } else {
        _handleError(response: response);
      }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<ServerSuccess> deleteLocation(String jwt, Location location) async {
    final uri = Uri.parse("$serverUrl/deleteLocation.php");
    print(uri.toString());

    try {
      final deleteLocationMap = {
        "id": location.id,
      };

      // Send post request
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json", "jwt": jwt},
            body: json.encode(deleteLocationMap),
          )
          .timeout(kTimeOutDuration);

      // MOCK RESPONSE
      // await Future.delayed(const Duration(seconds: 1));
      // final response = Response("", 204,);
      //print(json.decode(response.body).toString());

      // Log status code
      print('[DELETE LOCATION] Response Code: ${response.statusCode}');

      if (response.statusCode == 204) {
        return ServerSuccess();
      } else {
        _handleError(response: response);
      }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<Store> toggleStoreActivate(String jwt, Store store) async {
    final uri = Uri.parse("$serverUrl/toggleStoreActive.php");
    print(uri.toString());
    //print("jwt req: " + jwt);

    try {
      // Status 1 == active // 2 == inactive
      final updatedStoreMap = {
        "storeUuid": store.uuid,
        "status": store.status == StoreStatus.inactive ? 2 : 1,
      };

      // Send post request
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json", "jwt": jwt},
            body: json.encode(updatedStoreMap),
          )
          .timeout(kTimeOutDuration);

      // MOCK RESPONSE
      // await Future.delayed(const Duration(seconds: 2));
      // final response = Response('{"imageUrl : """}', 201);
      //print(json.decode(response.body).toString());

      // Log status code
      print(
        '[ACTIVATE/DEACTIVATE STORE] Response Code: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return store;
      } else {
        _handleError(response: response);
      }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<Set<StoreCategory>> getAllStoreCategories() async {
    final uri = Uri.parse("$serverUrl/getAllStoreCategories.php");
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
      // await Future.delayed(const Duration(seconds: 1));
      // final response = Response(jsonEncode(mockStoreList), 200,);
      //print(json.decode(response.body).toString());

      // Log status code
      print('[GET ALL STORE CATEGORIES] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        //print(response.body.toString());

        final jsonList = json.decode(response.body) as List;
        final categoryList = jsonList
            .map(
              (jsonCategory) =>
                  StoreCategory.fromJson(jsonCategory as Map<String, dynamic>),
            )
            .toSet();

        return categoryList;
      } else {
        _handleError(response: response);
      }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<StoreStats> getStoreStats(String jwt, Store store) async {
    final uri = Uri.parse("$serverUrl/getStoreStats.php");
    print(uri.toString());
    // print("jwt req: " + jwt);

    try {
      // Send get request
      final response = await http.get(
        uri,
        headers: {"jwt": jwt},
      ).timeout(kTimeOutDuration);

      // MOCK RESPONSE
      // await Future.delayed(const Duration(seconds: 1));
      // final response = Response(jsonEncode(mockSpecialsList), 200,);
      //print(json.decode(response.body).toString());

      // Log status code
      print('[GET STORE STATS] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        //print(response.body.toString());
        final jsonStats = json.decode(response.body) as Map<String, dynamic>;
        final storeStats = StoreStats.fromJson(jsonStats);

        return storeStats;
      } else {
        _handleError(response: response);
      }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  // SPECIALS

  Future<Special> createSpecial(String jwt, Special special) async {
    final uri = Uri.parse("$serverUrl/createSpecial.php");
    print(uri.toString());
    //print("jwt req: " + jwt);

    try {
      special.status = SpecialStatus.pending;
      final createSpecialMap = special.toJson();
      // print(createSpecialMap);

      // Send post request
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json", "jwt": jwt},
            body: json.encode(createSpecialMap),
          )
          .timeout(kTimeOutDuration);

      // MOCK RESPONSE
      // await Future.delayed(const Duration(seconds: 1));
      // final response = Response('{"specialUuid" : "20", "imageUrl : """}', 201);
      //print(json.decode(response.body).toString());

      // Log status code
      print('[CREATE SPECIAL] Response Code: ${response.statusCode}');

      if (response.statusCode == 201) {
        //print(response.body.toString());
        final jsonResponse = json.decode(response.body);
        special.uuid = jsonResponse["specialUuid"] as String;
        special.imageUrl = jsonResponse["imageUrl"] as String;
        return special;
      } else {
        _handleError(response: response);
      }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<Set<Special>> getAllSpecials(String jwt) async {
    final uri = Uri.parse("$serverUrl/getAllSpecials.php");
    print(uri.toString());
    // print("jwt req: " + jwt);

    try {
      // Send get request
      final response = await http.get(
        uri,
        headers: {"jwt": jwt},
      ).timeout(kTimeOutDuration);

      // MOCK RESPONSE
      // await Future.delayed(const Duration(seconds: 1));
      // final response = Response(jsonEncode(mockSpecialsList), 200,);
      //print(json.decode(response.body).toString());

      // Log status code
      print('[GET ALL SPECIALS] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        //print(response.body.toString());

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

  Future<Special> updateSpecial(String jwt, Special special) async {
    final uri = Uri.parse("$serverUrl/updateSpecial.php");
    print(uri.toString());
    //print("jwt req: " + jwt);

    try {
      final updatedSpecialMap = special.toJson();
      // print(json.encode(updatedSpecialMap));

      // Send post request
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json", "jwt": jwt},
            body: json.encode(updatedSpecialMap),
          )
          .timeout(kTimeOutDuration);

      // MOCK RESPONSE
      // await Future.delayed(const Duration(seconds: 2));
      // final response = Response('{"imageUrl : """}', 201);
      //print(json.decode(response.body).toString());

      // Log status code
      print('[UPDATE SPECIAL] Response Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        special.imageUrl = jsonResponse["imageUrl"] as String;
        return special;
      } else {
        _handleError(response: response);
      }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<Special> toggleSpecialActivate(String jwt, Special special) async {
    final uri = Uri.parse("$serverUrl/toggleSpecialActive.php");
    print(uri.toString());
    //print("jwt req: " + jwt);

    try {
      final activatedAt = special.activatedAt != null
          ? Util.convertDateTimeToUtcISO(special.activatedAt!)
          : "0000-00-00 00:00:00";

      // Status 1 == inactive // 9 == active
      final updatedSpecialMap = {
        "specialUuid": special.uuid,
        "status": special.status == SpecialStatus.inactive ? 1 : 9,
        "activatedAt": activatedAt,
        // "activatedAt":  "0000-00-00 00:00:00Z",
      };

      // Send post request
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json", "jwt": jwt},
            body: json.encode(updatedSpecialMap),
          )
          .timeout(kTimeOutDuration);

      // MOCK RESPONSE
      // await Future.delayed(const Duration(seconds: 2));
      // final response = Response('{"imageUrl : """}', 201);
      //print(json.decode(response.body).toString());

      // Log status code
      print(
        '[ACTIVATE/DEACTIVATE SPECIAL] Response Code: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return special;
      } else {
        _handleError(response: response);
      }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<ServerSuccess> deleteSpecial(String jwt, Special special) async {
    final uri = Uri.parse("$serverUrl/deleteSpecial.php");
    print(uri.toString());

    try {
      final deleteSpecialMap = {
        "specialUuid": special.uuid,
        "imageUrl": special.imageUrl,
      };

      // Send post request
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json", "jwt": jwt},
            body: json.encode(deleteSpecialMap),
          )
          .timeout(kTimeOutDuration);

      // MOCK RESPONSE
      // await Future.delayed(const Duration(seconds: 1));
      // final response = Response("", 204,);
      //print(json.decode(response.body).toString());

      // Log status code
      print('[DELETE SPECIAL] Response Code: ${response.statusCode}');

      if (response.statusCode == 204) {
        return ServerSuccess();
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

  Future<ServerSuccess> updateStoreLatLon(
    String jwt,
    Store store,
    LatLng latLon,
  ) async {
    final uri = Uri.parse("$serverUrl/updateLatLon.php");
    print(uri.toString());
    //print("jwt req: " + jwt);

    try {
      // Send get request5
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json", "jwt": jwt},
            body: jsonEncode(latLon.toJson()),
          )
          .timeout(kTimeOutDuration);

      // MOCK RESPONSE
      // await Future.delayed(const Duration(seconds: 2));
      // final response = Response(jsonEncode(mockSpecialsList), 200,);
      //print(json.decode(response.body).toString());

      // Log status code
      print('[UPDATE STORE LAT-LON] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        return ServerSuccess();
      } else {
        _handleError(response: response);
      }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<List<SearchedPlace>> searchPlaceByQuery(
    String jwt,
    String query,
  ) async {
    final uri = Uri.parse("$serverUrl/fetchPlaceList.php");
    print(uri.toString());
    //print("jwt req: " + jwt);

    try {
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json", "jwt": jwt},
            body: jsonEncode({"query": Uri.encodeQueryComponent(query)}),
          )
          .timeout(kTimeOutDuration);

      // Log status code
      print('[GMAP Query] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final js = jsonDecode(response.body);
        final jsPlaceList = js["predictions"] as List;
        return jsPlaceList
            .map(
              (place) => SearchedPlace.fromJson(place as Map<String, dynamic>),
            )
            .toList();
      } else {
        _handleError(response: response);
      }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }

  Future<SelectedPlace> fetchSelectedPlace(String jwt, String placeId) async {
    final uri = Uri.parse("$serverUrl/fetchPlaceDetails.php?place=$placeId");
    print(uri.toString());

    try {
      // Send get request
      final response = await http.get(uri).timeout(kTimeOutDuration);

      // Log status code
      print('[GMAP PLACE] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final js = jsonDecode(response.body);
        final jsPlace = js["result"] as Map<String, dynamic>;
        return SelectedPlace.fromJson(jsPlace);
      } else {
        _handleError(response: response);
      }

      throw RemoteDataSourceException(response.body);
    } catch (error) {
      throw RemoteDataSourceException(error.toString());
    }
  }
}
