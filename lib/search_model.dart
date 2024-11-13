import 'package:location/location.dart';
import 'package:latlong2/latlong.dart' as lat_lng;

class SearchModel {
  String name = "";
  bool isOpen = false;
  lat_lng.LatLng location;
  List<String> filters = [];
  String timings = "";
  
  Future<lat_lng.LatLng> getCurrentLocation() async {
    Location location_res = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location_res.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location_res.requestService();
      if (!serviceEnabled) {
        print('Service failed');
        return Future.error('Service failed');
      }
    }

    permissionGranted = await location_res.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location_res.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print('Permission failed');
        return Future.error('Permission failed');
      }
    }

    locationData = await location_res.getLocation();

    return lat_lng.LatLng(locationData.latitude!, locationData.longitude!); //FIXME: Using ! to enforce non-null is... unsafe
  }
  
  SearchModel(
      {required this.name,
      required this.isOpen,
      required this.location,
      required this.filters,
      required this.timings});
}
