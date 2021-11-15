import 'dart:developer';

import 'package:flutter/material.dart';

import '../core/failure.dart';
import '../data_models/location.dart';
import '../repositories/specials_repo.dart';
import '../widgets/snackbar.dart';

enum LocationsViewState {
  idle,
  busy,
  error,
  uploading,
  deleting,
  uploadingImage,
  updatingStatus
}

// ignore: prefer_function_declarations_over_variables
final Comparator<Location> _nameComparator =
    (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase());
// ignore: prefer_function_declarations_over_variables

class LocationsViewModel extends ChangeNotifier {
  SpecialsRepository specialsRepository;

  LocationsViewModel({required this.specialsRepository});

  List<Location> _locationsList = [];
  List<Location> get locationsList => _locationsList;

  // Build Context
  late BuildContext _context;
  // ignore: avoid_setters_without_getters
  set context(BuildContext ctx) => _context = ctx;

  // State Management
  LocationsViewState _state = LocationsViewState.busy;
  LocationsViewState get state => _state;
  void setState(LocationsViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  // Error Handling
  void _handleFailure(Failure failure) {
    log("Locations VM: $failure");
    Failure.handleFailure(context: _context, failure: failure);
    // Failure.handleFailure(context: _context, failure: failure, logoutFunction: authViewModel.logout, );

    setState(LocationsViewState.error);
  }

  Future<int> createLocation(Location location) async {
    setState(LocationsViewState.uploading);
    int newLocationId = 0;

    final failureOrLocationId = await specialsRepository.createLocation(location);
    failureOrLocationId.fold((failure) => _handleFailure(failure), (newLocation) {
      _locationsList.add(newLocation as Location);
      _locationsList.sort(_nameComparator);
      newLocationId = newLocation.id;
      InfoSnackBar.show(_context, "New Location Created");
      setState(LocationsViewState.idle);
    });

    return newLocationId;
  }

  Future<void> getAllLocations() async {
    setState(LocationsViewState.busy);

    final failureOrLocationsList = await specialsRepository.getAllLocations();
    failureOrLocationsList.fold((failure) => _handleFailure(failure), (locationList) {
      // ignore: prefer_function_declarations_over_variables
      final Comparator<Location> nameComparator =
          (a, b) => a.name.compareTo(b.name);

      _locationsList = (locationList as Set<Location>).toList();
      _locationsList.sort(nameComparator);
      setState(LocationsViewState.idle);
    });

    // await Future.delayed(const Duration(seconds: 1),
    //   () => _locationsList = mockLocationList.map((location) => Location.fromJson(location)).toSet()
    // );
    // setState(LocationsViewState.idle);
  }

  Future<bool> updateLocation(Location location) async {
    setState(LocationsViewState.uploading);
    bool updateSuccess = false;

    final failureOrSuccess = await specialsRepository.updateLocation(location);
    failureOrSuccess.fold((failure) => _handleFailure(failure), (updatedLocation) {
      _locationsList[(_locationsList
              .indexWhere((tempLocation) => tempLocation.id == location.id))] =
          updatedLocation as Location;
      // ignore: prefer_function_declarations_over_variables
      _locationsList.sort(_nameComparator);
      updateSuccess = true;
      InfoSnackBar.show(_context, "Location Updated");
      setState(LocationsViewState.idle);
    });

    return updateSuccess;
  }

  Future<void> deleteLocation(Location location) async {
    setState(LocationsViewState.deleting);

    final failureOrSuccess = await specialsRepository.deleteLocation(location);
    failureOrSuccess.fold((failure) => _handleFailure(failure), (_) {
      _locationsList.remove(location);
      InfoSnackBar.show(_context, "Location Deleted");
      setState(LocationsViewState.idle);
    });
  }

  // Future<bool> toggleLocationActivate(Location location) async {
  //   setState(LocationsViewState.updatingStatus);
  //   bool updateSuccess = false;

  //   final failureOrSuccess =
  //       await specialsRepository.toggleLocationActivate(location);
  //   failureOrSuccess.fold((failure) => _handleFailure(failure), (_) {
  //     _locationsList[(_locationsList
  //         .indexWhere((tempLocation) => tempLocation.uuid == location.uuid))] = location;
  //     updateSuccess = true;
  //     InfoSnackBar.show(_context,
  //         "Location ${location.status == LocationStatus.active ? "Activated" : "De-activated"}");
  //   });

  //   setState(LocationsViewState.idle);
  //   return updateSuccess;
  // }

  // Future<List<SearchedPlace>> searchPlaceByQuery(String query) async {
  //   List<SearchedPlace> placeList = [];
  //   final failureOrPlaceList =
  //       await specialsRepository.searchPlaceByQuery(query);
  //   failureOrPlaceList.fold(
  //     (failure) => _handleFailure(failure),
  //     (places) => placeList = places as List<SearchedPlace>,
  //   );
  //   return placeList;
  // }
}
