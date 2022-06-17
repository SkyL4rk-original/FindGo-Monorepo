import 'dart:developer';

import 'package:findgo_admin/core/constants.dart';
import 'package:findgo_admin/core/failure.dart';
import 'package:findgo_admin/data_models/managed_user.dart';
import 'package:findgo_admin/data_models/store.dart';
import 'package:findgo_admin/repositories/auth_repo.dart';
import 'package:findgo_admin/widgets/snackbar.dart';
import 'package:flutter/material.dart';

enum UsersViewState { idle, busy, error, fetchingUser, updatingUser }

class UsersViewModel extends ChangeNotifier {
  final AuthRepository authRepo;

  // Constructor
  UsersViewModel({
    required this.authRepo,
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

    final failureOrUserSet = await authRepo.getStoreUsers(store);
    await failureOrUserSet.fold((failure) async => _handleFailure(failure),
        (userSet) async {
      _storeUsersList = userSet.toList();
      await _sortUserList();
    });

    setState(UsersViewState.idle);
  }

  Future<ManagedUser?> getUserByEmail(String email) async {
    ManagedUser? user;
    setState(UsersViewState.fetchingUser);

    final failureOrUser = await authRepo.getUserByEmail(email);
    await failureOrUser.fold(
      (failure) async {},
      (u) async => user = u,
    );

    // user = ManagedUser.fromJson(jsonUser as Map<String, dynamic>);
    // await _sortUserList();
    // await Future.delayed(const Duration(seconds: 1));
    setState(UsersViewState.idle);
    return user;
  }

  Future<bool> addUserToStore(
    ManagedUser user,
    Store store,
  ) async {
    bool success = false;
    setState(UsersViewState.updatingUser);

    final failureOrSuccess = await authRepo.addUserToStore(user, store);
    await failureOrSuccess.fold(
      (failure) async => _handleFailure(failure),
      (_) async {
        _storeUsersList.add(user);
        await _sortUserList();
        success = true;
      },
    );

    setState(UsersViewState.idle);
    return success;
  }

  Future<bool> removeUserFromStore(
    ManagedUser user,
    Store store,
  ) async {
    bool success = false;
    setState(UsersViewState.updatingUser);

    final failureOrSuccess = await authRepo.removeUserFromStore(user, store);
    await failureOrSuccess.fold(
      (failure) async => _handleFailure(failure),
      (_) async {
        _storeUsersList.remove(user);
        success = true;
      },
    );

    setState(UsersViewState.idle);
    return success;
  }

  Future<void> _sortUserList() async {
    _storeUsersList.sort((a, b) {
      final int cmp = a.role.index.compareTo(b.role.index);
      if (cmp != 0) return cmp;
      return a.email.compareTo(b.email);
    });
  }
}
