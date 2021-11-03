import 'package:findgo/data_models/lat_lon.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {

  Future<bool> get isLocationEnabled async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }

  Future<String?> checkPermissionError() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return 'Location permissions are permanently denied, we cannot request permissions.';
    }

    return null;
  }

  Future<LatLng> getCurrentLatLng() async {
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    final pos = await Geolocator.getCurrentPosition();
    return LatLng(lat: pos.latitude, lng: pos.longitude);
  }

  Future<LatLng?> getLastKnownLocation() async {
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    final pos = await Geolocator.getLastKnownPosition();
    if (pos != null) return LatLng(lat: pos.latitude, lng: pos.longitude);

    return null;
  }

  double getDistanceBetween(
    LatLng userLocation,
    LatLng storeLocation,
  ) {
    if (userLocation.isNil || storeLocation.isNil) return 0.0;
    return Geolocator.distanceBetween(
      userLocation.lat!,
      userLocation.lng!,
      storeLocation.lat!,
      storeLocation.lng!,
    );
  }
}
