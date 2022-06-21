import 'dart:developer';

import 'package:findgo_admin/core/failure.dart';
import 'package:findgo_admin/data_models/lat_lon.dart';
import 'package:findgo_admin/data_models/location.dart';
import 'package:findgo_admin/data_models/store.dart';
import 'package:findgo_admin/data_models/store_category.dart';
import 'package:findgo_admin/data_models/store_stats.dart';
import 'package:findgo_admin/repositories/specials_repo.dart';
import 'package:findgo_admin/widgets/snackbar.dart';
import 'package:flutter/material.dart';

enum StoresViewState {
  idle,
  busy,
  error,
  uploading,
  deleting,
  uploadingImage,
  updatingStatus
}

// ignore: prefer_function_declarations_over_variables
final Comparator<Store> _nameComparator =
    (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase());
// ignore: prefer_function_declarations_over_variables
final Comparator<StoreCategory> _categoryNameComparator =
    (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase());
// ignore: prefer_function_declarations_over_variables
final Comparator<Location> _locationNameComparator =
    (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase());

class StoresViewModel extends ChangeNotifier {
  SpecialsRepository specialsRepository;

  StoresViewModel({required this.specialsRepository});

  List<Store> _storesList = [];
  List<Store> get storesList => _storesList;
  List<StoreCategory> _categoryList = [];
  List<StoreCategory> get categoryList => _categoryList;
  List<Location> _locationList = [];
  List<Location> get locationList => _locationList;
  set locationList(List<Location> value) {
    _locationList = value;
  }

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
    Failure.handleFailure(context: _context, failure: failure);
    // Failure.handleFailure(context: _context, failure: failure, logoutFunction: authViewModel.logout, );

    setState(StoresViewState.error);
  }

  Future<Store?> createStore(Store store) async {
    setState(StoresViewState.uploading);
    Store? createdStore;

    final failureOrStoreUuid = await specialsRepository.createStore(store);
    failureOrStoreUuid.fold((failure) => _handleFailure(failure), (newStore) {
      _storesList.add(newStore as Store);
      _storesList.sort(_nameComparator);
      createdStore = newStore;
      InfoSnackBar.show(_context, "New Store Created");
      setState(StoresViewState.idle);
    });

    return createdStore;
  }

  Future<void> getAllStores() async {
    setState(StoresViewState.busy);

    final failureOrStoresList = await specialsRepository.getAllStores();
    failureOrStoresList.fold((failure) => _handleFailure(failure), (storeList) {
      // ignore: prefer_function_declarations_over_variables
      final Comparator<Store> nameComparator =
          (a, b) => a.name.compareTo(b.name);
      _storesList = (storeList as Set<Store>).toList();
      _storesList.sort(nameComparator);
      setState(StoresViewState.idle);
    });

    // await Future.delayed(const Duration(seconds: 1),
    //   () => _storesList = mockStoreList.map((store) => Store.fromJson(store)).toSet()
    // );
    // setState(StoresViewState.idle);
  }

  Future<bool> updateStore(Store store) async {
    setState(StoresViewState.uploading);
    bool updateSuccess = false;

    final failureOrSuccess = await specialsRepository.updateStore(store);
    failureOrSuccess.fold((failure) => _handleFailure(failure), (updatedStore) {
      _storesList[(_storesList
              .indexWhere((tempStore) => tempStore.uuid == store.uuid))] =
          updatedStore as Store;
      // ignore: prefer_function_declarations_over_variables
      _storesList.sort(_nameComparator);
      updateSuccess = true;
      InfoSnackBar.show(_context, "Store Updated");
      setState(StoresViewState.idle);
    });

    return updateSuccess;
  }

  Future<void> deleteStore(Store store) async {
    setState(StoresViewState.deleting);

    final failureOrSuccess = await specialsRepository.deleteStore(store);
    failureOrSuccess.fold((failure) => _handleFailure(failure), (_) {
      _storesList.remove(store);
      InfoSnackBar.show(_context, "Store Deleted");
      setState(StoresViewState.idle);
    });
  }

  Future<bool> toggleStoreActivate(Store store) async {
    setState(StoresViewState.updatingStatus);
    bool updateSuccess = false;

    final failureOrSuccess =
        await specialsRepository.toggleStoreActivate(store);
    failureOrSuccess.fold((failure) => _handleFailure(failure), (_) {
      _storesList[(_storesList
          .indexWhere((tempStore) => tempStore.uuid == store.uuid))] = store;
      updateSuccess = true;
      InfoSnackBar.show(
        _context,
        "Store ${store.status == StoreStatus.active ? "Activated" : "De-activated"}",
      );
    });

    setState(StoresViewState.idle);
    return updateSuccess;
  }

  Future<void> getAllStoreCategories() async {
    setState(StoresViewState.busy);

    final failureOrCategoryList =
        await specialsRepository.getAllStoreCategories();
    failureOrCategoryList.fold((failure) => _handleFailure(failure),
        (categoryList) {
      _categoryList = (categoryList as Set<StoreCategory>).toList();
      _categoryList.sort(_categoryNameComparator);
      setState(StoresViewState.idle);
    });
  }

  Future<void> getAllStoreLocations() async {
    setState(StoresViewState.busy);

    final failureOrLocationList = await specialsRepository.getAllLocations();
    failureOrLocationList.fold((failure) => _handleFailure(failure),
        (locationList) {
      _locationList = (locationList as Set<Location>).toList();
      _locationList.sort(_locationNameComparator);
      setState(StoresViewState.idle);
    });
  }

  Future<StoreStats> getRemoteStoreStats(Store store) async {
    setState(StoresViewState.busy);
    StoreStats storeStats = StoreStats(
      storeUuid: store.uuid,
      followers: -1,
      impressions: -1,
      clicks: -1,
      phoneClicks: -1,
      savedClicks: -1,
      sharedClicks: -1,
      websiteClicks: -1,
    );

    final failureOrStoreStats = await specialsRepository.getStoreStats(store);
    failureOrStoreStats.fold(
      (failure) => _handleFailure(failure),
      (stats) => storeStats = stats as StoreStats,
    );

    setState(StoresViewState.idle);
    return storeStats;
  }

  Future<void> updateStoreLatLon(Store store, LatLng latLon) async {
    setState(StoresViewState.uploading);

    final failureOrStoreStats =
        await specialsRepository.updateStoreLatLon(store, latLon);
    failureOrStoreStats.fold((failure) => _handleFailure(failure), (_) {
      final updateStore = _storesList.firstWhere((st) => st.uuid == store.uuid);
      updateStore.latLng = latLon;
    });

    setState(StoresViewState.idle);
  }

  Future<List<SearchedPlace>> searchPlaceByQuery(String query) async {
    List<SearchedPlace> placeList = [];
    final failureOrPlaceList =
        await specialsRepository.searchPlaceByQuery(query);
    failureOrPlaceList.fold(
      (failure) => _handleFailure(failure),
      (places) => placeList = places as List<SearchedPlace>,
    );
    return placeList;
  }

  Future<SelectedPlace?> searchPlaceDetails(String pickedId) async {
    SelectedPlace? place;

    final failureOrPlace =
        await specialsRepository.fetchSelectedPlace(pickedId);
    failureOrPlace.fold(
      (failure) => _handleFailure(failure),
      (p) => place = p as SelectedPlace,
    );

    return place;
  }
}
