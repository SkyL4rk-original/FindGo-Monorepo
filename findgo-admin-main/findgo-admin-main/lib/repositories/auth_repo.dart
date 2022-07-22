import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:findgo_admin/core/exception.dart';
import 'package:findgo_admin/core/failure.dart';
import 'package:findgo_admin/core/success.dart';
import 'package:findgo_admin/data_models/managed_user.dart';
import 'package:findgo_admin/data_models/store.dart';
import 'package:findgo_admin/data_models/user.dart';
import 'package:findgo_admin/external_services/local_data_src.dart';
import 'package:findgo_admin/external_services/network_info.dart';
import 'package:findgo_admin/external_services/remote_auth_src.dart';
import 'package:jwt_decode/jwt_decode.dart';

const logoutSuccessMessage = '[FINISHED LOGOUT USER] success';

class AuthRepository {
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final RemoteAuthSource remoteAuthSource;

  AuthRepository({
    required this.localDataSource,
    required this.networkInfo,
    required this.remoteAuthSource,
  });

  bool _updatingToken = false;

  Future<String> getJwt() async {
    int retryCounter = 20;
    while (_updatingToken && retryCounter >= 0) {
      await Future.delayed(const Duration(milliseconds: 300), () {});
      retryCounter--;
    }

    // Get jwt
    final jwt = await localDataSource.jwt;

    // Check if expired
    if (!Jwt.isExpired(jwt)) {
      return jwt;
    }

    _updatingToken = true;
    final refreshToken = await localDataSource.refreshToken;

    // Check if refreshToken expired
    String newJwt;
    if (Jwt.isExpired(refreshToken)) {
      // Update refreshToken
      final tokenMap = await remoteAuthSource.updateRefreshToken(refreshToken);
      // print("jwt: ${tokenMap["jwt"]}");
      // print("refreshToken: ${tokenMap["refreshToken"]}");
      newJwt = tokenMap["jwt"] ?? "";
      localDataSource.storeRefreshToken(tokenMap["refreshToken"] ?? "");
    } else {
      // Update jwt
      newJwt = await remoteAuthSource.getJwtFromRefreshToken(refreshToken);
    }

    await localDataSource.storeJwt(newJwt);
    _updatingToken = false;
    return newJwt;
  }

  // AUTH FUNCTIONS WITHOUT CALL TO REMOTE SERVER
  Future<bool> get isConnected async => networkInfo.isConnected;

