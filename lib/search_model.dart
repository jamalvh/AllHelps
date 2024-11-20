import 'package:location/location.dart';
import 'package:latlong2/latlong.dart' as lat_lng;
import "package:flutter/foundation.dart" show kIsWeb;

class SearchModel {
  // Singleton model
  static final SearchModel _instance = SearchModel._internal();
  SearchModel._internal();

  factory SearchModel() {
    return _instance;
  }
  String name = "";
  bool isOpen = false;
  late lat_lng.LatLng latLng;
  List<String> filters = [];
  String timings = "";
  Location location = Location();
  late LocationData locationData;
  bool showResults = false;

  Future<lat_lng.LatLng> getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    if (!kIsWeb) {
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return Future.error('Service failed');
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return Future.error('Permission failed');
        }
      }
    }

    locationData = await location.getLocation();

    return lat_lng.LatLng(locationData.latitude!, locationData.longitude!);
  }
}
