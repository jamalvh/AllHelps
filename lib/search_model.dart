import 'package:latlong2/latlong.dart' as lat_lng;

class SearchModel {
  final String name;
  final lat_lng.LatLng location;

  SearchModel({required this.location, required this.name});
}
