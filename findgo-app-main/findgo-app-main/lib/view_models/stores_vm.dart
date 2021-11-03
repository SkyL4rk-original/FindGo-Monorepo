import 'dart:developer';

import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/failure.dart';
import '../data_models/store.dart';
import '../repositories/specials_repo.dart';
import '../widgets/snackbar.dart';
import 'network_vm.dart';

enum StoresViewState { idle, busy, error, uploading }

// ignore: prefer_function_declarations_over_variables
final Comparator<Store> _nameComparator = (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase());

class StoresViewModel extends ChangeNotifier {
  final NetworkViewModel networkViewModel;
  final SpecialsRepository specialsRepository;
  final String findgoUuid;

  StoresViewModel({required this.networkViewModel, required this.specialsRepository, required this.findgoUuid});

  Set<String> _followedStoresUuidList = {};
  Set<String> get followedStoresUuidList => _followedStoresUuidList;
  Set<String> _notifyStoresUuidList = {};
  Set<String> get notifyStoresUuidList => _notifyStoresUuidList;
  Set<Store> _storesList = {};
  Set<Store> get storesList => _storesList;

  // Build Context
  late BuildContext _context;
  // ignore: avoid_setters_without_getters
  set context(BuildContext ctx) => _context = ctx;

  // State Management
  StoresViewState _state = StoresViewState.busy;
  StoresViewState get state => _state;
  void setState(StoresViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  // Error Handling
  void _handleFailure(Failure failure) {
    log("Stores VM: $failure");
    if (failure is OfflineFailure && networkViewModel.state == NetworkViewState.online) {
      InfoSnackBar.show(_context, kMessageOfflineError, color: SnackBarColor.error);
      networkViewModel.setState(NetworkViewState.offline);
      networkViewModel.streamNetworkStatus();
    } else if (networkViewModel.state != NetworkViewState.offline) {
      Failure.handleFailure(context: _context, failure: failure);
    }

    setState(StoresViewState.error);
  }

  void clearStoreList() { _storesList = {}; }

  bool _fetchingStores = false;
  Future<void> getAllStores() async {
    if (_fetchingStores) return;
    setState(StoresViewState.busy);
    _fetchingStores = true;

    // await Future.delayed(const Duration(seconds: 1), () {} );

    final failureOrStoresList = await specialsRepository.getAllStores();
    failureOrStoresList.fold(
            (failure) => _handleFailure(failure),
            (storeList) {
          storeList.toList().sort(_nameComparator);
          _storesList = storeList;
            }
    );

    // await Future.delayed(const Duration(seconds: 1),
    //   () => _storesList = mockStoreList.map((store) => Store.fromJson(store)).toSet()
    // );
    _fetchingStores = false;
    setState(StoresViewState.idle);
  }

  Future<void> getAllFollowedStores() async {
    setState(StoresViewState.busy);

    final failureOrFollowedStoreList = await specialsRepository.getAllFollowedStores();
    failureOrFollowedStoreList.fold(
            (failure) => _handleFailure(failure),
            (followedStoreList) {
              _followedStoresUuidList = followedStoreList;
        }
    );

    // await Future.delayed(const Duration(seconds: 1),
    //         () => followedStoresUuidList = mockFollowedStoreUuidList.toSet()
    // );
    setState(StoresViewState.idle);
  }

  Future<void> followStore({required String storeUuid, required bool follow}) async {
    if (follow) {

      final failureOrStoresList = await specialsRepository.followStore(storeUuid);
      failureOrStoresList.fold(
              (failure) => _handleFailure(failure),
              (_) => _followedStoresUuidList.add(storeUuid)
      );
    } else {
      final failureOrStoresList = await specialsRepository.unfollowStore(storeUuid);
      failureOrStoresList.fold(
              (failure) => _handleFailure(failure),
              (_) => _followedStoresUuidList.remove(storeUuid)
      );
    }

    await Future.delayed(const Duration(milliseconds: 300), () => null);
  }

  Future<void> getAllNotifyStores() async {
    setState(StoresViewState.busy);

    final failureOrNotifyStoreList = await specialsRepository.getAllFollowedStores();
    failureOrNotifyStoreList.fold(
            (failure) => _handleFailure(failure),
            (notifyStoreList) {
          _notifyStoresUuidList = notifyStoreList;
        }
    );

    // await Future.delayed(const Duration(seconds: 1),
    //         () => followedStoresUuidList = mockFollowedStoreUuidList.toSet()
    // );
    setState(StoresViewState.idle);
  }

  Future<void> notifyStore({required String storeUuid, required bool notify}) async {
    if (notify) {
      final failureOrNotifyStoreList = await specialsRepository.addNotifyStore(storeUuid);
      failureOrNotifyStoreList.fold(
              (failure) => _handleFailure(failure),
              (_) => notifyStoresUuidList.add(storeUuid)
      );
    } else {
      final failureOrNotifyStoreList = await specialsRepository.removeNotifyStore(storeUuid);
      failureOrNotifyStoreList.fold(
              (failure) => _handleFailure(failure),
              (_) => _notifyStoresUuidList.remove(storeUuid)
      );
    }

    await Future.delayed(const Duration(milliseconds: 300), () => null);
  }

}