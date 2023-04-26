import 'package:geolocator/geolocator.dart';

import 'package:timely/backend_models/location_data.dart';

class LocationController {

  // Creates a LocationController with a Location object from the
  // location plugin, and verifies that service is enabled and permission
  // has been granted
  LocationController(){
    verify();
  }

  Future<void> verify() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
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
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  // Future<bool> _checkService() async {
  //   bool _serviceEnabled = await location.serviceEnabled();
  //   if (!_serviceEnabled) {
  //     _serviceEnabled = await location.requestService();
  //     if (!_serviceEnabled) {
  //       throw Exception('Location services not enabled');
  //     }
  //   }
  //   return _serviceEnabled;
  // }
  //
  // Future<loc.PermissionStatus> _checkPermission() async {
  //   loc.PermissionStatus _permissionGranted = await location.hasPermission();
  //   if (_permissionGranted == loc.PermissionStatus.denied) {
  //     _permissionGranted = await location.requestPermission();
  //     if (_permissionGranted != loc.PermissionStatus.granted) {
  //       throw Exception('Permission not granted for accessing location information');
  //     }
  //   }
  //   return _permissionGranted;
  // }

  Future<LocationData> currentLocation() async {

    Position curr = await Geolocator.getCurrentPosition();
    LocationData currentLocation = LocationData.fromCoordinates(curr.latitude!, curr.longitude!);
    return currentLocation;
  }
}