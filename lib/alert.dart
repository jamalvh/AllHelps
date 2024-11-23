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
      "date": "2024-11-20 00:37:00",
      "title": "Free Houses",
      "description": "Giving away houses to homeless people",
      "type": "Event",
    },
    {
      "date": "2024-11-25 18:43:00",
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

    //sorts the dates, no errors, 
    for (int i = 0; i < alertsArray.length; i++) {
      //[lower, upper], date: yyyy-mm-dd hh:mm:ss 1234(year) 5(space) 67(month) 8(space) 9(10)(date) 11(space) (12)(13) (hour) 14 (colon) (15)(16) minutes, anymore than that is unneeded
      //so substring(9, 11) ("coincidence?! I think Not!")
      if (int.parse(alertsArray[i]["date"]!.substring(9, 11)) >= dateRange[0] && int.parse(alertsArray[i]["date"]!.substring(9, 11)) <= dateRange[1]) {
        sortedArray.add(alertsArray[i]);
      }
    }

    //makes sure the times in that date is in order, slowest method i can think of lol
    for (int curr = 0; curr < sortedArray.length-1; curr++) {
      for (int next = 1; next < sortedArray.length; next++) {
        //compare hours first then minutes if hours are the same
        //has a value but for some reason swaping is messing up, checking is raising an error for some reason

        //why the hell is this comparing everything in the string to everything in the string?? 

        // error is caused by this, for some reason, parcing this string isn't working correctly for some reason, i can't parse it for some reason
        //hour is the first, minute is the second
        if (
          int.parse(sortedArray[curr]["date"]!.substring(11, 13)) >= int.parse(sortedArray[next]["date"]!.substring(11, 13))
          ||
          (int.parse(sortedArray[curr]["date"]!.substring(11, 13)) == int.parse(sortedArray[next]["date"]!.substring(11, 13))
          &&
          int.parse(sortedArray[curr]["date"]!.substring(14, 16)) >= int.parse(sortedArray[next]["date"]!.substring(14, 16)))
          ) {
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
    print(dateFilteredAlerts[0][0]);

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

                      //for some reason this part of the code isn't running, prob cus the eventQuantities, check that next
                      print(dateFilteredAlerts[index][itemIndex]);

                      //var index is the listview we're in, dateName[index] gives the section we're in
                      //and section[index] should give the corresponding lists required for this, filtered[index].length should be the item count
                      //if the thing exists, return this, else return a default alert
                      if (dateFilteredAlerts[index][itemIndex] != null) {
                        return Alert(
                          alertBase: _convertToAlertBase(dateFilteredAlerts[index][itemIndex])
                          //alertBase: _convertToAlertBase(filteredAlerts[itemIndex])
                        
                        );
                      } else { 
                        //if there is no event for that day, this is not used due to the num times this function gets run, figure a way out to put a default thing in or get rid of it entirely
                        return Alert(
                          alertBase: _convertToAlertBase({
                            "date": "Unavailable",
                            "title": "Nothing Yet",
                            "description": " ",
                            "type": "Event",
                          }));
                          //alertBase: _convertToAlertBase(filteredAlerts[itemIndex])
                      }
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