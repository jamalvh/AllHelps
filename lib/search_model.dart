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
  late lat_lng.LatLng location;
  List<String> filters = [];
  String timings = "";

  Future<lat_lng.LatLng> getCurrentLocation() async {
    Location location_res = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    if (!kIsWeb){
      serviceEnabled = await location_res.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location_res.requestService();
        if (!serviceEnabled) {
          return Future.error('Service failed');
        }
      }

      permissionGranted = await location_res.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location_res.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return Future.error('Permission failed');
        }
      }
    }

    locationData = await location_res.getLocation();

    return lat_lng.LatLng(
        locationData.latitude!,
        locationData
            .longitude!); //FIXME: Using ! to enforce non-null is... unsafe
  }
}
