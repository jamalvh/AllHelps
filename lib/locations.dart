import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart' as lat_lng;
import 'package:http/http.dart' as http;

class LocationModel {
  final String name;
  final lat_lng.LatLng coordinates;
  final String openTime;
  final String closeTime;
  final List<String> services;
  late double distance = -1;
  bool hasDistance = false;

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

  void clearDistance() {
    hasDistance = false;
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

  Future<double> calculateDistance(
      double lat1, double long1, double lat2, double long2) async {
    if (hasDistance) {
      return distance;
    }
    final response = await http.get(Uri.parse(
        'http://router.project-osrm.org/route/v1/foot/$long1,$lat1;$long2,$lat2?overview=false'));
    if (response.statusCode == 200) {
      final result = await jsonDecode(response.body) as Map<String, dynamic>;
      if (result['code'] == 'Ok') {
        hasDistance = true;
        distance = result['routes'][0]['distance'] / 1609.34;
        return distance;
      } else {
        return -1;
      }
    } else {
      return -1;
    }
  }

  List<LocationModel> filterLocationsByDistance(List<LocationModel> locations,
      double currentLat, double currentLon, double maxDistance) {
    return locations.where((location) {
      return location.distance <= maxDistance;
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
    return [];
  }
}



