import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart' as lat_lng;
import 'dart:math';

class LocationModel {
  final String name;
  final lat_lng.LatLng coordinates;
  final bool isOpen;
  final List<String> services;

  LocationModel({
    required this.name,
    required this.coordinates,
    required this.isOpen,
    required this.services,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'],
      coordinates: lat_lng.LatLng(json['latitude'], json['longitude']),
      isOpen: json['isOpen'],
      services: List<String>.from(json['services']),
    );
  }

  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 3961;

    double lat1Rad = _degToRad(lat1);
    double lon1Rad = _degToRad(lon1);
    double lat2Rad = _degToRad(lat2);
    double lon2Rad = _degToRad(lon2);

    double dlat = lat2Rad - lat1Rad;
    double dlon = lon2Rad - lon1Rad;

    double a = sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dlon / 2) * sin(dlon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degToRad(double deg) {
    return deg * (pi / 180.0);
  }

  static List<LocationModel> filterLocationsByDistance(
      List<LocationModel> locations,
      double currentLat,
      double currentLon,
      double maxDistance) {
    return locations.where((location) {
      double distance = calculateDistance(currentLat, currentLon,
          location.coordinates.latitude, location.coordinates.longitude);
      return distance <= maxDistance;
    }).toList();
  }
}

Future<List<LocationModel>> loadLocations() async {
  try {
    final String jsonString =
        await rootBundle.loadString('lib/help_page_assets/locations.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    return jsonData
        .map((location) => LocationModel.fromJson(location))
        .toList();
  } catch (e) {
    print("Error loading locations: $e");
    return [];
  }
}
