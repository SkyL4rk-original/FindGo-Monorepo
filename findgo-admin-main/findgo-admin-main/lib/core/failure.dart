import 'dart:developer';

import 'package:flutter/material.dart';

import '../widgets/snackbar.dart';
import 'constants.dart';

// ignore: avoid_classes_with_only_static_members
class Failure {
  static void handleFailure({required BuildContext context, required Failure failure, Function? logoutFunction}) {
    Failure finalFailure = failure;
    if (finalFailure.toString().contains(kXMLHttpRequestError) || finalFailure.toString().contains(kTimeOutError)) finalFailure = OfflineFailure();
    if (finalFailure is AuthFailure) {
      logoutFunction != null ? logoutFunction() : log("ERROR >>>>> AuthFailure and no logout function: ${context.owner}");
    } else if (finalFailure is OfflineFailure) { InfoSnackBar.show(context, kConnectionErrorMessage, color: SnackBarColor.error); }
    else {  InfoSnackBar.show(context, finalFailure.toString(), color: SnackBarColor.error); }
  }
}

class AuthFailure extends Failure {
  final String message =
      kMessageAuthError;

  @override
  String toString() => message;

}

class OfflineFailure extends Failure {
  final String message = kMessageOfflineError;

  @override
  String toString() => message;

}

class ServerFailure extends Failure {
  final String message;

  ServerFailure(this.message);

  @override
  String toString() => message;

}

class CacheFailure extends Failure {
  final String message;

  CacheFailure(this.message);

  @override
  String toString() => message;

}

class ExternalServiceFailure extends Failure {
  final String message;

  ExternalServiceFailure(this.message);

  @override
  String toString() => message;
}