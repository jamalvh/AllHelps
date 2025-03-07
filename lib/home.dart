import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:allhelps/alert_base_class.dart';
import 'package:allhelps/filter_model.dart';
import 'package:allhelps/search_model.dart';
import 'package:allhelps/locations.dart';
import 'package:allhelps/search_bar_page.dart';
import 'package:allhelps/search_options.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  final Function(int, {String? filter}) onIndexChanged;

  const MyHomePage({super.key, required this.onIndexChanged});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

// No changes needed in _MyHomePageState
class _MyHomePageState extends State<MyHomePage> {
  FilterModel filterModel = FilterModel();
  SearchModel searchModel = SearchModel();
  List<LocationModel> locations = [];

  void activateSearch() {
    if (mounted) {
      setState(() {
        filterModel.initializeSearches();
        searchModel.showResults = true;
      });
    }
  }

  void closeSearch() async {
    locations = await loadLocations();
    if (mounted) {
      setState(() {
        filterModel.setChosenFilter("");
        searchModel.showResults = false;
      });
    }
  }

  void updateSearch(String value) {
    if (mounted) {
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
  }

  void updateResults(String topFilter) {
    if (mounted) {
      setState(() {
        locations.removeWhere((location) {
          return !location.services.contains(topFilter);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEDF4FF),
              Color(0xFFc8dcf8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              const Header(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SearchBarWidget(
                  activateSearch: activateSearch,
                  closeSearch: closeSearch,
                  updateSearch: updateSearch,
                  updateResults: updateResults,
                ),
              ),
              if (searchModel.showResults)
                SearchOptions(
                  searchModel: searchModel,
                  searches: filterModel.searches,
                  updateResults: updateResults,
                  onIndexChanged: widget.onIndexChanged,
                ),
              const SizedBox(height: 40),
              HelpsRow(onIndexChanged: widget.onIndexChanged),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  widget.onIndexChanged(2);
                },
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('alerts')
                      .orderBy('date', descending: true)
                      .limit(1)
                      .snapshots(),
                  builder: (context, snapshot) {
                    // If there's an error or no data, return an empty container
                    if (snapshot.hasError) {
                      return const SizedBox.shrink();
                    }

                    // Show loading indicator while fetching
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // No alerts found
                    if (snapshot.data!.docs.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    // Get the most recent alert
                    var alertData = snapshot.data!.docs.first.data()
                        as Map<String, dynamic>;

                    // Convert alert type
                    AlertType alertType;
                    switch (alertData['type']) {
                      case 'Event':
                        alertType = AlertType.Event;
                        break;
                      case 'Safety':
                        alertType = AlertType.Safety;
                        break;
                      case 'Resources':
                        alertType = AlertType.Resources;
                        break;
                      default:
                        alertType = AlertType.Welcome;
                    }

                    return GestureDetector(
                      onTap: () {
                        widget.onIndexChanged(2);
                      },
                      child: Alert(
                        alertBase: AlertBase(
                          type: alertType,
                          header: alertData['title'] ?? 'Recent Alert',
                          message: alertData['description'] ??
                              'No description available',
                          date: alertData['date'].toDate(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              EmergencyRow(onIndexChanged: widget.onIndexChanged),
              const SizedBox(height: 200),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget for header remains unchanged
class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // Header
      Container(
        height: 213,
        decoration: const BoxDecoration(
            color: Color(0xFF6359CA),
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(26),
                bottomRight: Radius.circular(26))),
        alignment: Alignment.center,
      ),
      // Image
      Positioned(
        top: 0,
        left: 20,
        child: Center(
          child: Image.asset(
            'assets/images/header_image.png',
            height: 180,
            fit: BoxFit.cover,
          ),
        ),
      ),
    ]);
  }
}

// Widget for Helps Row
class HelpsRow extends StatelessWidget {
  final Function(int, {String? filter}) onIndexChanged;

  const HelpsRow({super.key, required this.onIndexChanged});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            alignment: Alignment.centerLeft,
            child: const Text(
              "We are here to help",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.left,
            ),
          )),
      const SizedBox(height: 10),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Home Page is index 0, Helps Page is index 1
              HelpsButton(
                  color1: const Color(0xFFE57701),
                  color2: const Color(0xFFFFB15E),
                  text: "Searching for Food",
                  imageURL: "assets/images/helps_food_icon.png",
                  onTap: () {
                    onIndexChanged(1, filter: "Food"); // Switch to HelpsPage
                  }),
              HelpsButton(
                  color1: const Color(0xFF50714A),
                  color2: const Color(0xFF5BB139),
                  text: "Looking for Shelter",
                  imageURL: "assets/images/helps_shelter_icon.png",
                  onTap: () {
                    onIndexChanged(1, filter: "Shelter");
                  }),
              HelpsButton(
                  color1: const Color(0xFF4F77C0),
                  color2: const Color(0xFF86A8FE),
                  text: "Get Medical Connect",
                  imageURL: "assets/images/helps_medicine_icon.png",
                  onTap: () {
                    onIndexChanged(1, filter: "Medical");
                  })
            ],
          ))
    ]);
  }
}

