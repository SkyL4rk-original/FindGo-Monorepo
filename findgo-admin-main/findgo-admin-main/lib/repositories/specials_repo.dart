import 'package:dartz/dartz.dart';
import 'package:findgo_admin/core/exception.dart';
import 'package:findgo_admin/core/failure.dart';
import 'package:findgo_admin/data_models/lat_lon.dart';
import 'package:findgo_admin/data_models/location.dart';
import 'package:findgo_admin/data_models/special.dart';
import 'package:findgo_admin/data_models/store.dart';
import 'package:findgo_admin/external_services/local_data_src.dart';
import 'package:findgo_admin/external_services/network_info.dart';
import 'package:findgo_admin/external_services/remote_specials_data_src.dart';
import 'package:findgo_admin/repositories/auth_repo.dart';

class SpecialsRepository {
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final RemoteSpecialsDataSource remoteSpecialsDataSource;
  final AuthRepository authRepository;

  SpecialsRepository({
    required this.localDataSource,
    required this.networkInfo,
    required this.remoteSpecialsDataSource,
    required this.authRepository,
  });

  Future<String> _getJwt() async {
    return authRepository.getJwt();
  }

  Future<bool> get isConnected async => networkInfo.isConnected;

  // STORES

  Future<Either<Failure, dynamic>> createStore(Store store) async {
    return remoteCall(
      (jwt) => remoteSpecialsDataSource.createStore(jwt, store),
    );
  }

  Future<Either<Failure, dynamic>> createLocation(Location location) async {
    return remoteCall(
      (jwt) => remoteSpecialsDataSource.createLocation(jwt, location),
    );
  }

  Future<Either<Failure, dynamic>> getAllStores() async {
    return remoteCall(
      (jwt) => remoteSpecialsDataSource.getAllStores(jwt),
    );
  }

  Future<Either<Failure, dynamic>> getAllLocations() async {
    return remoteCall(
      (jwt) => remoteSpecialsDataSource.getAllLocations(jwt),
    );
  }

  Future<Either<Failure, dynamic>> updateStore(Store store) async {
    return remoteCall(
      (jwt) => remoteSpecialsDataSource.updateStore(jwt, store),
    );
  }

  Future<Either<Failure, dynamic>> updateLocation(Location location) async {
    return remoteCall(
      (jwt) => remoteSpecialsDataSource.updateLocation(jwt, location),
    );
  }

  Future<Either<Failure, dynamic>> deleteStore(Store store) async {
    return remoteCall(
      (jwt) => remoteSpecialsDataSource.deleteStore(jwt, store),
    );
  }

  Future<Either<Failure, dynamic>> deleteLocation(Location location) async {
    return remoteCall(
      (jwt) => remoteSpecialsDataSource.deleteLocation(jwt, location),
    );
  }

  Future<Either<Failure, dynamic>> toggleStoreActivate(Store store) async {
    return remoteCall(
      (jwt) => remoteSpecialsDataSource.toggleStoreActivate(jwt, store),
    );
  }

  Future<Either<Failure, dynamic>> getAllStoreCategories() async {
    return remoteCall((_) => remoteSpecialsDataSource.getAllStoreCategories());
  }

  Future<Either<Failure, dynamic>> getStoreStats(Store store) async {
    return remoteCall(
      (jwt) => remoteSpecialsDataSource.getStoreStats(jwt, store),
    );
  }

  // SPECIALS

  Future<Either<Failure, dynamic>> createSpecial(Special special) async {
    return remoteCall(
      (jwt) => remoteSpecialsDataSource.createSpecial(jwt, special),
    );
  }

  Future<Either<Failure, dynamic>> getAllSpecials() async {
    return remoteCall(
      (jwt) => remoteSpecialsDataSource.getAllSpecials(jwt),
    );
  }

  Future<Either<Failure, dynamic>> updateSpecial(Special special) async {
    return remoteCall(
      (jwt) => remoteSpecialsDataSource.updateSpecial(jwt, special),
    );
  }

  Future<Either<Failure, dynamic>> toggleSpecialActivate(
    Special special,
  ) async {
    return remoteCall(
      (jwt) => remoteSpecialsDataSource.toggleSpecialActivate(jwt, special),
    );
  }

  Future<Either<Failure, dynamic>> deleteSpecial(Special special) async {
    return remoteCall(
      (jwt) => remoteSpecialsDataSource.deleteSpecial(jwt, special),
    );
  }

  Future<Either<Failure, dynamic>> updateStoreLatLon(
    Store store,
    LatLng latLon,
  ) async {
    return remoteCall(
      (jwt) => remoteSpecialsDataSource.updateStoreLatLon(
        jwt,
        store,
        latLon,
      ),
    );
  }

  Future<Either<Failure, dynamic>> searchPlaceByQuery(String query) async {
    return remoteCall(
      (jwt) => remoteSpecialsDataSource.searchPlaceByQuery(jwt, query),
    );
  }

  Future<Either<Failure, dynamic>> fetchSelectedPlace(String placeId) async {
    return remoteCall(
      (jwt) => remoteSpecialsDataSource.fetchSelectedPlace(jwt, placeId),
    );
  }

  Future<Either<Failure, dynamic>> remoteCall(Function(String) function) async {
    try {
      // Check if online
      if (!await networkInfo.isConnected) return left(OfflineFailure());

      // Get jwt
      final jwt = await _getJwt();

      final returnValue = await function(jwt);
      return right(returnValue);
    } on Exception catch (e) {
      if (e is AuthorizationException) {
        return left(AuthFailure());
      }
      print('specials repo: ${StackTrace.current}\n: ${e.toString()}');
      return left(ExternalServiceFailure(e.toString()));
    }
  }

  Future<Either<Failure, Special>> getSpecialByUuid(String uuid) async {
    try {
      // Check if online
      if (!await isConnected) return left(OfflineFailure());

      final special = await remoteSpecialsDataSource.getSpecialByUuid(uuid);
      return right(special);
    } on Exception catch (e) {
      if (e is AuthorizationException) {
        return left(AuthFailure());
      }
      print('specials repo: getSpecialByUuid: ${e.toString()}');
      return left(ExternalServiceFailure("Error getSpecialByUuid"));
    }
  }
}
