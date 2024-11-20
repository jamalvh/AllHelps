import 'package:allhelps/filter_model.dart';
import 'package:allhelps/help_page_filters.dart';
import 'package:allhelps/search_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as lat_lng;
import 'dart:convert';
import 'dart:io';
import 'locations.dart';


class HelpsPage extends StatefulWidget {
  const HelpsPage({super.key});

  @override
  State<HelpsPage> createState() => _HelpsPageState();
}

class _HelpsPageState extends State<HelpsPage> {
  double _sheetPosition = 0.5;
  final double _dragSensitivity = 600;

  // SearchModel searchModel = SearchModel(
  //     name: 'test',
  //     isOpen: true,
  //     location: const lat_lng.LatLng(42, 42),
  //     filters: [],
  //     timings: ''); //TODO: Real models

  SearchModel searchModel = SearchModel();

  FilterModel filterModel = FilterModel();

  final MapController _mapController = MapController();
  double curr_lat = 0;
  double curr_long = 0;



  List<LocationModel> locations = [];

    @override
    void initState() {
    super.initState();
    _loadLocations();
  }


  Future<void> _loadLocations() async {
    locations = await loadLocations(); 
    setState(() {}); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: MediaQuery.of(context).size.height * 0.18,
        title: const Filters(),
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
                // lat_lng.LatLng current_location = lat_lng.LatLng(
                //     snapshot.data!.latitude, snapshot.data!.longitude);

                curr_lat = snapshot.data != null ? snapshot.data!.latitude : 0;
                curr_long =snapshot.data != null ? snapshot.data!.longitude : 0;

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
                            userAgentPackageName: 'com.example.app',
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
                    : const CircularProgressIndicator();
              }),

          Positioned(
            top: 0.7 * MediaQuery.of(context).size.height,
            left: 0.05 * MediaQuery.of(context).size.width,
            child: FloatingActionButton(
              onPressed: () {
                _mapController.move(lat_lng.LatLng(curr_lat, curr_long),
                    13); // Default initial zoom of map is 13
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.near_me_rounded),
            ),
          ),

            DraggableScrollableSheet(
            initialChildSize: _sheetPosition,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return ColoredBox(
                color: Colors.white,
                child: Column(
                  children: [
                    Grabber(
                      onVerticalDragUpdate: (details) {
                        setState(() {
                          _sheetPosition -= details.delta.dy / _dragSensitivity;
                          _sheetPosition = _sheetPosition.clamp(0.2, 0.8);
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'We found ${locations.length} Shelter Locations Nearby',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.zero,
                        itemCount: locations.length,
                        itemBuilder: (context, index) {
                          final location = locations[index];
                          final isOpen = location.isOpen;
                          final services = ['Laundry', 'Support', 'Shower'];

                          final distance = LocationModel.calculateDistance(curr_lat, curr_long, location.coordinates.latitude, location.coordinates.longitude);
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        location.name,
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
                                  Row(
                                    children: [
                                      Icon(Icons.directions_walk, color: Colors.black54),
                                      SizedBox(width: 8),
                                      Text(
                                        //will make dynamic soon
                                        '24 Mins by walking (${distance.toStringAsFixed(1)} Miles Away)',
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
                                          style: const TextStyle(color: Colors.black),
                                        ),
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0)
                                        ),
                                        side: BorderSide.none,
                                        padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 2.0), 
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
        ],
      ),
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
        color: Colors.grey[100],
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            width: 32.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }
}
