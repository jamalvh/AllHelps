import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:allhelps/signin.dart';
import 'package:allhelps/locations.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart'; // Import locations model

class MyPage extends StatefulWidget {
  final int selectedIndex;
  final Function(int, {String? filter}) onIndexChanged;
  const MyPage(
      {super.key, required this.selectedIndex, required this.onIndexChanged});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  Map<String, dynamic>? _userData;
  List<LocationModel> _favoritedLocations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _currentUser = _auth.currentUser;
    });

    if (_currentUser != null) {
      try {
        // Fetch user document
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(_currentUser!.uid).get();

        // Get favorited location IDs
        List<dynamic> favoritedLocationIds =
            (userDoc.data() as Map<String, dynamic>?)?['favoritedLocations'] ??
                [];

        // Fetch full location details
        if (favoritedLocationIds.isNotEmpty) {
          // Load all locations
          List<LocationModel> allLocations = await loadLocations();

          // Filter to only favorited locations
          _favoritedLocations = allLocations
              .where((location) => favoritedLocationIds.contains(location.id))
              .toList();
        }

        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>?;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching user data: $e')),
        );
      }
    }
  }

  void _signOut() async {
    try {
      await _auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => SignInPage(
                  onIndexChanged: widget.onIndexChanged,
                  selectedIndex: widget.selectedIndex,
                )),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign out failed: $e')),
      );
    }
  }

  Future<void> _removeFavorite(String locationId) async {
    try {
      // Remove from Firestore
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'favoritedLocations': FieldValue.arrayRemove([locationId])
      });

      // Update local state
      setState(() {
        _favoritedLocations
            .removeWhere((location) => location.id == locationId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location removed from favorites')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing favorite: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF6359CA),
          ),
          child: const SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 50.0, bottom: 10.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    'My',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    // Profile Avatar
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple,
                            Colors.deepPurple.shade300,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          (_userData?['firstName'] ?? '')[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Name
                    Text(
                      '${_userData?['firstName'] ?? ''} ${_userData?['lastName'] ?? ''}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple[800],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Email
                    Text(
                      _currentUser?.email ?? 'No email',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Favorited Locations Section
                    _buildFavoritedLocationsSection(),

                    const SizedBox(height: 30),

                    // Sign Out Button
                    ElevatedButton(
                      onPressed: _signOut,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFavoritedLocationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Favorited Locations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple[800],
          ),
        ),
        const SizedBox(height: 10),
        _favoritedLocations.isEmpty
            ? _buildEmptyFavoritesWidget()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _favoritedLocations.length,
                itemBuilder: (context, index) {
                  final location = _favoritedLocations[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                          )
                        ],
                      ),
                      child: ListTile(
                        onTap: () =>
                            _showLocationDetailsDialog(context, location),
                        title: Text(
                          location.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple[800],
                          ),
                        ),
                        subtitle: Text(
                          'Open: ${LocationModel.formatTimeTo12Hour(location.openTime)} - ${LocationModel.formatTimeTo12Hour(location.closeTime)}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          ),
                          onPressed: () => _removeFavorite(location.id),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildEmptyFavoritesWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.deepPurple[300],
          ),
          const SizedBox(height: 15),
          Text(
            'No Favorited Locations Yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.deepPurple[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Start exploring and save your favorite locations!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Add these methods to your _MyPageState class
  void _showLocationDetailsDialog(
      BuildContext context, LocationModel location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: _buildPopupContent(context, location),
        );
      },
    );
  }

  Widget _buildPopupContent(BuildContext context, LocationModel location) {
    // Format date for display based on your event data
    String formattedDate = "March 3, 2025";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // To make the card wrap content
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  location.name,
                  style: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: location.isOpenNow() ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  location.isOpenNow() ? 'OPEN' : 'CLOSED',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Icon(Icons.category, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8.0),
              Text(
                "Resources", // Type from your data
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey[700], size: 20),
              const SizedBox(width: 8.0),
              Text(
                formattedDate,
                style: TextStyle(color: Colors.grey[800], fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Text(
            "Services Available",
            style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 8.0,
            children: location.services.map((service) {
              return Chip(
                label: Text(
                  service,
                  style: const TextStyle(color: Colors.black),
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                side: BorderSide(color: Colors.grey[300]!),
                padding: const EdgeInsets.symmetric(
                  vertical: 1.0,
                  horizontal: 2.0,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              const Icon(Icons.directions_walk, color: Colors.black54),
              const SizedBox(width: 8.0),
              Text(
                "${LocationModel.estimateWalkingTime(location.distance)} mins walking (${location.distance.toStringAsFixed(1)} miles)",
                style: TextStyle(color: Colors.grey[700], fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              const Icon(Icons.timer, color: Colors.black54),
              const SizedBox(width: 8.0),
              Text(
                'Accept walk-in until ${LocationModel.formatTimeTo12Hour(location.closeTime)}',
                style: TextStyle(color: Colors.grey[700], fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          // Add the telephone number row here
          Row(
            children: [
              const Icon(Icons.phone, color: Colors.black54),
              const SizedBox(width: 8.0),
              GestureDetector(
                onTap: () {
                  if (location.tel != "No Phone Number") {
                    final Uri phoneUri = Uri(scheme: 'tel', path: location.tel);
                    launchUrl(phoneUri);
                  }
                  // Use the url_launcher package to make a phone call
                },
                child: Text(
                  location.tel,
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 15,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "CLOSE",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _openMapsForDirections(location);
                },
                child: const Text(
                  "GET DIRECTIONS",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openMapsForDirections(LocationModel location) async {
    final availableMaps = await MapLauncher.installedMaps;

    if (availableMaps.isNotEmpty) {
      // Try to find platform-specific maps first
      final preferredMap = Platform.isIOS
          ? availableMaps.firstWhere(
              (map) => map.mapType == MapType.apple,
              orElse: () => availableMaps.first,
            )
          : availableMaps.firstWhere(
              (map) => map.mapType == MapType.google,
              orElse: () => availableMaps.first,
            );

      await preferredMap.showDirections(
        destination: Coords(
          location.coordinates.latitude,
          location.coordinates.longitude,
        ),
        destinationTitle: location.name,
      );
    } else {
      // Fallback to URL schemes if map_launcher fails
      final lat = location.coordinates.latitude;
      final lng = location.coordinates.longitude;
      final name = Uri.encodeComponent(location.name);

      String url;
      if (Platform.isIOS) {
        // Apple Maps URL scheme
        url = 'https://maps.apple.com/?daddr=$lat,$lng&dirflg=w';
      } else {
        // Google Maps URL scheme
        url =
            'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$name&travelmode=walking';
      }

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch maps';
      }
    }
  }
}
