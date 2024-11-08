import 'package:allhelps/search_bar_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as lat_lng;

class HelpsPage extends StatefulWidget {
  const HelpsPage({super.key});

  @override
  State<HelpsPage> createState() => _HelpsPageState();
}

class _HelpsPageState extends State<HelpsPage> {
  double _sheetPosition = 0.5;
  final double _dragSensitivity = 600;

  List<String> chosenFilters = [];

  final Map<String, String> filter_images = {
    "Food": "lib/help_page_assets/food.png",
    "Support": "lib/help_page_assets/support.png",
    "Medical": "lib/help_page_assets/medicene.png",
    "Shelter": "lib/help_page_assets/shelter.png",
    "Resources": "lib/help_page_assets/resource.png"
  };

  final Map<String, List<String>> filters = {
    "Food": ["Food and Meals- Hot Meals", "Food bank"],
    "Support": [
      "Abuse/Stalking- locations",
      "Child care",
      "Donation Centers",
      "Financial Guidance & Management",
      "Foster care service"
    ],
    "Medical": [],
    "Shelter": [
      "Cooling station",
      "Housing",
      "Housing Assistance/Coordinated Entry",
      "Laundry",
      "Shelter",
      "Showers"
    ],
    "Resources": [
      "Bus ticket home",
      "Clothing",
      "Community Resources",
      "Coordinated Energy Assessment Sites",
      "Energy SHARE",
      "Families with Children",
      "Disability Housing Program",
      "Disability Services"
    ],
    "Other": []
  };

  @override
  Widget build(BuildContext context) {
    List<Widget> top_filters = [];
    String chosenFilter;

    filter_images.forEach((categoryName, filename) {
      top_filters.add(Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
            onPressed: () {
              setState(() {
                chosenFilter = categoryName;
                print(chosenFilter);
              });
            },
            child: Row(children: [
              Image.asset(
                filename,
                width: 20,
                height: 20,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                categoryName,
                style: const TextStyle(fontSize: 14),
              ),
            ]),
          )),
        ],
      ));
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: MediaQuery.of(context).size.height * 0.18,
        title: Column(
          children: [
            Row(
              children: [
                const Expanded(child: SearchBarWidget()),
                const SizedBox(
                  width: 10,
                ),
                Container(
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 89, 28, 211),
                        borderRadius: BorderRadius.circular(10)),
                    width: 0.15 * MediaQuery.of(context).size.width,
                    height: 0.065 * MediaQuery.of(context).size.height,
                    child: ListTile(
                      minLeadingWidth: 0,
                      minTileHeight: 0,
                      title: IconButton(
                        highlightColor: Colors.amber,
                        onPressed: () {},
                        icon: const Icon(
                          Icons.filter_alt_off_sharp,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: const Text(
                        'Filter',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: top_filters),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
      body: Stack(
        children: [
          // Map Layer
          FlutterMap(
            options: const MapOptions(
              initialCenter:
                  lat_lng.LatLng(36.1716, -115.1391), // Las Vegas, Nevada
              minZoom: 1,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
            ],
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
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.zero,
                        itemCount: 20,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.location_on,
                                      color: Colors.grey[700]),
                                  const SizedBox(width: 16.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Location $index',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 40.0),
                                      Text(
                                        'Description of location $index',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
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
        color: Colors.grey[300],
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

// class Filter extends StatelessWidget {
//   final String categoryName;
//   final String filename;
//   const Filter({super.key, required this.categoryName, required this.filename});

//   @override
//   Widget build(BuildContext context) {
//     return Row(children: [
//       Image.asset(
//         filename,
//         width: 20,
//         height: 20,
//       ),
//       const SizedBox(
//         width: 10,
//       ),
//       Text(
//         categoryName,
//         style: const TextStyle(fontSize: 14),
//       ),
//     ]);
//   }
// }
