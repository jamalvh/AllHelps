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

  List<List<int>> showTimeLimit = [[0, 0], [1, 7], [14, -1]];

  //this is not sorted in order of ascending dates
  //dates are in yyyy-mm-dd hh:mm:ss, no milisecond cus that's too much
  //year, month, day, hour, minute
  //using military time: 0-24, will be sorted through a function
  final List<Map<String, String>> alertsArray = [
    {
      "date": "2024-07-11 00:37:00",
      "title": "Free Houses",
      "description": "Giving away houses to homeless people",
      "type": "Event",
    },
    {
      "date": "2024-07-15 18:43:00",
      "title": "Free Apartments",
      "description": "Giving away apartments to homeless people",
      "type": "Safety",
    }
  ];

  //takes out the times out of each index to use in parcing our data
  //only used for comparison as of the moment
  final List<DateTime> sortedAlertsArrayTimes =  [];

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
  List<Map<String, String>> dateTimeSortArray(List<int> dateRange, List<Map<String, String>> alertsArray) {
    List<Map<String, String>> sortedArray = [];
     Map<String, String> temp;

    //sorts the dates
    for (int i = 0; i < alertsArray.length; i++) {
      //[lower, upper], date: yyyy-mm-dd hh:mm:ss 1234(year) 5(space) 67(month) 8(space) 9(10)(date) 11(space) (12)(13) (hour) 14 (colon) (15)(16) minutes, anymore than that is unneeded
      //so substring(9, 11) ("coincidence?! I think Not!")
      if (int.parse(alertsArray[i]["date"]!.substring(9, 11)) >= dateRange[0] && int.parse(alertsArray[i]["date"]!.substring(9, 11)) <= dateRange[1]) {
        sortedArray.add(alertsArray[i]);
      }
    }

    //makes sure the times in that date is in order, slowest method i can think of lol
    for (int curr = 0; curr < alertsArray.length-1; curr++) {
      for (int next = 1; next < alertsArray.length; next++) {
        //compare hours first then minutes
        if (
          int.parse(alertsArray[curr]["date"]!.substring(12, 14)) >= int.parse(alertsArray[next]["date"]!.substring(13, 14))
          ||
          (int.parse(alertsArray[curr]["date"]!.substring(12, 14)) == int.parse(alertsArray[next]["date"]!.substring(13, 14))
          &&
          int.parse(alertsArray[curr]["date"]!.substring(15, 17)) >= int.parse(alertsArray[next]["date"]!.substring(15, 17)))
          ) {
            temp = alertsArray[curr];
            alertsArray[curr] = alertsArray[next];
            alertsArray[next] = temp;
        } 
      }
    }
    return sortedArray;
  }

  List<Map<String, String>> today = []; 
  List<Map<String, String>> thisWeek = []; 
  List<Map<String, String>> pastEvents = []; 

  List<List<Map<String, String>>> dateFilteredAlerts = [];

  @override
  void initState() {
    super.initState();
    today = dateTimeSortArray([0, 0], alertsArray);
    thisWeek = dateTimeSortArray([1, 7], alertsArray);
    pastEvents = dateTimeSortArray([14, -1], alertsArray);
    dateFilteredAlerts = [today, thisWeek, pastEvents];
    filteredAlerts = alertsArray;
  }

  void updateFilters(List<bool> selections) {
    setState(() {
      selectedFilters = selections;
      if (selections[0]) {
        filteredAlerts = alertsArray;
      } else {
        filteredAlerts = alertsArray.where((alert) {
          if (selections[1] && alert["type"] == "Event") return true;
          if (selections[2] && alert["type"] == "Resources") return true;
          if (selections[3] && alert["type"] == "Safety") return true;
          return false;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    for (int i = 0; i < alertsArray.length; i++) {
      sortedAlertsArrayTimes.add(DateTime.parse(alertsArray[i]["date"]!));
    }

    int todayEvents = 0;
    int thisWeekEvents = 0;
    int pastWeeksEvents = 0;
    for (int i = 0; i > sortedAlertsArrayTimes.length; i++) {
      //parces the sorted alerts array, gives the lengths of time for which sections for what to display
      if (sortedAlertsArrayTimes[i].year == DateTime.now().year) {
        if (sortedAlertsArrayTimes[i].day - DateTime.now().day == 0) {
          todayEvents++;
        } else if (sortedAlertsArrayTimes[i].day - DateTime.now().day <= 7 && sortedAlertsArrayTimes[i].day - DateTime.now().day > 0 ) {
          thisWeekEvents++;
        } else if (sortedAlertsArrayTimes[i].day - DateTime.now().day <= -1 && sortedAlertsArrayTimes[i].day - DateTime.now().day >= -14 ) {
          pastWeeksEvents++;
        }
      }
    }

    List<int> eventQuantities = [todayEvents, thisWeekEvents, pastWeeksEvents];

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AlertSelector(
              onSelectionChanged: updateFilters,
            ),
            const SizedBox(height: 14),
            ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: 3,

              itemBuilder: (context, index) {
                return Column(
                children: [
                  Text(
                    dateName[index], 
                    style: const TextStyle(
                        color: Color(0xFF4D5166),
                        fontFamily: "NotoSans",
                        fontSize: 14,
                      ),
                    ),
                  ListView.builder(

                    shrinkWrap: true,
                    itemCount: eventQuantities[index],
                    itemBuilder: (BuildContext context, int itemIndex) {
                      
                      //var index is the listview we're in, dateName[index] gives the section we're in
                      //and section[index] should give the corresponding lists required for this, filtered[index].length should be the item count

                      //note to self that all the filters were in place when the data pulled from the backend was being sorted

                        return Alert(
                          //skips the items that have already been displayed, displays items that are in that range of time
                          alertBase: _convertToAlertBase(dateFilteredAlerts[index][itemIndex])
                        );
                    } 
                  )
                ]
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}