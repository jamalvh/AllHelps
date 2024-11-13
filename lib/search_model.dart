import 'package:latlong2/latlong.dart' as lat_lng;

class SearchModel {
  String name = "";
  bool isOpen = false;
  lat_lng.LatLng location;
  List<String> filters = [];
  String timings = "";

  SearchModel(
      {required this.name,
      required this.isOpen,
      required this.location,
      required this.filters,
      required this.timings});
}
