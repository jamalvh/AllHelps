import 'package:allhelps/filter_model.dart';
import 'package:allhelps/help_page_filters.dart';
import 'package:allhelps/search_model.dart';
import 'package:allhelps/search_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart' as lat_lng;
import 'locations.dart';
import 'navigation.dart';

class HelpsPage extends StatefulWidget {
  const HelpsPage({super.key});

  @override
  State<HelpsPage> createState() => _HelpsPageState();
}

class _HelpsPageState extends State<HelpsPage> {
  double _sheetPosition = 0.4;
  final double _dragSensitivity = 600;

  SearchModel searchModel = SearchModel();

  FilterModel filterModel = FilterModel();

  final MapController _mapController = MapController();
  double currLat = 42.279;
  double currLong = -83.732;
  bool locationObtained = false;
  int _selectedIndex = 0;

  Location location = Location();
  late LocationData locationData;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    _loadLocations();
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
                    updateResults: updateResults),
              ),
              searchModel.showResults
                  ? SearchOptions(
                      searches: filterModel.searches,
                      updateResults: updateResults,
                      searchModel: searchModel,
                    )
                  : Container(),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter:
                  lat_lng.LatLng(currLat, currLong), // Current location
              initialZoom: 15,
              minZoom: 0.5,
            ),
            mapController: _mapController,
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.allhelps',
              ),
              StatefulBuilder(builder: (context, setState) {
                location.onLocationChanged
                    .listen((LocationData currentLocation) {
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
                                'lib/help_page_assets/current_location_marker.png'),
                          ),
                          // Shelter location markers
                          ...searchModel.locations.map((location) {
                            return Marker(
                              point: lat_lng.LatLng(
                                  location.coordinates.latitude,
                                  location.coordinates.longitude),
                              width: 55,
                              height: 55,
                              child: Image.asset(filterModel
                                  .getMarkerIcon(location.services[0])),
                            );
                          })
                        ],
                      )
                    : Container();
              })
            ],
          ),
          StatefulBuilder(builder: (context, setState) {
            return RefreshIndicator(
              onRefresh: () {
                setState(
                  () {
                    print('refreshing');
                    for (int index = 0;
                        index < searchModel.locations.length;
                        index++) {
                      searchModel.locations[index].clearDistance();
                    }
                  },
                );

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
                                        15); // Default initial zoom of map is 13
                                  },
                                  backgroundColor: Colors.white,
                                  child: const Icon(Icons.near_me_rounded),
                                ),
                              ),
                            )
                          : Container(),
                      const SizedBox(
                        height: 10,
                      ),
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
                                    _sheetPosition =
                                        _sheetPosition.clamp(0.2, 0.8);
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
                                          TextSpan(children: [
                                            const TextSpan(
                                                text: 'We found ',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            TextSpan(
                                                text: filterModel
                                                        .chosenFilter.isEmpty
                                                    ? '${searchModel.locations.length} Releifs'
                                                    : '${searchModel.locations.length} ${filterModel.chosenFilter} Locations',
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    color: Colors.deepPurple)),
                                            TextSpan(
                                                text: filterModel
                                                        .chosenFilter.isEmpty
                                                    ? ' nearby'
                                                    : ' within 2 miles',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ))
                                          ])),
                                    ),
                                    const Spacer(),
                                    Tooltip(
                                      message:
                                          'These are the nearest shelters based on your current location',
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      textStyle: const TextStyle(
                                          color: Colors.white, fontSize: 14),
                                      preferBelow:
                                          false, // Display the tooltip above the widget
                                      showDuration: const Duration(
                                          seconds:
                                              2), // Time the tooltip remains visible
                                      waitDuration:
                                          const Duration(milliseconds: 500),
                                      child: const Icon(
                                        Icons.info_outline,
                                        size: 24,
                                      ), // Time to wait before showing
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: StatefulBuilder(
                                    builder: (context, setState) {
                                  return ListView.builder(
                                    // physics: const NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    itemCount: searchModel.locations.length,
                                    itemBuilder: (context, index) {
                                      final availableLocation =
                                          searchModel.locations[index];
                                      //final isOpen = availableLocation.isOpen;
                                      final services = [
                                        'Laundry',
                                        'Support',
                                        'Shower'
                                      ];
                                      // double distance =
                                      //     LocationModel.calculateDistance(
                                      //         currLat,
                                      //         currLong,
                                      //         availableLocation
                                      //             .coordinates.latitude,
                                      //         availableLocation
                                      //             .coordinates.longitude);

                                      // location.onLocationChanged
                                      //     .listen((LocationData currentLocation) {
                                      //   setState(() {
                                      //     distance =
                                      //         LocationModel.calculateDistance(
                                      //             currLat,
                                      //             currLong,
                                      //             availableLocation
                                      //                 .coordinates.latitude,
                                      //             availableLocation
                                      //                 .coordinates.longitude);
                                      //   });
                                      // });

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 16.0),
                                        child: Container(
                                          padding: const EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(12.0),
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
                                                    availableLocation.name,
                                                    style: const TextStyle(
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 12.0,
                                                      vertical: 4.0,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: availableLocation
                                                              .isOpenNow()
                                                          ? Colors.green
                                                          : Colors.red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                    ),
                                                    child: Text(
                                                      availableLocation
                                                              .isOpenNow()
                                                          ? 'OPEN'
                                                          : 'CLOSED',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(height: 40.0),
                                              Row(
                                                children: [
                                                  const Icon(
                                                      Icons.directions_walk,
                                                      color: Colors.black54),
                                                  const SizedBox(width: 8),
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
                                                                  .longitude),
                                                      builder:
                                                          (context, snapshot) {
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
                                                                'Navigation server failure');
                                                          } else {
                                                            return Text(
                                                                '${LocationModel.estimateWalkingTime(searchModel.locations[index].distance)} mins by walking (${searchModel.locations[index].hasDistance ? '' : '(OLD VALUE)'}${searchModel.locations[index].distance.toStringAsFixed(1)} miles)',
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black54));
                                                          }
                                                        } else {
                                                          return const CircularProgressIndicator();
                                                        }
                                                      }),
                                                ],
                                              ),
                                              const SizedBox(height: 8.0),
                                              Row(
                                                children: [
                                                  const Icon(Icons.timer,
                                                      color: Colors.black54),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Accept walk-in until ${LocationModel.formatTimeTo12Hour(availableLocation.closeTime)}',
                                                    style: const TextStyle(
                                                        color: Colors.black54),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12.0),
                                              // Services Tags
                                              Wrap(
                                                spacing: 8.0,
                                                children:
                                                    services.map((service) {
                                                  return Chip(
                                                    label: Text(
                                                      service,
                                                      style: const TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                    backgroundColor:
                                                        Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20.0)),
                                                    side: BorderSide.none,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 1.0,
                                                        horizontal: 2.0),
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),
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
          }),
        ],
      ),
      bottomNavigationBar: MyNavigationBar(
          currentPageIndex: _selectedIndex,
          onItemTapped: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          }),
    );
  }
}

class Grabber extends StatelessWidget {
  const Grabber({
    super.key,
    required this.onVerticalDragUpdate,
  });

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