// Widget for Helps Button remains unchanged
class HelpsButton extends StatelessWidget {
  final Color color1;
  final Color color2;
  final String text;
  final String imageURL;
  final VoidCallback? onTap; // No change needed

  const HelpsButton({
    super.key,
    required this.color1,
    required this.color2,
    required this.text,
    required this.imageURL,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Material(
        child: Ink(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                color1,
                color2,
              ],
              center: Alignment.bottomRight,
              radius: 1.2,
            ),
          ),
          // Ripple effect
          child: InkWell(
            onTap: onTap,
            splashColor: color2.withOpacity(1),
            highlightColor: color2.withOpacity(.5),
            child: SizedBox(
              width: 116,
              height: 144,
              child: Stack(
                children: [
                  // Icon
                  Positioned(
                    top: 12,
                    left: 12,
                    child: SizedBox(
                      height: 46,
                      width: 46,
                      child: Image.asset(
                        imageURL,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Text caption
                  Positioned(
                    bottom: 20,
                    left: 12,
                    right: 12,
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget for Emergency Row
class EmergencyRow extends StatelessWidget {
  final Function(int, {String? filter}) onIndexChanged;

  const EmergencyRow({super.key, required this.onIndexChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            alignment: Alignment.centerLeft,
            child: const Text(
              "Need Emergency Help?",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.left,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                EmergencyButton(
                    title: "24/7 Hotline",
                    text: "Reach out anytime for support",
                    imageURL: "assets/images/24-hours-line.png",
                    onTap: () async {
                      // 988
                      launchUrl(Uri.parse('tel:988'));
                    }),
                EmergencyButton(
                    title: "Local outreach team",
                    text: "Connect with your local agency",
                    imageURL: "assets/images/phone-fill.png",
                    onTap: () {
                      // 211
                      launchUrl(Uri.parse('tel:211'));
                    }),
              ],
            ))
      ],
    );
  }
}

// Widget for Emergency Buttons remains unchanged
class EmergencyButton extends StatelessWidget {
  final String title;
  final String text;
  final String imageURL;
  final VoidCallback? onTap; // No change needed

  const EmergencyButton({
    super.key,
    required this.title,
    required this.text,
    required this.imageURL,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Material(
          child: Ink(
            color: Colors.white,
            child: InkWell(
              onTap: onTap,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(14.0), // Uniform radius
                ),
                child: SizedBox(
                  width: 180,
                  height: 120,
                  child: Stack(
                    children: [
                      // Icon
                      Positioned(
                        top: 12,
                        left: 12,
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: Image.asset(
                            imageURL,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Text caption
                      Positioned(
                        bottom: 40,
                        left: 12,
                        right: 12,
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 12,
                        right: 12,
                        child: Text(
                          text,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}

// Widget for GuideButton
class GuideButton extends StatelessWidget {
  final Function(int, {String? filter}) onIndexChanged;

  const GuideButton({super.key, required this.onIndexChanged});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Material(
          child: Ink(
            color: Colors.white,
            child: InkWell(
              onTap: () {
                onIndexChanged(1); // Switch to HelpsPage
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(14.0), // Uniform radius
                ),
                child: SizedBox(
                  width: 365,
                  height: 80,
                  child: Stack(
                    children: [
                      // Icon
                      Positioned(
                        top: 20,
                        right: 12,
                        child: SizedBox(
                          height: 35,
                          width: 35,
                          child: Image.asset(
                            "assets/images/arrow-right-s-line.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Text caption
                      const Positioned(
                        top: 20,
                        left: 12,
                        right: 12,
                        child: Text(
                          "Guide you to the right services faster",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: 20,
                        left: 12,
                        right: 12,
                        child: Text(
                          "Please choose your current situation",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
