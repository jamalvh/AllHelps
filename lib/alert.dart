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
  List<bool> selectedButtons = [false, false, false, false];
  bool allSelected = false;

  void toggleAll() {
    setState(() {
      allSelected = !allSelected;
      selectedButtons = List.filled(4, allSelected);
      widget.onSelectionChanged(selectedButtons);
    });
  }

  void toggleButton(int index) {
    setState(() {
      selectedButtons[index] = !selectedButtons[index];
      if (!selectedButtons[index]) {
        allSelected = false;
      } else if (selectedButtons.every((element) => element)) {
        allSelected = true;
      }
      widget.onSelectionChanged(selectedButtons);
    });
  }

  static const double size = 8.0; // Changed from 10.0 to 8.0

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
                  isSelected: allSelected,
                  onPressed: toggleAll,
                ),
                const SizedBox(width: size),
                CustomIconButton(
                  icon: Icons.event,
                  label: 'Event',
                  isSelected: selectedButtons[1],
                  onPressed: () => toggleButton(1),
                ),
                const SizedBox(width: size),
                CustomIconButton(
                  icon: Icons.favorite,
                  label: 'Resources',
                  isSelected: selectedButtons[2],
                  onPressed: () => toggleButton(2),
                ),
                const SizedBox(width: size),
                CustomIconButton(
                  icon: Icons.security,
                  label: 'Safety',
                  isSelected: selectedButtons[3],
                  onPressed: () => toggleButton(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AlertPage extends StatelessWidget {
  const AlertPage({super.key});

  final Color mainColor = const Color(0xFF6359ca);
  final bool isEmergency = true; // Placeholder
  final int itemCount = 5;
  final Color welcomeText = const Color(0xFF3d3a8d);
  final Color welcomeBG = const Color.fromRGBO(237, 244, 255, 1);
  final Color welcomeBorder = const Color.fromRGBO(220, 220, 224, 1);
  final int datesShown = 14;

  @override
  Widget build(BuildContext context) {

    final List<String> dateName = ["Today", "This Week", "Last Week"];

    //the json backend of the array
    //this will be sorted by date, starting with more recent to most in the future
    final List<Map<String, dynamic>> sortedAlertsArray = [
      {
        //mmddyy: month, date, year
        "Date": DateTime.now().day,
        "Title": "free houses",
        "Description": "giving away houses to homeless people",
        "Type": "Emergency"
      },
      {
        "Date": DateTime.now().day + 2,
        "Title": "free apartments",
        "Description": "giving away apartments to homeless people",
        "Type": "Emergency"
      }
    ];

    //parse into each individual ones to be put through days, week, and next week
    int todayEvents = 0;
    int thisWeekEvents = 0;
    int nextWeekEvents = 0;

    for (int i = 0; i > sortedAlertsArray.length; i++) {
      if (sortedAlertsArray[i]["Date"] == DateTime.now().day) {
        todayEvents++;
      } else if (sortedAlertsArray[i]["Date"] >= DateTime.now().day && sortedAlertsArray[i]["Date"] <= DateTime.now().day + 7) {
        thisWeekEvents++;
      } else if (sortedAlertsArray[i]["Date"] == DateTime.now().day && sortedAlertsArray[i]["Date"] <= DateTime.now().day + 14) {
        nextWeekEvents++;
      }
    }
    

    List<int> eventQuantities = [todayEvents, thisWeekEvents, nextWeekEvents];

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
                  Alert(
                      alertBase: AlertBase("Event", "Clean up today",
                          "Gonna do some cleaning up today", DateTime.now())),
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
              onSelectionChanged: (selections) {
                print('Selected buttons: $selections');
              },
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: welcomeBG,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: welcomeBorder,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to the Alerts Board!',
                      style: TextStyle(
                        color: welcomeText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Missed a notification from us? No worries. They\'ll be right here waiting for you and for up to 14 days.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
              //this listener class makes it so that we should be able to add new alerts in the back end
              ListView.builder(
                shrinkWrap: true,
                itemCount: 3,
                //itembuilder that shows each date section
                itemBuilder: (BuildContext context, int dateindex) {
                  return Column(
                  
                    children: [
                      Text(
                        dateName[dateindex], 
                        style: const TextStyle(
                            color: Color(0xFF4D5166),
                            fontFamily: "NotoSans",
                            fontSize: 14,
                          ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: eventQuantities[dateindex], //placeholder value
                        //itemblder that shows each alert item in each date
                        itemBuilder: (BuildContext context, int itemindex) {

                          int itemsInQuantitiesList = 0;

                          for (int i = 0; i < eventQuantities.length && i < dateindex; i++) {
                            itemsInQuantitiesList = itemsInQuantitiesList + eventQuantities[i];
                          }
                          return Alert(
                            alertBase: AlertBase(
                              sortedAlertsArray[itemsInQuantitiesList]["Type"], 
                              sortedAlertsArray[itemsInQuantitiesList]["Title"], 
                              sortedAlertsArray[itemsInQuantitiesList]["Description"], 
                              sortedAlertsArray[itemsInQuantitiesList]["Date"]
                            )
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