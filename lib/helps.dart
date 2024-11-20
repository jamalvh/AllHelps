import 'package:allhelps/filter_model.dart';
import 'package:allhelps/help_page_filters.dart';
import 'package:allhelps/search_model.dart';
import 'package:allhelps/search_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart' as lat_lng;

import 'navigation.dart';

class HelpsPage extends StatefulWidget {
  const HelpsPage({super.key});

  @override
  State<HelpsPage> createState() => _HelpsPageState();
}

class _HelpsPageState extends State<HelpsPage> {
  SearchModel searchModel = SearchModel();

  FilterModel filterModel = FilterModel();

  final MapController _mapController = MapController();
  double currLat = 0;
  double currLong = 0;
  int _selectedIndex = 0;

  void activateSearch() {
    setState(() {
      filterModel.initializeSearches();
      searchModel.showResults = true;
      // filterModel.setChosenFilter('show search');
    });
  }

  void closeSearch() {
    setState(() {
      filterModel.setChosenFilter("");
      searchModel.showResults = false;
    });
  }

  void updateSearch(value) {
    setState(() {
      if (value == '') {
        filterModel.initializeSearches();
      } else {
        filterModel.searches.removeWhere((filter) {
          return !filter.contains(value);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    searchModel.location.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude == currLat &&
          currentLocation.longitude == currLong) return;
    });
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
                    updateSearch: updateSearch),
              ),
              searchModel.showResults
                  ? SearchOptions(
                      searches: filterModel.searches,
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
          // Map Layer
          FutureBuilder(
              future: searchModel.getCurrentLocation(),
              builder: (context, snapshot) {
                currLat =
                    snapshot.data != null ? snapshot.data!.latitude : currLat;
                currLong =
                    snapshot.data != null ? snapshot.data!.longitude : currLong;
                return snapshot.connectionState == ConnectionState.done
                    ? FlutterMap(
                        options: MapOptions(
                          initialCenter: lat_lng.LatLng(snapshot.data!.latitude,
                              snapshot.data!.longitude), // Current location
                          minZoom: 0.5,
                        ),
                        mapController: _mapController,
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.allhelps',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: lat_lng.LatLng(snapshot.data!.latitude,
                                    snapshot.data!.longitude),
                                width: 20,
                                height: 20,
                                child: Image.asset(
                                    'lib/help_page_assets/current_location_marker.png'),
                              ),
                            ],
                          ),
                        ],
                      )
                    : const Center(child: CircularProgressIndicator());
              }),

          Positioned(
            top: 0.7 * MediaQuery.of(context).size.height,
            left: 0.05 * MediaQuery.of(context).size.width,
            child: FloatingActionButton(
              onPressed: () {
                _mapController.move(lat_lng.LatLng(currLat, currLong),
                    13); // Default initial zoom of map is 13
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.near_me_rounded),
            ),
          ),

          const Grabber()
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

class Grabber extends StatefulWidget {
  const Grabber({
    super.key,
  });

  @override
  State<Grabber> createState() => _GrabberState();
}

class _GrabberState extends State<Grabber> {
  @override
  Widget build(BuildContext context) {
    double _sheetPosition = 0.5;
    final double _dragSensitivity = 600;
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          _sheetPosition -= details.delta.dy / _dragSensitivity;
          _sheetPosition = _sheetPosition.clamp(0.2, 0.8);
        });
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.2,
        maxChildSize: 0.8,
        builder: (context, scrollController) {
          return ColoredBox(
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'We found ',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              TextSpan(
                                text: '3 Shelter Locations',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 106, 17, 122),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(
                                text: ' within 2 miles',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Icon(
                        Icons.info_outline,
                        size: 28.0,
                        color: Color.fromARGB(255, 120, 119, 119),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.zero,
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      // testing  for now
                      final isOpen = index % 2 == 0;

                      //testing for now
                      final services = ['Laundry', 'Support', 'Shower'];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Location $index',
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                      vertical: 4.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isOpen ? Colors.green : Colors.red,
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Text(
                                      isOpen ? 'OPEN' : 'CLOSED',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40.0),
                              const Row(
                                children: [
                                  Icon(Icons.directions_walk,
                                      color: Colors.black54),
                                  SizedBox(width: 8),
                                  Text(
                                    //will make dynamic soon
                                    '24 mins by walking (1.2 miles away)',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              const Row(
                                children: [
                                  Icon(Icons.timer, color: Colors.black54),
                                  SizedBox(width: 8),
                                  Text(
                                    //will make dynamic soon
                                    'Accept walk-in until 7:00 PM',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12.0),
                              // Services Tags
                              Wrap(
                                spacing: 8.0,
                                children: services.map((service) {
                                  return Chip(
                                    label: Text(
                                      service,
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                    side: BorderSide.none,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 1.0, horizontal: 2.0),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
