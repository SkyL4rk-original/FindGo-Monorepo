import 'package:dartz/dartz.dart';
import 'package:findgo/core/exception.dart';
import 'package:findgo/core/failure.dart';
import 'package:findgo/data_models/lat_lon.dart';
import 'package:findgo/data_models/special.dart';
import 'package:findgo/data_models/store.dart';
import 'package:findgo/external_services/local_data_src.dart';
import 'package:findgo/external_services/network_info.dart';
import 'package:findgo/external_services/remote_specials_data_src.dart';
import 'package:findgo/repositories/auth_repo.dart';

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

  // Future<bool> get isConnected async => true;
  Future<bool> get isConnected async => networkInfo.isConnected;

  Future<Either<Failure, Set<Special>>> getAllSpecials() async {
    try {
      // Check if online
      if (!await isConnected) return left(OfflineFailure());

      final specialList = await remoteSpecialsDataSource.getAllSpecials();
      return right(specialList);
    } on Exception catch (e) {
      if (e is AuthorizationException) {
        return left(AuthFailure());
      }
      print('specials repo: getAllSpecials: ${e.toString()}');
      return left(ExternalServiceFailure("Error getAllSpecials"));
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

  Future<Either<Failure, Set<Store>>> getAllStores() async {
    try {
      // Check if online
      if (!await isConnected) return left(OfflineFailure());

      final storeList = await remoteSpecialsDataSource.getAllStores();
      return right(storeList);
    } on Exception catch (e) {
      if (e is AuthorizationException) {
        return left(AuthFailure());
      }
      print('specials repo: getAllStores: ${e.toString()}');
      return left(ExternalServiceFailure("Error getAllStores"));
    }
  }

  Future<Either<Failure, Set<String>>> getAllFollowedStores() async {
    try {
      // Check if online
      if (!await networkInfo.isConnected) {
        return right(await localDataSource.getFollowedStores());
      }

      // Set<String> followedStoreList = await localDataSource.getFollowedStores();
      // if (followedStoreList.isNotEmpty) return right(followedStoreList);
      final jwt = await authRepository.getJwt();
      return right(await remoteSpecialsDataSource.getAllFollowedStores(jwt));

      // followedStoreList = await remoteSpecialsDataSource.getAllFollowedStores();
      // await localDataSource.setFollowedStores(followedStoreList);
      // return right(followedStoreList);

    } on Exception catch (e) {
      if (e is AuthorizationException) {
        return left(AuthFailure());
      }
      print('specials repo: getAllFollowedStores: ${e.toString()}');
      return left(ExternalServiceFailure("Error getAllFollowedStores"));
    }
  }

  Future<Either<Failure, Unit>> followStore(String storeUuid) async {
    try {
      // Check if online
      if (!await isConnected) return left(OfflineFailure());

      final jwt = await authRepository.getJwt();
      await remoteSpecialsDataSource.followStore(jwt, storeUuid, status: true);
      // await localDataSource.addFollowedStore(storeUuid);
      return right(unit);
    } on Exception catch (e) {
      if (e is AuthorizationException) {
        return left(AuthFailure());
      }
      print('specials repo: followStore: ${e.toString()}');
      return left(ExternalServiceFailure("Error followStore"));
    }
  }

  Future<Either<Failure, Unit>> unfollowStore(String storeUuid) async {
    try {
      // Check if online
      if (!await isConnected) return left(OfflineFailure());

      final jwt = await authRepository.getJwt();
      await remoteSpecialsDataSource.followStore(jwt, storeUuid, status: false);
      // await localDataSource.removeFollowedStore(storeUuid);
      return right(unit);
    } on Exception catch (e) {
      if (e is AuthorizationException) {
        return left(AuthFailure());
      }
      print('specials repo: followStore: ${e.toString()}');
      return left(ExternalServiceFailure("Error followStore"));
    }
  }

  Future<Either<Failure, Set<String>>> getAllNotifyStores() async {
    try {
      // Check if online
      if (!await networkInfo.isConnected) {
        right(await localDataSource.getNotifyStores());
      }

      // Set<String> followedStoreList = await localDataSource.getFollowedStores();
      // if (followedStoreList.isNotEmpty) return right(followedStoreList);
      final jwt = await authRepository.getJwt();
      return right(await remoteSpecialsDataSource.getAllNotifyStores(jwt));

      // followedStoreList = await remoteSpecialsDataSource.getAllFollowedStores();
      // await localDataSource.setFollowedStores(followedStoreList);
      // return right(followedStoreList);

    } on Exception catch (e) {
      if (e is AuthorizationException) {
        return left(AuthFailure());
      }
      print('specials repo: getAllNotifyStores: ${e.toString()}');
      return left(ExternalServiceFailure("Error getAllNotifyStores"));
    }
  }

  Future<Either<Failure, Unit>> addNotifyStore(String storeUuid) async {
    try {
      // Check if online
      if (!await isConnected) return left(OfflineFailure());

      final jwt = await authRepository.getJwt();
      await remoteSpecialsDataSource.notificationFromStore(
        jwt,
        storeUuid,
        status: true,
      );
      // await localDataSource.addNotifyStore(storeUuid);
      return right(unit);
    } on Exception catch (e) {
      if (e is AuthorizationException) {
        return left(AuthFailure());
      }
      print('specials repo: addNotifyStore: ${e.toString()}');
      return left(ExternalServiceFailure("Error addNotifyStore"));
    }
  }

  Future<Either<Failure, Unit>> removeNotifyStore(String storeUuid) async {
    try {
      // Check if online
      if (!await isConnected) return left(OfflineFailure());

      final jwt = await authRepository.getJwt();
      await remoteSpecialsDataSource.followStore(jwt, storeUuid, status: false);
      // await localDataSource.removeNotifyStore(storeUuid);
      return right(unit);
    } on Exception catch (e) {
      if (e is AuthorizationException) {
        return left(AuthFailure());
      }
      print('specials repo: removeNotifyStore: ${e.toString()}');
      return left(ExternalServiceFailure("Error removeNotifyStore"));
    }
  }

  // Saved
  Future<Either<Failure, Set<String>>> getAllSavedSpecials() async {
    try {
      // Check if online
      // if (!await networkInfo.isConnected) return right(await localDataSource.getFollowedStores());

      // Set<String> followedStoreList = await localDataSource.getFollowedStores();
      // if (followedStoreList.isNotEmpty) return right(followedStoreList);
      // final jwt = await authRepository.getJwt();
      return right(await localDataSource.getSavedSpecials());

      // followedStoreList = await remoteSpecialsDataSource.getAllFollowedStores();
      // await localDataSource.setFollowedStores(followedStoreList);
      // return right(followedStoreList);

    } on Exception catch (e) {
      if (e is AuthorizationException) {
        return left(AuthFailure());
      }
      print('specials repo: getAllSavedSpecials: ${e.toString()}');
      return left(ExternalServiceFailure("Error getAllSavedSpecials"));
    }
  }

  Future<Either<Failure, Unit>> addSavedSpecial(String specialUuid) async {
    try {
      // Check if online
      //if (!await isConnected) return left(OfflineFailure());

      // final jwt = await authRepository.getJwt();
      // await remoteSpecialsDataSource.followStore(jwt, storeUuid, status: true);
      await localDataSource.addSavedSpecial(specialUuid);
      return right(unit);
    } on Exception catch (e) {
      if (e is AuthorizationException) {
        return left(AuthFailure());
      }
      print('specials repo: add save special: ${e.toString()}');
      return left(ExternalServiceFailure("Error Adding Saved Special"));
    }
  }

  Future<Either<Failure, Unit>> removeSavedSpecial(String specialUuid) async {
    try {
      // Check if online
      // if (!await isConnected) return left(OfflineFailure());

      // final jwt = await authRepository.getJwt();
      // await remoteSpecialsDataSource.followStore(jwt, storeUuid, status: false);
      await localDataSource.removeSavedSpecial(specialUuid);
      return right(unit);
    } on Exception catch (e) {
      if (e is AuthorizationException) {
        return left(AuthFailure());
      }
      print('specials repo: removeSavedSpecial: ${e.toString()}');
      return left(ExternalServiceFailure("Error Removing Saved Special"));
    }
  }

  // Stat Events
  Future<void> addSpecialStatIncrement(
    String specialUuid,
    SpecialStat specialStat,
  ) async {
    try {
      // Check if online
      if (!await isConnected) return;

      final jwt = await authRepository.getJwt();
      await remoteSpecialsDataSource.addSpecialStatIncrement(
        jwt,
        specialUuid,
        specialStat,
      );
      // await localDataSource.addNotifyStore(storeUuid);

    } on Exception catch (e) {
      print('specials repo: addSpecialShareClicked: ${e.toString()}');
    }
  }

  // INFO: LOCATION
  Future<Either<Failure, Unit>> storeCurrentLocation(LatLng latLng) async {
    try {
      await localDataSource.storeCurrentLocation(latLng);
      return right(unit);
    } on Exception catch (e) {
      if (e is AuthorizationException) {
        return left(AuthFailure());
      }
      print('specials repo: storeCurrentLocation: ${e.toString()}');
      return left(CacheFailure("Error saving current location"));
    }
  }

  Future<Either<Failure, LatLng>> fetchLastLocation() async {
    try {
      return right(await localDataSource.fetchLastLocation());
    } on Exception catch (e) {
      if (e is AuthorizationException) {
        return left(AuthFailure());
      }
      print('specials repo: fetchLastLocation: ${e.toString()}');
      return left(CacheFailure("Error fetching last location "));
    }
  }

  Future<Either<Failure, Unit>> storeLocationRange(
    double? locationRange,
  ) async {
    try {
      await localDataSource.storeLocationRange(locationRange);
      return right(unit);
    } on Exception catch (e) {
      if (e is AuthorizationException) {
        return left(AuthFailure());
      }
      print('specials repo: storeLocationRange: ${e.toString()}');
      return left(CacheFailure("Error saving current location filter range"));
    }
  }

  Future<Either<Failure, double?>> fetchLocationrange() async {
    try {
      return right(await localDataSource.fetchLocationRange());
    } on Exception catch (e) {
      if (e is AuthorizationException) {
        return left(AuthFailure());
      }
      print('specials repo: fetchLocationRange: ${e.toString()}');
      return left(CacheFailure("Error fetching location filter range"));
    }
  }
}