  // TODO FIX STORE CURRENT USER TO ONLY IN REPO
  Future<bool> storeCurrentUser(User user) async {
    try {
      await localDataSource.storeCurrentUser(user);

      return true;
    } on CacheException catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<Either<Failure, Success>> logout(String email) async {
    try {
      // final refreshToken = await localDataSource.refreshToken;
      // Store nullJwt & nullUser
      await localDataSource.storeJwt('null');
      await localDataSource.storeRefreshToken('null');

      // await remoteAuthSource.logout(email, refreshToken);

      return right(CacheSuccess());
    } on CacheException catch (e) {
      log("auth repo: logout: ${e.message}");
      return left(CacheFailure(e.message));
    }
  }

  // AUTH FUNCTIONS TO REMOTE SERVER WITHOUT JWT -> LOGIN & REGISTER
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      // Check if online
      if (!await networkInfo.isConnected) {
        return left(OfflineFailure());
      }
      // Run function
      final success = await remoteAuthSource.login(email, password);
      // Success -> object == <User>
      if (success.object == null) {
        return left(ExternalServiceFailure("No user returned with login"));
      }

      // Store jwt & user
      await localDataSource.storeJwt(success.jwt);
      await localDataSource.storeRefreshToken(success.refreshToken);
      // await localDataSource.storeCurrentUser(success.object!);

      return right(success.object!);
    } on Exception catch (e) {
      log('auth repo: login: ${e.toString()}');
      return left(ExternalServiceFailure(e.toString()));
    }
  }

  Future<Either<Failure, User>> register(User user) async {
    try {
      // Check if online
      if (!await networkInfo.isConnected) {
        return left(OfflineFailure());
      }

      final usr = await remoteAuthSource.register(user);

      // Store jwt & user
      // await localDataSource.storeJwt(success.jwt);
      // await localDataSource.storeRefreshToken(success.refreshToken);
      // await localDataSource.storeCurrentUser(success.object!);

      return right(usr);
    } on Exception catch (e) {
      log('auth repo: register: ${e.toString()}');
      return left(ExternalServiceFailure(e.toString()));
    }
  }

  Future<Either<Failure, User>> verifyUser(String code) async {
    try {
      // Check if online
      if (!await networkInfo.isConnected) {
        return left(OfflineFailure());
      }
      // Run function
      final success = await remoteAuthSource.verifyUser(code);
      // Success -> object == <User>
      if (success.object == null) {
        return left(ExternalServiceFailure("No user returned with verify"));
      }

      // Store jwt & user
      await localDataSource.storeJwt(success.jwt);
      await localDataSource.storeRefreshToken(success.refreshToken);
      // await localDataSource.storeCurrentUser(success.object!);

      return right(success.object!);
    } on Exception catch (e) {
      log('auth repo: verifyUser: ${e.toString()}');
      return left(ExternalServiceFailure(e.toString()));
    }
  }

  // AUTH FUNCTIONS TO REMOTE SERVER WITH JWT
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Check if online
      if (!await networkInfo.isConnected) {
        return left(OfflineFailure());
      }

      // Get jwt
      final jwt = await getJwt();
      final user = await remoteAuthSource.getCurrentUser(jwt);

      return right(user);
    } on Exception catch (e) {
      if (e is AuthorizationException || e.toString() == 'No token stored') {
        return left(AuthFailure());
      }
      print('auth repo: getCurrentUser: ${e.toString()}');
      return left(ExternalServiceFailure(e.toString()));
    }
  }

  Future<Either<Failure, User>> updateEmail(User user) async {
    try {
      // Check if online
      if (!await networkInfo.isConnected) {
        return left(OfflineFailure());
      }
      // Get jwt
      final jwt = await getJwt();
      print(jwt);

      final updatedUser = await remoteAuthSource.updateEmail(jwt, user);
      return right(updatedUser);
    } on Exception catch (e) {
      log('auth repo: updateEmail: ${e.toString()}');
      return left(ExternalServiceFailure(e.toString()));
    }
  }

  Future<Either<Failure, User>> updatePassword(
    User user,
    String newPassword,
  ) async {
    try {
      // Check if online
      if (!await networkInfo.isConnected) {
        return left(OfflineFailure());
      }
      // Get jwt
      final jwt = await getJwt();

      final updatedUser =
          await remoteAuthSource.updatePassword(jwt, user, newPassword);
      return right(updatedUser);
    } on Exception catch (e) {
      log('auth repo: updatePassword: ${e.toString()}');
      return left(ExternalServiceFailure(e.toString()));
    }
  }

  Future<Either<Failure, User>> updateUsername(User user) async {
    try {
      // Check if online
      if (!await networkInfo.isConnected) {
        return left(OfflineFailure());
      }
      // Get jwt
      final jwt = await getJwt();

      final updatedUser = await remoteAuthSource.updateUsername(jwt, user);
      return right(updatedUser);
    } on Exception catch (e) {
      log('auth repo: updateUsername: ${e.toString()}');
      return left(ExternalServiceFailure(e.toString()));
    }
  }

  Future<Either<Failure, Success>> passwordResetRequest(String email) async {
    try {
      // Check if online
      if (!await networkInfo.isConnected) {
        return left(OfflineFailure());
      }

      await remoteAuthSource.passwordResetRequest(email);
      return right(ServerSuccess());
    } on RemoteDataSourceException catch (e) {
      log('auth repo: passwordResetRequest: remote error ${e.message}');
      return left(ServerFailure(e.message));
    }
  }

  Future<Either<Failure, Success>> passwordReset(
    String password,
    String passwordResetCode,
  ) async {
    try {
      // Check if online
      if (!await networkInfo.isConnected) {
        return left(OfflineFailure());
      }

      await remoteAuthSource.passwordReset(password, passwordResetCode);
      return right(ServerSuccess());
    } on RemoteDataSourceException catch (e) {
      log('Auth repo: passwordReset: remote error ${e.message}');
      return left(ServerFailure(e.message));
    }
  }

  Future<Either<Failure, Success>> deleteAccount(User user) async {
    try {
      // Check if online
      if (!await networkInfo.isConnected) {
        return left(OfflineFailure());
      }
      // Get jwt
      final jwt = await getJwt();

      final success = await remoteAuthSource.deleteAccount(jwt, user);
      return right(success);
    } on Exception catch (e) {
      log('auth repo: deleteAccount: ${e.toString()}');
      return left(ExternalServiceFailure(e.toString()));
    }
  }

  Future<Either<Failure, Success>> broadcastMessage(String message) async {
    try {
      // Check if online
      if (!await networkInfo.isConnected) {
        return left(OfflineFailure());
      }

      // Get jwt
      final jwt = await getJwt();

      await remoteAuthSource.broadcastMessage(jwt, message);
      return right(ServerSuccess());
    } on RemoteDataSourceException catch (e) {
      log('auth repo: broadcastMessage: remote error ${e.message}');
      return left(ServerFailure(e.message));
    }
  }

  Future<Either<Failure, Set<ManagedUser>>> getStoreUsers(Store store) async {
    try {
      // Check if online
      if (!await networkInfo.isConnected) {
        return left(OfflineFailure());
      }

      // Get jwt
      final jwt = await getJwt();

      final userSet = await remoteAuthSource.getStoreUsers(jwt, store);
      return right(userSet);
    } on RemoteDataSourceException catch (e) {
      log('auth repo: getStoreUsers: remote error ${e.message}');
      return left(ServerFailure(e.message));
    }
  }

  Future<Either<Failure, ManagedUser?>> getUserByEmail(String email) async {
    try {
      // Check if online
      if (!await networkInfo.isConnected) {
        return left(OfflineFailure());
      }

      // Get jwt
      final jwt = await getJwt();

      final user = await remoteAuthSource.getUserByEmail(jwt, email);
      return right(user);
    } on RemoteDataSourceException catch (e) {
      log('auth repo: broadcastMessage: remote error ${e.message}');
      return left(ServerFailure(e.message));
    }
  }

  Future<Either<Failure, Success>> addUserToStore(
    ManagedUser user,
    Store store,
  ) async {
    try {
      // Check if online
      if (!await networkInfo.isConnected) {
        return left(OfflineFailure());
      }

      // Get jwt
      final jwt = await getJwt();

      final success = await remoteAuthSource.addUserToStore(jwt, user, store);
      return right(success);
    } on RemoteDataSourceException catch (e) {
      log('auth repo: addUserToStore: remote error ${e.message}');
      return left(ServerFailure(e.message));
    }
  }

  Future<Either<Failure, Success>> removeUserFromStore(
    ManagedUser user,
    Store store,
  ) async {
    try {
      // Check if online
      if (!await networkInfo.isConnected) {
        return left(OfflineFailure());
      }

      // Get jwt
      final jwt = await getJwt();

      final success =
          await remoteAuthSource.removeUserFromStore(jwt, user, store);
      return right(success);
    } on RemoteDataSourceException catch (e) {
      log('auth repo: removeUserFromStore: remote error ${e.message}');
      return left(ServerFailure(e.message));
    }
  }
}
