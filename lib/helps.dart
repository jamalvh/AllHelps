import 'dart:io';

import 'package:allhelps/filter_model.dart';
import 'package:allhelps/help_page_filters.dart';
import 'package:allhelps/search_model.dart';
import 'package:allhelps/search_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart' as lat_lng;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'locations.dart';

class HelpsPage extends StatefulWidget {
  final Function(int, {String? filter}) onIndexChanged;

  const HelpsPage({super.key, required this.onIndexChanged});

  @override
  State<HelpsPage> createState() => _HelpsPageState();
}

class _HelpsPageState extends State<HelpsPage> {
  double _sheetPosition = 0.4;
  final double _dragSensitivity = 600;

  SearchModel searchModel = SearchModel();
  FilterModel filterModel = FilterModel();
  final MapController _mapController = MapController();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double currLat = 36.129920;
  double currLong = -115.116680;
  bool locationObtained = false;

  Location location = Location();
  late LocationData locationData;

  // Favorite locations tracking
  Set<String> favoritedLocations = {};

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    _loadLocations();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        // Retrieve favorited locations if they exist
        final userData = userDoc.data() as Map<String, dynamic>?;
        setState(() {
          favoritedLocations = userData?['favoritedLocations'] != null
              ? Set<String>.from(userData!['favoritedLocations'])
              : {};
        });
      } catch (e) {
        print('Error loading favorites: $e');
      }
    }
  }

  Future<void> _toggleFavorite(String locationId) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        setState(() {
          if (favoritedLocations.contains(locationId)) {
            favoritedLocations.remove(locationId);
          } else {
            favoritedLocations.add(locationId);
          }
        });

        // Update Firestore with new favorites
        await _firestore.collection('users').doc(user.uid).update({
          'favoritedLocations': favoritedLocations.toList(),
        });
      } catch (e) {
        print('Error toggling favorite: $e');
        // Revert the local state if update fails
        setState(() {
          if (favoritedLocations.contains(locationId)) {
            favoritedLocations.remove(locationId);
          } else {
            favoritedLocations.add(locationId);
          }
        });
      }
    }
  }

  Future<void> _loadLocations() async {
    searchModel.locations = await loadLocations();
    setState(() {});
  }

  void activateSearch() {
    setState(() {
      filterModel.initializeSearches();
      searchModel.showResults = true;
    });
  }

  void closeSearch() async {
    searchModel.locations = await loadLocations();
    setState(() {
      filterModel.setChosenFilter("");
      searchModel.showResults = false;
    });
  }

  void updateSearch(String value) {
    setState(() {
      if (value == '') {
        filterModel.initializeSearches();
      } else {
        filterModel.searches.clear();
        for (String filter in filterModel.filters.keys.toList()) {
          if (filter.toLowerCase().contains(value.toLowerCase())) {
            filterModel.searches.add(filter);
          }
        }
      }
    });
  }

  void updateResults(topFilter) {
    setState(() {
      searchModel.locations.removeWhere((location) {
        return !location.services.contains(topFilter);
      });
    });
  }

  void filterLocationsByWalkingTime(maxMinutes) {
    setState(() {
      searchModel.locations.removeWhere((location) {
        final walkingTime = LocationModel.estimateWalkingTime(
          location.distance,
        );
        return walkingTime > maxMinutes;
      });
    });
  }

  Future<void> getCurrentLocation() async {
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
    setState(() {
      locationObtained = true;
      currLat = locationData.latitude!;
      currLong = locationData.longitude!;
      _mapController.move(lat_lng.LatLng(currLat, currLong), 15);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (filterModel.chosenFilter.isNotEmpty) {
      updateResults(filterModel.chosenFilter);
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: !searchModel.showResults
            ? MediaQuery.of(context).size.height * 0.18
            : MediaQuery.of(context).size.height,
        flexibleSpace: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Filters(
                  activateSearch: activateSearch,
                  closeSearch: closeSearch,
                  updateSearch: updateSearch,
                  updateResults: updateResults,
                  filterLocationsByWalkingTime: filterLocationsByWalkingTime,
                ),
              ),
              searchModel.showResults
                  ? SearchOptions(
                      searches: filterModel.searches,
                      updateResults: updateResults,
                      searchModel: searchModel,
                      onIndexChanged: widget.onIndexChanged,
                    )
                  : Container(),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: lat_lng.LatLng(
                currLat,
                currLong,
              ), // Current location
              initialZoom: 15,
              minZoom: 0.5,
            ),
            mapController: _mapController,
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.allhelps',
              ),
              StatefulBuilder(
                builder: (context, setState) {
                  location.onLocationChanged.listen((
                    LocationData currentLocation,
                  ) {
                    setState(() {
                      currLat = currentLocation.latitude != null
                          ? currentLocation.latitude!
                          : currLat;
                      currLong = currentLocation.latitude != null
                          ? currentLocation.longitude!
                          : currLong;
                    });
                  });

                  return locationObtained
                      ? MarkerLayer(
                          markers: [
                            // Current location marker
                            Marker(
                              point: lat_lng.LatLng(currLat, currLong),
                              width: 20,
                              height: 20,
                              child: Image.asset(
                                'lib/help_page_assets/current_location_marker.png',
                              ),
                            ),
                            // Shelter location markers
                            ...searchModel.locations.map((location) {
                              return Marker(
                                point: lat_lng.LatLng(
                                  location.coordinates.latitude,
                                  location.coordinates.longitude,
                                ),
                                width: 100,
                                height: 100,
                                child: Image.asset(
                                  filterModel
                                      .getMarkerIcon(location.services[0]),
                                ),
                              );
                            }),
                          ],
                        )
                      : Container();
                },
              ),
            ],
          ),
          StatefulBuilder(
            builder: (context, setState) {
              return RefreshIndicator(
                onRefresh: () {
                  setState(() {
                    for (int index = 0;
                        index < searchModel.locations.length;
                        index++) {
                      searchModel.locations[index].clearDistance();
                    }
                  });

                  return Future.delayed(Duration.zero);
                },
                child: DraggableScrollableSheet(
                  initialChildSize: _sheetPosition,
                  minChildSize: 0.2,
                  maxChildSize: 0.8,
                  builder: (context, scrollController) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        locationObtained
                            ? Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: SizedBox(
                                  height: 44,
                                  width: 44,
                                  child: FloatingActionButton(
                                    onPressed: () {
                                      _mapController.move(
                                        lat_lng.LatLng(currLat, currLong),
                                        15,
                                      ); // Default initial zoom of map is 13
                                    },
                                    backgroundColor: Colors.white,
                                    child: const Icon(Icons.near_me_rounded),
                                  ),
                                ),
                              )
                            : Container(),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ColoredBox(
                            color: Colors.white,
                            child: Column(
                              children: [
                                Grabber(
                                  onVerticalDragUpdate: (details) {
                                    setState(() {
                                      _sheetPosition -=
                                          details.delta.dy / _dragSensitivity;
                                      _sheetPosition = _sheetPosition.clamp(
                                        0.2,
                                        0.8,
                                      );
                                    });
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 0.8 *
                                            MediaQuery.of(context).size.width,
                                        child: Text.rich(
                                          overflow: TextOverflow.clip,
                                          softWrap: true,
                                          TextSpan(
                                            children: [
                                              const TextSpan(
                                                text: 'We found ',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                text: filterModel
                                                        .chosenFilter.isEmpty
                                                    ? '${searchModel.locations.length} Connects'
                                                    : '${searchModel.locations.length} ${filterModel.chosenFilter} Locations',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  color: Colors.deepPurple,
                                                ),
                                              ),
                                              TextSpan(
                                                text: filterModel
                                                        .chosenFilter.isEmpty
                                                    ? ' nearby'
                                                    : ' within 2 miles',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Tooltip(
                                        message:
                                            'These are the nearest shelters based on your current location',
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                        preferBelow:
                                            false, // Display the tooltip above the widget
                                        showDuration: const Duration(
                                          seconds: 2,
                                        ), // Time the tooltip remains visible
                                        waitDuration: const Duration(
                                          milliseconds: 500,
                                        ),
                                        child: const Icon(
                                          Icons.info_outline,
                                          size: 24,
                                        ), // Time to wait before showing
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: StatefulBuilder(
                                    builder: (context, setState) {
                                      final limitedLocations = searchModel
                                          .locations
                                          .take(10)
                                          .toList();

                                      return ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: limitedLocations.length,
                                        itemBuilder: (context, index) {
                                          final availableLocation =
                                              limitedLocations[index];
                                          final services = [
                                            'Laundry',
                                            'Support',
                                            'Shower',
                                          ];
                                          final isFavorited = favoritedLocations
                                              .contains(availableLocation.id);

                                          return InkWell(
                                            onTap: () =>
                                                _showLocationDetailsDialog(
                                              context,
                                              availableLocation,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                                horizontal: 16.0,
                                              ),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    12.0,
                                                  ),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          availableLocation
                                                              .name,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            // Favorite Button
                                                            IconButton(
                                                              icon: Icon(
                                                                isFavorited
                                                                    ? Icons
                                                                        .favorite
                                                                    : Icons
                                                                        .favorite_border,
                                                                color: isFavorited
                                                                    ? Colors.red
                                                                    : Colors
                                                                        .grey,
                                                              ),
                                                              onPressed: () {
                                                                _toggleFavorite(
                                                                  availableLocation
                                                                      .id,
                                                                );
                                                              },
                                                            ),
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal:
                                                                    12.0,
                                                                vertical: 4.0,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: availableLocation
                                                                        .isOpenNow()
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .red,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                  20.0,
                                                                ),
                                                              ),
                                                              child: Text(
                                                                availableLocation
                                                                        .isOpenNow()
                                                                    ? 'OPEN'
                                                                    : 'CLOSED',
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 15.0,
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.directions_walk,
                                                          color: Colors.black54,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        FutureBuilder(
                                                          future: searchModel
                                                              .locations[index]
                                                              .calculateDistance(
                                                            currLat,
                                                            currLong,
                                                            searchModel
                                                                .locations[
                                                                    index]
                                                                .coordinates
                                                                .latitude,
                                                            searchModel
                                                                .locations[
                                                                    index]
                                                                .coordinates
                                                                .longitude,
                                                          ),
                                                          builder: (
                                                            context,
                                                            snapshot,
                                                          ) {
                                                            if (snapshot
                                                                    .connectionState ==
                                                                ConnectionState
                                                                    .done) {
                                                              if (snapshot.data ==
                                                                      -1 &&
                                                                  searchModel
                                                                          .locations[
                                                                              index]
                                                                          .distance ==
                                                                      -1) {
                                                                return const Text(
                                                                  'Navigation server failure',
                                                                );
                                                              } else {
                                                                return Text(
                                                                  '${LocationModel.estimateWalkingTime(searchModel.locations[index].distance)} mins by walking (${searchModel.locations[index].hasDistance ? '' : '(OLD VALUE)'}${searchModel.locations[index].distance.toStringAsFixed(1)} miles)',
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                  ),
                                                                );
                                                              }
                                                            } else {
                                                              return const CircularProgressIndicator();
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8.0),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.timer,
                                                          color: Colors.black54,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          'Accept walk-in until ${LocationModel.formatTimeTo12Hour(availableLocation.closeTime)}',
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 12.0,
                                                    ),
                                                    // Services Tags
                                                    Wrap(
                                                      spacing: 8.0,
                                                      children: services.map((
                                                        service,
                                                      ) {
                                                        return Chip(
                                                          label: Text(
                                                            service,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          backgroundColor:
                                                              Colors.white,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              20.0,
                                                            ),
                                                          ),
                                                          side: BorderSide.none,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            vertical: 1.0,
                                                            horizontal: 2.0,
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Add this method to your _HelpsPageState class
  void _showLocationDetailsDialog(
    BuildContext context,
    LocationModel location,
  ) {
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

  // Add this method to your _HelpsPageState class
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

class Grabber extends StatelessWidget {
  const Grabber({super.key, required this.onVerticalDragUpdate});

  final ValueChanged<DragUpdateDetails> onVerticalDragUpdate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: onVerticalDragUpdate,
      child: Container(
        width: double.infinity,
        color: Colors.white,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            width: 32.0,
            height: 5.0,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }
}
