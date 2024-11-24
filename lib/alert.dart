import 'package:flutter/material.dart';
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

  final List<String> dateName = ["Today", "This Week", "Last Week"];

  List<List<int>> showTimeLimit = [
    [0, 0],
    [1, 7],
    [14, -1]
  ];

  //dates are in yyyy-mm-dd hh:mm:ss
  //hours: 0-24
  final List<Map<String, String>> alertsArray = [
    {
      "date": "2024-11-20 00:37:00",
      "title": "Free Houses",
      "description": "Giving away houses to homeless people",
      "type": "Event",
    },
    {
      "date": "2024-11-27 18:43:00",
      "title": "Free Apartments",
      "description": "Giving away apartments to homeless people",
      "type": "Safety",
    },
    {
      "date": "2024-11-23 18:43:00",
      "title": "Free Food",
      "description": "Giving away food to homeless people",
      "type": "Safety",
    },
    {
      "date": "2024-11-21 18:43:00",
      "title": "Free Food",
      "description": "Giving away food to homeless people",
      "type": "Safety",
    },
    {
      "date": "2024-11-20 18:43:00",
      "title": "Free Food",
      "description": "Giving away food to homeless people",
      "type": "Safety",
    },
    {
      "date": "2024-11-19 18:43:00",
      "title": "Free Food",
      "description": "Giving away food to homeless people",
      "type": "Safety",
    },
    {
      "date": "2024-11-18 18:43:00",
      "title": "Free Food",
      "description": "Giving away food to homeless people",
      "type": "Safety",
    },
    {
      "date": "2024-11-17 18:43:00",
      "title": "Free Food",
      "description": "Giving away food to homeless people",
      "type": "Safety",
    },
    {
      "date": "2024-11-16 18:43:00",
      "title": "Free Food",
      "description": "Giving away food to homeless people",
      "type": "Safety",
    },
    {
      "date": "2024-11-15 18:43:00",
      "title": "Free Food",
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
    Map<String, String> temp;
    int currHour;
    int nextHour;
    int currMinute;
    int nextMinute;
    int currDate;

    for (int i = 0; i < alertsArray.length; i++) {
      //[lowerBound, upperBound]
      //date indexes: yyyy-mm-dd hh:mm:ss 1234(year) 5(-) 67(month) 8(-) 9(10)(date) 11(space) (12)(13) (hour) 14 (colon) (15)(16) minutes, anymore than that is unneeded
      currDate = int.parse(alertsArray[i]["date"]!.substring(8, 10));

      print([alertsArray[i]["date"]!.substring(8, 10), "two"]);
      if (currDate >= dateRange[0] && currDate <= dateRange[1]) {
        sortedArray.add(alertsArray[i]);
      }
      print(i);
    }
    // if (sortedArray.isEmpty) {
    //   sortedArray = [
    //     {
    //       "date": "9999-99-99 00:00:00",
    //       "title": "Nothing Yet",
    //       "description": "Unavailable",
    //       "type": "Event",
    //     }
    //   ];
    //   return sortedArray;
    // }
    for (int curr = 0; curr < sortedArray.length - 1; curr++) {
      for (int next = 1; next < sortedArray.length; next++) {
        currHour = int.parse(sortedArray[curr]["date"]!.substring(11, 13));
        nextHour = int.parse(sortedArray[next]["date"]!.substring(11, 13));
        currMinute = int.parse(sortedArray[curr]["date"]!.substring(14, 16));
        nextMinute = int.parse(sortedArray[next]["date"]!.substring(11, 13));

        if (currHour <= nextHour ||
            (currHour == nextHour && currMinute <= nextMinute)) {
          //this is the issue, temp is being bad, and idk what its doing
          //error is trying to access curr from the array, its not allowing access for some reason
          temp = sortedArray[curr];
          sortedArray[curr] = sortedArray[next];
          sortedArray[next] = temp;
        }
      }
    }
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

      // Then update the date-filtered lists with the type-filtered results
      today = dateTimeSortArray(
          [DateTime.now().day, DateTime.now().day], typeFilteredAlerts);
      thisWeek = dateTimeSortArray(
          [DateTime.now().day + 1, DateTime.now().day + 7], typeFilteredAlerts);
      pastEvents = dateTimeSortArray(
          [DateTime.now().day - 14, DateTime.now().day - 1],
          typeFilteredAlerts);
      dateFilteredAlerts = [today, thisWeek, pastEvents];

      // Update filteredAlerts for compatibility
      filteredAlerts = typeFilteredAlerts;
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize with all alerts
    today = dateTimeSortArray(
        [DateTime.now().day, DateTime.now().day], alertsArray);
    thisWeek = dateTimeSortArray(
        [DateTime.now().day + 1, DateTime.now().day + 7], alertsArray);
    pastEvents = dateTimeSortArray(
        [DateTime.now().day - 14, DateTime.now().day - 1], alertsArray);
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
                              color: Color(0xFF4D5166),
                              fontFamily: "NotoSans",
                              fontSize: 14,
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
            ),
          ),
        ],
      ),
    );
  }
}
