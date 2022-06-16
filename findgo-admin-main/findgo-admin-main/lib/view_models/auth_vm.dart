import 'dart:developer';

import 'package:findgo_admin/core/constants.dart';
import 'package:findgo_admin/core/failure.dart';
import 'package:findgo_admin/data_models/user.dart';
import 'package:findgo_admin/repositories/auth_repo.dart';
import 'package:findgo_admin/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

enum AuthViewState { idle, busy, error, fetchingUser }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  // Constructor
  AuthViewModel({
    required this.authRepository,
  });

  late BuildContext context;
  User currentUser =
      User(uuid: "-1", updatedAt: DateTime.parse("2020-01-01T00:00:00.000Z"));

  bool _getUserComplete = false;
  bool get getUserComplete => _getUserComplete;

  AuthViewState _state = AuthViewState.fetchingUser;
  AuthViewState get state => _state;
  void setState(AuthViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  void _handleFailure(Failure failure) {
    log("Auth VM: $failure");
    if (failure.toString() == "XMLHttpRequest error." ||
        failure.toString().contains("TimeoutException")) {
      InfoSnackBar.show(
        context,
        "Remote Server Connection Error! : Please check internet connection.",
        color: SnackBarColor.error,
      );
    } else if (failure.toString() != kMessageAuthError) {
      InfoSnackBar.show(
        context,
        failure.toString(),
        color: SnackBarColor.error,
      );
    }
    //if (!failure.toString().contains("auth repo: getCurrentUser: NoSuchMethodError: invalid member on null: 'getString'"))
    // Failure.handleFailure(failure, logout, context);
    setState(AuthViewState.error);
  }

  Future<bool> getCurrentUser() async {
    bool foundUser = false;
    final failureOrUser = await authRepository.getCurrentUser();
    await failureOrUser.fold((failure) async {
      if (!failure.toString().contains("No token stored")) {
        _handleFailure(failure);
      }
      context.vRouter.to("/login", isReplacement: true);
      _state = AuthViewState.error;
      return;
      // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) => const LoginPage()));
    }, (user) async {
      currentUser = user;
      foundUser = true;
      //navigationService.homePage(context);
    });
    _getUserComplete = true;
    setState(AuthViewState.idle);
    return foundUser;
  }

  Future<void> loginUser(String email, String password) async {
    setState(AuthViewState.busy);

    final failureOrUser = await authRepository.login(email, password);
    await failureOrUser.fold((failure) async => _handleFailure(failure),
        (user) async {
      currentUser = user;
      // log('[USER] : $currentUser');
      // InfoSnackBar.show(context, "Login Success");
      // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) => const HomePage()));
      _state = AuthViewState.idle;
      context.vRouter.to("/", isReplacement: true);
    });
  }

  Future<bool> registerUser(User user) async {
    bool success = false;
    setState(AuthViewState.busy);

    final failureOrUser = await authRepository.register(user);
    failureOrUser.fold((failure) async => _handleFailure(failure), (newUser) {
      currentUser = newUser;
      success = true;
      _state = AuthViewState.idle;
      // context.vRouter.to("/", isReplacement: true);
    });
    return success;
  }

  Future<void> logout() async {
    log("LOGGING OUT");
    final failureOrString = await authRepository.logout(currentUser.email);
    failureOrString.fold(
      (failure) => log(failure.toString()),
      (success) => log("LOGGED OUT SUCCESS"),
    );
    currentUser =
        User(uuid: "-1", updatedAt: DateTime.parse("2020-01-01T00:00:00.000Z"));
    context.vRouter.to("/login", isReplacement: true);
    // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) => const LoginPage()));
  }

  // Update User Credentials
  Future<void> updateEmail(String newEmail, String password) async {
    setState(AuthViewState.busy);
    final updatedUser = User(
      uuid: currentUser.uuid,
      email: newEmail,
      password: password,
      updatedAt: DateTime.parse("2020-01-01T00:00:00.000Z"),
    );

    final failureOrUser = await authRepository.updateEmail(updatedUser);
    failureOrUser.fold((failure) async => _handleFailure(failure), (_) {
      currentUser =
          currentUser.copyWith(email: newEmail, updatedAt: DateTime.now());
      // TODO store user
      //authRepository.storeCurrentUser(currentUser);
      InfoSnackBar.show(context, kMessageEmailUpdateSuccess);

      setState(AuthViewState.idle);
    });
  }

  Future<void> updatePassword(String password, String newPassword) async {
    setState(AuthViewState.busy);

    final updatedUser = User(
      uuid: currentUser.uuid,
      password: password,
      updatedAt: currentUser.updatedAt,
    );

    final failureOrUser =
        await authRepository.updatePassword(updatedUser, newPassword);
    failureOrUser.fold((failure) async => _handleFailure(failure), (_) {
      InfoSnackBar.show(context, kMessagePasswordUpdateSuccess);
      setState(AuthViewState.idle);
    });
  }

  Future<void> updateUsername({
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    setState(AuthViewState.busy);

    final updatedUser = User(
      uuid: currentUser.uuid,
      firstName: firstName,
      lastName: lastName,
      password: password,
      updatedAt: currentUser.updatedAt,
    );

    final failureOrUser = await authRepository.updateUsername(updatedUser);
    failureOrUser.fold((failure) async => _handleFailure(failure), (_) {
      currentUser = currentUser.copyWith(
        firstName: firstName,
        lastName: lastName,
        updatedAt: DateTime.now(),
      );
      // TODO store user
      //authRepository.storeCurrentUser(currentUser);
      InfoSnackBar.show(context, kMessageUsernameUpdateSuccess);
      setState(AuthViewState.idle);
    });
  }

  Future<bool> passwordResetRequest(String email) async {
    setState(AuthViewState.busy);
    bool _hasCode = false;

    if (email.length < 2) {
      log("[ERROR] passwordResetRequest: email.length to short");
      InfoSnackBar.show(
        context,
        kMessagePasswordResetRequestEmailError,
        color: SnackBarColor.error,
      );
      setState(AuthViewState.error);
      return _hasCode;
    }

    final failureOrSuccess = await authRepository.passwordResetRequest(email);
    await failureOrSuccess.fold((failure) async {
      _handleFailure(failure);
    }, (success) async {
      InfoSnackBar.show(context, kMessagePasswordResetUpdateSuccess);
      currentUser = User(
        email: email,
        uuid: "-1",
        updatedAt: DateTime.parse("2020-01-01T00:00:00.000Z"),
      );
      setState(AuthViewState.idle);
      _hasCode = true;
    });
    setState(AuthViewState.error);
    return _hasCode;
  }

  Future<void> passwordReset(String password, String passwordResetCode) async {
    setState(AuthViewState.busy);

    if (passwordResetCode.length < 6) {
      log("PW RESET ERROR: NO CURRENT USER EMAIL");
      InfoSnackBar.show(
        context,
        "Unexpected error for password reset, please try send another email",
        color: SnackBarColor.error,
      );
      setState(AuthViewState.error);
      return;
    }

    final failureOrSuccess =
        await authRepository.passwordReset(password, passwordResetCode);
    failureOrSuccess.fold((failure) async => _handleFailure(failure),
        (success) {
      loginUser(currentUser.email, password);
      InfoSnackBar.show(context, "Password update success");
    });
  }

  Future<void> deleteUser(String password) async {
    setState(AuthViewState.busy);

    final deleteUser = User(
      uuid: currentUser.uuid,
      email: currentUser.email,
      password: password,
    );

    final failureOrUser = await authRepository.deleteAccount(deleteUser);
    await failureOrUser.fold((failure) async => _handleFailure(failure),
        (_) async {
      InfoSnackBar.show(context, "Account Deleted Successfully");
      logout();
    });
  }

  Future<void> broadcastMessage(String message) async {
    final failureOrSuccess = await authRepository.broadcastMessage(message);
    failureOrSuccess.fold(
      (failure) => _handleFailure(failure),
      (_) => InfoSnackBar.show(context, "Message Sent Successfully"),
    );
  }

  // Helper
  bool isNotEmail(String? string) {
    // Null or empty string is invalid
    if (string == null || string.isEmpty) {
      return false;
    }

    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(pattern);

    if (!regExp.hasMatch(string)) {
      return true;
    }
    return false;
  }

  bool checkLengthOfPassword(String password) {
    return password.length >= 6;
  }

  bool checkPasswordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }
}
