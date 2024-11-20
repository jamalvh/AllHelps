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
  List<Map<String, dynamic>> filteredAlerts = [];
  List<bool> selectedFilters = [false, false, false, false];

  final List<Map<String, dynamic>> alertsArray = [
    {
      "date": "2024-07-11",
      "title": "Free Houses",
      "description": "Giving away houses to homeless people",
      "type": "Event",
    },
    {
      "date": "2024-07-11",
      "title": "Free Apartments",
      "description": "Giving away apartments to homeless people",
      "type": "Safety",
    }
  ];

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

  @override
  void initState() {
    super.initState();
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
            Expanded(
              child: ListView.builder(
                itemCount: filteredAlerts.length,
                itemBuilder: (context, index) {
                  return Alert(
                      alertBase: _convertToAlertBase(filteredAlerts[index]));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}