import 'package:allhelps/locations.dart';
import 'package:latlong2/latlong.dart' as lat_lng;

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
  // Location location = Location();
  // late LocationData locationData;
  bool showResults = false;

  List<LocationModel> locations = [];
}
