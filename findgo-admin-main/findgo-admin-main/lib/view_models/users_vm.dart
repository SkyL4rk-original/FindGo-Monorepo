import 'dart:convert';
import 'dart:developer';

import 'package:findgo_admin/core/constants.dart';
import 'package:findgo_admin/core/failure.dart';
import 'package:findgo_admin/data_models/managed_user.dart';
import 'package:findgo_admin/data_models/store.dart';
import 'package:findgo_admin/repositories/specials_repo.dart';
import 'package:findgo_admin/widgets/snackbar.dart';
import 'package:flutter/material.dart';

enum UsersViewState { idle, busy, error, fetchingUser, updatingUser }

class UsersViewModel extends ChangeNotifier {
  final SpecialsRepository specialsRepository;

  // Constructor
  UsersViewModel({
    required this.specialsRepository,
  });

  late BuildContext context;

  List<ManagedUser> _storeUsersList = [];
  List<ManagedUser> get storeUsersList => _storeUsersList;

  UsersViewState _state = UsersViewState.busy;
  UsersViewState get state => _state;
  void setState(UsersViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  void _handleFailure(Failure failure) {
    log("Users VM: $failure");
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
    setState(UsersViewState.error);
  }

  Future<void> getAllStoreUsers(Store store) async {
    setState(UsersViewState.busy);

    // final failureOrUser = await authRepository.getCurrentUser();
    // await failureOrUser.fold(
    //     (failure) async {
    //       if (!failure.toString().contains("No token stored")) _handleFailure(failure);
    //       context.vRouter.to("/login", isReplacement: true);
    //       _state = AuthViewState.error;
    //       return;
    //       // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) => const LoginPage()));
    //     },
    //     (user) async {
    //           currentUser = user;
    //           foundUser = true;
    //           //navigationService.homePage(context);
    //         }
    // );

    final jsonUserList = jsonDecode(
      """
[
      {
        "userUuid" : "user1",
        "email" : "d@e.com",
        "firstName" : "david",
        "lastName" : "gericke",
        "role": "1"
      },
      {
        "userUuid" : "user2",
        "email" : "b@e.com",
        "firstName" : "Bob",
        "lastName" : "Bobson",
        "role": "2"
      },
      {
        "userUuid" : "user3",
        "email" : "c@e.com",
        "firstName" : "Cathy",
        "lastName" : "Cathkey",
        "role": "3"
      }
    ]""",
    ) as List;

    _storeUsersList = jsonUserList
        .map((user) => ManagedUser.fromJson(user as Map<String, dynamic>))
        .toList();
    await _sortUserList();

    await Future.delayed(const Duration(seconds: 1));
    setState(UsersViewState.idle);
  }

  Future<ManagedUser?> getUserByEmail(String email) async {
    ManagedUser? user;
    setState(UsersViewState.fetchingUser);

    // final failureOrUser = await authRepository.getCurrentUser();
    // await failureOrUser.fold(
    //     (failure) async {
    //       if (!failure.toString().contains("No token stored")) _handleFailure(failure);
    //       context.vRouter.to("/login", isReplacement: true);
    //       _state = AuthViewState.error;
    //       return;
    //       // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) => const LoginPage()));
    //     },
    //     (user) async {
    //           currentUser = user;
    //           foundUser = true;
    //           //navigationService.homePage(context);
    //         }
    // );

    final jsonUser = jsonDecode(
      """
{
        "userUuid" : "user4",
        "email" : "g@e.com",
        "firstName" : "Garth",
        "lastName" : "Garland"
      }""",
    );

    user = ManagedUser.fromJson(jsonUser as Map<String, dynamic>);
    _storeUsersList.add(user);
    await _sortUserList();
    await Future.delayed(const Duration(seconds: 1));
    setState(UsersViewState.idle);
    return user;
  }

  Future<ManagedUser?> updateUser(ManagedUser user) async {
    setState(UsersViewState.updatingUser);

    // final failureOrUser = await authRepository.getCurrentUser();
    // await failureOrUser.fold(
    //     (failure) async {
    //       if (!failure.toString().contains("No token stored")) _handleFailure(failure);
    //       context.vRouter.to("/login", isReplacement: true);
    //       _state = AuthViewState.error;
    //       return;
    //       // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) => const LoginPage()));
    //     },
    //     (user) async {
    //           currentUser = user;
    //           foundUser = true;
    //           //navigationService.homePage(context);
    //         }
    // );

    _storeUsersList.remove(user);
    _storeUsersList.add(user);
    await _sortUserList();
    await Future.delayed(const Duration(seconds: 1));
    // ignore: use_build_context_synchronously
    InfoSnackBar.show(
      context,
      "Updated user role",
    );
    setState(UsersViewState.idle);
    return user;
  }

  Future<void> _sortUserList() async {
    _storeUsersList.sort((a, b) {
      final int cmp = a.role.index.compareTo(b.role.index);
      if (cmp != 0) return cmp;
      return a.email.compareTo(b.email);
    });
  }
}

