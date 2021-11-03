import 'package:dartz/dartz.dart';
import 'package:findgo_admin/data_models/lat_lon.dart';

import '../core/exception.dart';
import '../core/failure.dart';
import '../data_models/special.dart';
import '../data_models/store.dart';
import '../external_services/local_data_src.dart';
import '../external_services/network_info.dart';
import '../external_services/remote_specials_data_src.dart';
import '../repositories/auth_repo.dart';

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
        (jwt) => remoteSpecialsDataSource.createStore(jwt as String, store));
  }

  Future<Either<Failure, dynamic>> getAllStores() async {
    return remoteCall(
        (jwt) => remoteSpecialsDataSource.getAllStores(jwt as String));
  }

  Future<Either<Failure, dynamic>> updateStore(Store store) async {
    return remoteCall(
        (jwt) => remoteSpecialsDataSource.updateStore(jwt as String, store));
  }

  Future<Either<Failure, dynamic>> deleteStore(Store store) async {
    return remoteCall(
        (jwt) => remoteSpecialsDataSource.deleteStore(jwt as String, store));
  }

  Future<Either<Failure, dynamic>> toggleStoreActivate(Store store) async {
    return remoteCall((jwt) =>
        remoteSpecialsDataSource.toggleStoreActivate(jwt as String, store));
  }

  Future<Either<Failure, dynamic>> getAllStoreCategories() async {
    return remoteCall((_) => remoteSpecialsDataSource.getAllStoreCategories());
  }

  Future<Either<Failure, dynamic>> getStoreStats(Store store) async {
    return remoteCall(
        (jwt) => remoteSpecialsDataSource.getStoreStats(jwt as String, store));
  }

  // SPECIALS

  Future<Either<Failure, dynamic>> createSpecial(Special special) async {
    return remoteCall((jwt) =>
        remoteSpecialsDataSource.createSpecial(jwt as String, special));
  }

  Future<Either<Failure, dynamic>> getAllSpecials() async {
    return remoteCall(
        (jwt) => remoteSpecialsDataSource.getAllSpecials(jwt as String));
  }

  Future<Either<Failure, dynamic>> updateSpecial(Special special) async {
    return remoteCall((jwt) =>
        remoteSpecialsDataSource.updateSpecial(jwt as String, special));
  }

  Future<Either<Failure, dynamic>> toggleSpecialActivate(
      Special special) async {
    return remoteCall((jwt) =>
        remoteSpecialsDataSource.toggleSpecialActivate(jwt as String, special));
  }

  Future<Either<Failure, dynamic>> deleteSpecial(Special special) async {
    return remoteCall((jwt) =>
        remoteSpecialsDataSource.deleteSpecial(jwt as String, special));
  }

  Future<Either<Failure, dynamic>> updateStoreLatLon(
      Store store, LatLng latLon) async {
    return remoteCall((jwt) => remoteSpecialsDataSource.updateStoreLatLon(
        jwt as String, store, latLon));
  }

  Future<Either<Failure, dynamic>> searchPlaceByQuery(String query) async {
    return remoteCall(
        (jwt) => remoteSpecialsDataSource.searchPlaceByQuery(jwt, query));
  }

  Future<Either<Failure, dynamic>> fetchSelectedPlace(String placeId) async {
    return remoteCall(
        (jwt) => remoteSpecialsDataSource.fetchSelectedPlace(jwt, placeId));
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
