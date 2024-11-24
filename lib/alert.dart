import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'alert_base_class.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isSelected;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFFCBDFFF) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13.3),
          side: BorderSide(
            color:
                isSelected ? const Color(0xFF9BAEF1) : const Color(0xFFDCDCE0),
            width: 1.4,
          ),
        ),
      ),
      icon: Icon(
        icon,
        size: 20,
        color: const Color(0xFF6359CA),
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF3D3A8D) : const Color(0xFF4D5166),
        ),
      ),
    );
  }
}

class AlertSelector extends StatefulWidget {
  final Function(List<bool>) onSelectionChanged;

  const AlertSelector({
    super.key,
    required this.onSelectionChanged,
  });

  @override
  State<AlertSelector> createState() => _AlertSelectorState();
}

class _AlertSelectorState extends State<AlertSelector> {
  int selectedIndex = 0; // 0 = All, 1 = Event, 2 = Resources, 3 = Safety

  void selectButton(int index) {
    setState(() {
      selectedIndex = index;
      List<bool> selections = List.filled(4, false);
      selections[index] = true;
      widget.onSelectionChanged(selections);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13.5, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconButton(
                  icon: Icons.forum,
                  label: 'All',
                  isSelected: selectedIndex == 0,
                  onPressed: () => selectButton(0),
                ),
                const SizedBox(width: 8),
                CustomIconButton(
                  icon: Icons.event,
                  label: 'Event',
                  isSelected: selectedIndex == 1,
                  onPressed: () => selectButton(1),
                ),
                const SizedBox(width: 8),
                CustomIconButton(
                  icon: Icons.favorite,
                  label: 'Resources',
                  isSelected: selectedIndex == 2,
                  onPressed: () => selectButton(2),
                ),
                const SizedBox(width: 8),
                CustomIconButton(
                  icon: Icons.security,
                  label: 'Safety',
                  isSelected: selectedIndex == 3,
                  onPressed: () => selectButton(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  List<Map<String, String>> filteredAlerts = [];
  List<bool> selectedFilters = [false, false, false, false];

  final List<String> dateName = ["TODAY", "THIS WEEK", "LAST WEEK"];

  List<List<int>> showTimeLimit = [
    [0, 0],
    [1, 7],
    [14, -1]
  ];

  //dates are in yyyy-mm-dd hh:mm:ss
  //hours: 0-24
  final List<Map<String, String>> alertsArray = [
    {
      "date": "2024-11-24 00:37:00",
      "title": "Free Houses 11/24/24",
      "description": "Giving away houses to homeless people",
      "type": "Event",
    },
    {
      "date": "2024-11-27 18:43:00",
      "title": "Free Apartments 11/27/24",
      "description": "Giving away apartments to homeless people",
      "type": "Safety",
    },
    {
      "date": "2024-11-23 18:43:00",
      "title": "Free Food 11/23/24",
      "description": "Giving away food to homeless people",
      "type": "Safety",
    },
    {
      "date": "2024-11-21 18:43:00",
      "title": "Free Food 11/21/24",
      "description": "Giving away food to homeless people",
      "type": "Safety",
    },
    {
      "date": "2024-11-20 18:43:00",
      "title": "Free Food 11/20/24",
      "description": "Giving away food to homeless people",
      "type": "Safety",
    },
    {
      "date": "2024-11-19 18:43:00",
      "title": "Free Food 11/19/24",
      "description": "Giving away food to homeless people",
      "type": "Safety",
    },
    {
      "date": "2024-11-18 18:43:00",
      "title": "Free Food 11/18/24",
      "description": "Giving away food to homeless people",
      "type": "Safety",
    },
    {
      "date": "2024-11-17 18:43:00",
      "title": "Free Food 11/17/24",
      "description": "Giving away food to homeless people",
      "type": "Safety",
    },
    {
      "date": "2024-11-16 18:43:00",
      "title": "Free Food 11/16/24",
      "description": "Giving away food to homeless people",
      "type": "Safety",
    },
    {
      "date": "2024-11-15 18:43:00",
      "title": "Free Food 11/15/24",
      "description": "Giving away food to homeless people",
      "type": "Safety",
    },
  ];

  //takes out the times out of each index to use in parcing our data
  //only used for comparison as of the moment
  final List<DateTime> sortedAlertsArrayTimes = [];

  AlertType _getAlertType(String type) {
    switch (type) {
      case "Event":
        return AlertType.Event;
      case "Safety":
        return AlertType.Safety;
      case "Resources":
        return AlertType.Resources;
      default:
        return AlertType.Welcome;
    }
  }

  AlertBase _convertToAlertBase(Map<String, dynamic> alert) {
    return AlertBase(
      type: _getAlertType(alert["type"]),
      header: alert["title"],
      message: alert["description"],
      date: DateTime.parse(alert["date"]),
    );
  }

  //sorts arrays in each date so that each date is in chronological order w/ respec to time in the date range
  List<Map<String, String>> dateTimeSortArray(
      List<int> dateRange, List<Map<String, String>> alertsArray) {
    List<Map<String, String>> sortedArray = [];
    DateTime now = DateTime.now();

    // Create date at start of today (midnight) for consistent comparison
    DateTime today = DateTime(now.year, now.month, now.day);

    // Filter alerts for the given date range
    for (var alert in alertsArray) {
      DateTime alertDate = DateTime.parse(alert["date"]!);
      // Normalize alert date to start of day for consistent comparison
      alertDate = DateTime(alertDate.year, alertDate.month, alertDate.day);

      // Calculate days difference
      int daysDifference = alertDate.difference(today).inDays;

      // Today
      if (dateRange[0] == 0 && dateRange[1] == 0) {
        if (daysDifference == 0) {
          sortedArray.add(alert);
        }
      }
      // This Week (next 7 days)
      else if (dateRange[0] == 1 && dateRange[1] == 7) {
        if (daysDifference > 0 && daysDifference <= 7) {
          sortedArray.add(alert);
        }
      }
      // Last Week (past 7 days)
      else if (dateRange[0] == -7 && dateRange[1] == -1) {
        if (daysDifference < 0 && daysDifference >= -7) {
          sortedArray.add(alert);
        }
      }
    }

    // Sort the filtered alerts by date (newest first)
    sortedArray.sort((a, b) {
      DateTime dateA = DateTime.parse(a["date"]!);
      DateTime dateB = DateTime.parse(b["date"]!);
      return dateB.compareTo(dateA);
    });

    return sortedArray;
  }

  List<Map<String, String>> today = [];
  List<Map<String, String>> thisWeek = [];
  List<Map<String, String>> pastEvents = [];

  List<List<Map<String, String>>> dateFilteredAlerts = [];
  List<int> eventQuantities = [];

  void updateFilters(List<bool> selections) {
    setState(() {
      selectedFilters = selections;
      // First filter by type
      List<Map<String, String>> typeFilteredAlerts;
      if (selections[0]) {
        typeFilteredAlerts = alertsArray;
      } else {
        typeFilteredAlerts = alertsArray.where((alert) {
          if (selections[1] && alert["type"] == "Event") return true;
          if (selections[2] && alert["type"] == "Resources") return true;
          if (selections[3] && alert["type"] == "Safety") return true;
          return false;
        }).toList();
      }

      // Then update the date-filtered lists
      today = dateTimeSortArray([0, 0], typeFilteredAlerts); // Today only
      thisWeek = dateTimeSortArray([1, 7], typeFilteredAlerts); // Next 7 days
      pastEvents =
          dateTimeSortArray([-7, -1], typeFilteredAlerts); // Last 7 days
      dateFilteredAlerts = [today, thisWeek, pastEvents];

      // Update filteredAlerts for compatibility
      filteredAlerts = typeFilteredAlerts;
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize with all alerts
    today = dateTimeSortArray([0, 0], alertsArray); // Today only
    thisWeek = dateTimeSortArray([1, 7], alertsArray); // Next 7 days
    pastEvents = dateTimeSortArray([-7, -1], alertsArray); // Last 7 days
    dateFilteredAlerts = [today, thisWeek, pastEvents];

    filteredAlerts = alertsArray;
    selectedFilters[0] = true; // Set "All" as initially selected
  }

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < alertsArray.length; i++) {
      sortedAlertsArrayTimes.add(DateTime.parse(alertsArray[i]["date"]!));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF6359CA),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0, bottom: 10.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 0,
                    child: BackButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Alerts',
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
      body: Column(
        children: [
          AlertSelector(
            onSelectionChanged: updateFilters,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  Alert(
                    alertBase: AlertBase(
                      type: AlertType.Welcome,
                      header: "Welcome to our platform!",
                      message:
                          "Missed a notification from us? No worries. They'll be right here waiting for you for up to 14 days.",
                      date: DateTime.now(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...List.generate(3, (index) {
                    if (dateFilteredAlerts[index].isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            dateName[index],
                            style: const TextStyle(
                              color: Color(0xFF4d5166),
                              fontFamily: "NotoSans",
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...dateFilteredAlerts[index]
                            .asMap()
                            .entries
                            .map((entry) {
                          final itemIndex = entry.key;
                          final alert = entry.value;
                          return Column(
                            children: [
                              Alert(alertBase: _convertToAlertBase(alert)),
                              if (itemIndex <
                                  dateFilteredAlerts[index].length - 1)
                                const SizedBox(height: 10),
                            ],
                          );
                        }).toList(),
                        const SizedBox(height: 10),
                      ],
                    );
                  }),
                ],
              ),
=======

class AlertPage extends StatefulWidget {
  AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Alerts page'),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
              child: Text('Go to Home Page'),
>>>>>>> main
            ),
          ),
        ],
      ),
<<<<<<< HEAD
    );
  }
}
=======
      
    );
  }
}
>>>>>>> main
