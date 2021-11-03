import 'package:findgo/view_models/location_vm.dart';
import 'package:flutter/material.dart';

import '../data_models/special.dart';
import '../view_models/specials_vm.dart';
import '../view_models/stores_vm.dart';

enum FilterViewState { busy, idle }

class FilterViewModel extends ChangeNotifier {
  final StoresViewModel storesViewModel;
  final SpecialsViewModel specialsViewModel;
  final LocationViewModel locationViewModel;

  List<Special> filteredSpecialList = [];

  double? _locationRange;

  FilterViewState _state = FilterViewState.idle;
  bool get isBusy => _state == FilterViewState.busy;
  bool get hasLocation => _locationRange != null;

  FilterViewModel({
    required this.storesViewModel,
    required this.specialsViewModel,
    required this.locationViewModel,
  });

  bool _checkFollowing(Special special, bool filterFollowing) {
    if (!filterFollowing) return true;
    return storesViewModel.followedStoresUuidList
        .any((uuid) => uuid == special.storeUuid);
  }

  bool _checkSaved(Special special, bool filterSaved) {
    if (!filterSaved) return true;
    return specialsViewModel.savedSpecialsUuidSet
        .any((uuid) => uuid == special.uuid);
  }

  void _setFilteringState(FilterViewState state) {
    _state = state;
    notifyListeners();
  }

  void setLocationRange(double? locationRange) {
    _locationRange = locationRange;
    specialsViewModel.specialsRepository.storeLocationRange(locationRange);
  }

  Future<double?> get locationRange async {
    if (_locationRange != null) return _locationRange;

    final failOrLRange =
        await specialsViewModel.specialsRepository.fetchLocationrange();
    failOrLRange.fold(
      (failure) => _locationRange = null,
      (range) => _locationRange = range,
    );
    return _locationRange;
  }

//   Future<void> _setSpecialListState() async {
//     specialsViewModel.setState(SpecialViewState.busy);
//     await Future.delayed(const Duration(milliseconds: 300));
//     specialsViewModel.setState(SpecialViewState.idle);
//   }

  Future<List<Special>> filterSpecialList({
    bool filterFollowing = false,
    bool filterSaved = false,
    bool filterLocation = false,
    required String filterString,
    required SpecialType? selectedSpecialType,
    required DateTimeRange? dateRange,
  }) async {
    _setFilteringState(FilterViewState.busy);
    // print("Filter called");

    // Filter Followed / Saved / Type
    filteredSpecialList = specialsViewModel.specialsList
        .where(
          (special) =>
              _checkFollowing(special, filterFollowing) &&
              _checkSaved(special, filterSaved) &&
              (selectedSpecialType == null ||
                  special.typeSet.contains(selectedSpecialType)),
        )
        .toList();

    if (filterLocation && _locationRange != null) {
      // Filter by distance
      final storesInDistance = storesViewModel.storesList.where(
        (store) =>
           store.uuid == storesViewModel.findgoUuid || (store.latLng.isNotNil &&
            locationViewModel.getDistanceBetweenInKm(store.latLng) <
                _locationRange!),
      );
      filteredSpecialList = filteredSpecialList
          .where(
            (special) => storesInDistance
                .any((store) => store.uuid == special.storeUuid),
          )
          .toList();
    }

    // Filter by filter string
    filteredSpecialList = filteredSpecialList
        .where(
          (special) =>
              special.name.toLowerCase().contains(filterString) ||
              special.storeName.toLowerCase().contains(filterString) ||
              special.storeCategory.toLowerCase().contains(filterString),
        )
        .toList();

    if (dateRange != null) {
      // print("DATE RANGE: ${dateRange.start} - ${dateRange.end.add(const Duration(hours: 23, minutes: 59))}");
      filteredSpecialList = filteredSpecialList
          .where(
            (special) =>
                special.validUntil!.isAfter(dateRange.start) &&
                (special.validFrom.isBefore(
                  dateRange.end.add(const Duration(hours: 24, minutes: 59)),
                )),
          )
          .toList();
      // print("done filter date");
    }

    //setSpecialListState();
    await Future.delayed(const Duration(milliseconds: 300));
    _setFilteringState(FilterViewState.idle);
    //specialsViewModel.setState(SpecialViewState.idle);
    //print("Filter done");
    //print("filter $filteredSpecialList");
    return filteredSpecialList;
  }
}
