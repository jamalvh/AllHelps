import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart' as lat_lng;
import 'dart:math';

class LocationModel {
  final String name;
  final lat_lng.LatLng coordinates;
  final String openTime;
  final String closeTime;
  final List<String> services;

  LocationModel({
    required this.name,
    required this.coordinates,
    required this.openTime,
    required this.closeTime,
    required this.services,
  });

  static TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  bool isOpenNow() {
    final now = TimeOfDay.now();
    final open = _parseTime(openTime);
    final close = _parseTime(closeTime);

    int nowMinutes = now.hour * 60 + now.minute;
    int openMinutes = open.hour * 60 + open.minute;
    int closeMinutes = close.hour * 60 + close.minute;

    if (closeMinutes < openMinutes) {
      return nowMinutes >= openMinutes || nowMinutes <= closeMinutes;
    }
    return nowMinutes >= openMinutes && nowMinutes <= closeMinutes;
  }

  static String formatTimeTo12Hour(String time) {
    final parsedTime = _parseTime(time);
    final hour = parsedTime.hour;
    final minute = parsedTime.minute;

    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
    final formattedMinute = minute.toString().padLeft(2, '0');

    return '$formattedHour:$formattedMinute $period';
  }

  static int estimateWalkingTime(double distanceInMiles) {
    const double walkingSpeedMph = 3.0;
    double timeInHours = distanceInMiles / walkingSpeedMph;
    int timeInMinutes = (timeInHours * 60).round();
    return timeInMinutes;
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'],
      coordinates: lat_lng.LatLng(json['latitude'], json['longitude']),
      openTime: json['openTime'],
      closeTime: json['closeTime'],
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
