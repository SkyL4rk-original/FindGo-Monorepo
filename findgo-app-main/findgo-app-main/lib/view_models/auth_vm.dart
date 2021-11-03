import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

import '../core/constants.dart';
import '../core/failure.dart';
import '../data_models/user.dart';
import '../repositories/auth_repo.dart';
import '../widgets/snackbar.dart';

enum AuthViewState { idle, busy, error, fetchingUser}

class AuthViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  // Constructor
  AuthViewModel({required this.authRepository,});

  late BuildContext context;
  User currentUser = User(uuid: "-1", updatedAt: DateTime.parse("2020-01-01T00:00:00.000Z"));

  bool _getUserComplete = false;
  bool get getUserComplete => _getUserComplete;

  bool isInitialLogin = true;

  String get htmlData => _htmlData;
  String _htmlData = "";

  AuthViewState _state = AuthViewState.fetchingUser;
  AuthViewState get state => _state;
  void setState(AuthViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  void _handleFailure(Failure failure) {
    log("Auth VM: $failure");
    if (failure is OfflineFailure || failure.toString() == "XMLHttpRequest error." || failure.toString().contains("TimeoutException") || failure.toString().contains("SocketException")) {
      InfoSnackBar.show(
        context,
        "Remote Server Connection Error! : Please check internet connection.",
        color: SnackBarColor.error
      );
    } else if (failure.toString() != kMessageAuthError) {
      InfoSnackBar.show(
          context,
          failure.toString(),
          color: SnackBarColor.error
      );
    }
    //if (!failure.toString().contains("auth repo: getCurrentUser: NoSuchMethodError: invalid member on null: 'getString'"))
      // Failure.handleFailure(failure, logout, context);
    _state = AuthViewState.error;
  }
  Future<void> getTerms() async {
    setState(AuthViewState.busy);
    final failureOrUser = await authRepository.getTerms();
    failureOrUser.fold(
            (failure) { return; },
            (html) { _htmlData = html; }
    );
    setState(AuthViewState.idle);
  }

  Future<bool> getCurrentUser() async {
    setState(AuthViewState.fetchingUser);

    bool foundUser = false;
    final token = await FirebaseMessaging.instance.getToken() ?? "";

    final failureOrUser = await authRepository.getCurrentUser(token);
    await failureOrUser.fold(
        (failure) async {
          if (!failure.toString().contains("No token stored")) { _handleFailure(failure); }
          context.vRouter.to("/login", isReplacement: true);
          _state = AuthViewState.error;
          return;
          // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) => const LoginPage()));
        },
        (user) async {
              // await _initFirebaseMessaging();
              currentUser = user;
              foundUser = true;
              //navigationService.homePage(context);
            }
    );
    isInitialLogin = true;
    _getUserComplete = true;
    setState(AuthViewState.idle);
    return foundUser;
  }

  Future<void>  loginUser(String email, String password) async {
    setState(AuthViewState.busy);

    // await Firebase.initializeApp();
    final token = await FirebaseMessaging.instance.getToken() ?? "";
    // print("Firebase token: $token");
    final user = User(uuid: "", email: email, password: password, firebaseToken: token);
    // final user = User(uuid: "", email: email, password: password, firebaseToken: "token");

    final failureOrUser = await authRepository.login(user);
    await failureOrUser.fold(
        (failure) async => _handleFailure(failure),
        (user) async {
          // _initFirebaseMessaging();
          currentUser = user;
          // log('[USER] : $currentUser');
          // InfoSnackBar.show(context, "Login Success");
          isInitialLogin = true;
          await FirebaseMessaging.instance.requestPermission();
          // print('User granted permission: ${settings.authorizationStatus}');
          context.vRouter.to("/all", isReplacement: true);
          // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) => const HomePage()));
        }
    );
    setState(AuthViewState.idle);
  }

  Future<void>  signUpUser(User user) async {
    setState(AuthViewState.busy);
    user.firebaseToken = await FirebaseMessaging.instance.getToken() ?? "";

    final failureOrUser = await authRepository.register(user);
    await failureOrUser.fold(
        (failure) async => _handleFailure(failure),
        (newUser) async {
          // _initFirebaseMessaging();
          isInitialLogin = true;
          currentUser = newUser;
          InfoSnackBar.show(context, "Sign Up Success");
          await FirebaseMessaging.instance.requestPermission();
          // print('User granted permission: ${settings.authorizationStatus}');
          context.vRouter.to("/all", isReplacement: true);
        }
    );
    setState(AuthViewState.idle);
  }

  Future<void> logout() async {
    isInitialLogin = true;
    final failureOrString = await authRepository.logout(currentUser.email);
    failureOrString.fold(
            (failure) => log(failure.toString()),
            (success) => log("LOGGED OUT SUCCESS"),
    );
    currentUser = User(uuid: "-1", updatedAt: DateTime.parse("2020-01-01T00:00:00.000Z"));
    context.vRouter.to("/login", isReplacement: true);
    // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) => const LoginPage()));
  }

  // Update User Credentials
  Future<void>  updateEmail(String newEmail, String password) async {
    setState(AuthViewState.busy);
    final updatedUser = User(
        uuid: currentUser.uuid,
        email: newEmail,
        password: password,
        updatedAt: DateTime.parse("2020-01-01T00:00:00.000Z")
    );

    final failureOrUser = await authRepository.updateEmail(updatedUser);
    failureOrUser.fold(
            (failure) async => _handleFailure(failure),

        (_) {
              currentUser = currentUser.copyWith(email: newEmail, updatedAt: DateTime.now());
              // TODO store user
              //authRepository.storeCurrentUser(currentUser);
              InfoSnackBar.show(context, kMessageEmailUpdateSuccess);

              setState(AuthViewState.idle);
            }
    );
  }

  Future<void>  updatePassword(String password, String newPassword) async {
    setState(AuthViewState.busy);

    final updatedUser = User(
        uuid: currentUser.uuid,
        password: password,
        updatedAt: currentUser.updatedAt
    );

    final failureOrUser = await authRepository.updatePassword(updatedUser, newPassword);
    failureOrUser.fold(
            (failure) async => _handleFailure(failure),
        (_) {
              InfoSnackBar.show(context, kMessagePasswordUpdateSuccess);
              setState(AuthViewState.idle);
            }
    );
  }

  Future<void>  updateUsername(
      {required String firstName, required String lastName, required String password}) async {
    setState(AuthViewState.busy);

    final updatedUser = User(
        uuid: currentUser.uuid,
        firstName: firstName,
        lastName: lastName,
        password: password,
        updatedAt: currentUser.updatedAt
    );

    final failureOrUser = await authRepository.updateUsername(updatedUser);
    failureOrUser.fold(
            (failure) async => _handleFailure(failure),
            (_) {
              currentUser = currentUser.copyWith(firstName: firstName, lastName: lastName, updatedAt: DateTime.now());
              // TODO store user
              //authRepository.storeCurrentUser(currentUser);
              InfoSnackBar.show(context, kMessageUsernameUpdateSuccess);
              setState(AuthViewState.idle);
            }
    );
  }

  Future<bool> passwordResetRequest(String email) async {
    setState(AuthViewState.busy);
    bool _hasCode = false;

    if (email.length < 2) {
      log("[ERROR] passwordResetRequest: email.length to short");
      InfoSnackBar.show(context, kMessagePasswordResetRequestEmailError, color: SnackBarColor.error);
      setState(AuthViewState.error);
      return _hasCode;
    }

    final failureOrSuccess = await authRepository.passwordResetRequest(email);
    await failureOrSuccess.fold(
        (failure) async {
          _handleFailure(failure);
        },
        (success) async {
          InfoSnackBar.show(context, kMessagePasswordResetUpdateSuccess);
          currentUser = User(email: email, uuid: "-1", updatedAt: DateTime.parse("2020-01-01T00:00:00.000Z"));
          setState(AuthViewState.idle);
          _hasCode = true;
        }
    );
    setState(AuthViewState.error);
    return _hasCode;
  }

  Future<void>  passwordReset(String password, String passwordResetCode) async {
    setState(AuthViewState.busy);

    if (passwordResetCode.length < 6) {
      log("PW RESET ERROR: NO CURRENT USER EMAIL");
      InfoSnackBar.show(context, "Unexpected error for password reset, please try send another email", color: SnackBarColor.error);
      setState(AuthViewState.error);
      return;
    }

    final failureOrSuccess = await authRepository.passwordReset(password, passwordResetCode);
    failureOrSuccess.fold(
        (failure) async => _handleFailure(failure),
        (success) {
              loginUser(currentUser.email, password);
              InfoSnackBar.show(context, "Password update success");
            }
    );
  }

  Future<void> deleteUser(String password) async {
    setState(AuthViewState.busy);

    final deleteUser = User(uuid: currentUser.uuid, email: currentUser.email, password: password);

    final failureOrUser = await authRepository.deleteAccount(deleteUser);
    await failureOrUser.fold(
        (failure) async => _handleFailure(failure),
        (_) async {
          InfoSnackBar.show(context, "Account Deleted Successfully");
          logout();
        }
    );
  }

  // Helper
  bool isEmail(String? string) {
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

  // Firebase Messaging
  // Future<void> _initFirebaseMessaging() async {
  //   await Firebase.initializeApp();
  //   // FirebaseMessaging.onMessage.listen((event) {
  //   //   print(event.notification!.title);
  //   // });
  //   FirebaseMessaging.onMessageOpenedApp.listen((event) {
  //     print(event.notification!.title);
  //   });
  //   FirebaseMessaging.onBackgroundMessage(
  //       _firebaseMessagingBackgroundHandler);
  // }
  // Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //   await Firebase.initializeApp();
  //   print('Handling a background message ${message.messageId}');
  // }

}