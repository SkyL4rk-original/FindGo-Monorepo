import 'package:findgo/data_models/lat_lon.dart';
import 'package:findgo/external_services/location_svs.dart';
import 'package:findgo/repositories/specials_repo.dart';
import 'package:findgo/widgets/snackbar.dart';
import 'package:flutter/material.dart';

enum LocationViewState { busy, idle, noPermission }

class LocationViewModel extends ChangeNotifier {
  LocationService locationService;
  SpecialsRepository specialsRepository;

  // Constructor
  LocationViewModel({
    required this.locationService,
    required this.specialsRepository,
  });

  late BuildContext context;
  bool isInitCheck = true;

  LocationViewState _state = LocationViewState.idle;
  void _setLocationState(LocationViewState ls) {
    _state = ls;
    notifyListeners();
  }

  bool get busy => _state == LocationViewState.busy;
  bool get noPermission => _state == LocationViewState.noPermission;
  Future<bool> get isLocationEnabled => locationService.isLocationEnabled;

  LatLng _latLng = const LatLng.nil();
  LatLng get latLng => _latLng;

  bool get hasUserLocation => _latLng.isNotNil;
  bool get showUserLoc => _latLng != const LatLng.nil();
  bool _showErrorMessage = true;

  Future<bool> fetchCurrentPosition() async {
    _setLocationState(LocationViewState.busy);
    final errorMessage = await locationService.checkPermissionError();
    if (errorMessage != null) {
      //await specialsRepository.storeCurrentLocation(LatLng(lat: null, lng: null));
      await specialsRepository.storeLocationRange(null);
      _latLng = const LatLng.nil();
      // await Future.delayed(const Duration(milliseconds: 300));
      //_setLocationState(LocationViewState.noPermission);
      _setLocationState(LocationViewState.idle);
      if (_showErrorMessage) {
        InfoSnackBar.show(context, errorMessage, color: SnackBarColor.error);
        _showErrorMessage = false;
      }
      return false;
    }

    final lastLocation = await locationService.getLastKnownLocation();
    if (lastLocation == null) {
      _latLng = await locationService.getCurrentLatLng();
    } else {
      _latLng = LatLng(lat: lastLocation.lat, lng: lastLocation.lng);
    }
    await Future.delayed(const Duration(milliseconds: 100));
    _setLocationState(LocationViewState.idle);

    backgroundLocationCheck();
    return true;
    // InfoSnackBar.show(context, _latLng.toString());
  }

  Future<void> backgroundLocationCheck() async {
    final loc = await locationService.getCurrentLatLng();
    if (_latLng.isNotNil && getDistanceBetweenInKm(LatLng(lat: loc.lat, lng: loc.lng)) >= 1) {
      _setLocationState(LocationViewState.busy);
      _latLng = LatLng(lat: loc.lat, lng: loc.lng);
      await Future.delayed(const Duration(milliseconds: 100));
      _setLocationState(LocationViewState.idle);
    }
  }

  double getDistanceBetweenInKm(LatLng storeLocation) =>
      locationService.getDistanceBetween(_latLng, storeLocation) / 1000;

  String getDistanceBetweenAsString(
    LatLng storeLocation,
  ) {
    final distanceInMeters =
        locationService.getDistanceBetween(_latLng, storeLocation);

    if (distanceInMeters < 1000) {
      return "${distanceInMeters.round()} meters away";
    }

    return "${(distanceInMeters / 1000).toStringAsFixed(1)} km away";
  }
}
