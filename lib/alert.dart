import 'package:flutter/material.dart';

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
<<<<<<< Updated upstream
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
=======
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
  static const double size = 8.0; // Changed from 10.0 to 8.0
=======
  static const double size = 10.0;
>>>>>>> Stashed changes

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
<<<<<<< Updated upstream
        padding: const EdgeInsets.symmetric(vertical: 13.5),
        child: Row(
          children: [
            CustomIconButton(
              icon: Icons.forum,
=======
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            CustomIconButton(
              icon: Icons.all_inclusive,
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
              icon: Icons.favorite,
=======
              icon: Icons.library_books,
>>>>>>> Stashed changes
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
    );
  }
}

class AlertPage extends StatelessWidget {
  const AlertPage({super.key});

  final Color mainColor = const Color(0xFF6359ca);
  final bool isEmergency = true; //placeholder
<<<<<<< Updated upstream
  //this will be equal to the amount of items that will be shown: placeholder number rn
  final int itemCount = 5;
=======
  final Color welcomeText = const Color(0xFF3d3a8d);
  final Color welcomeBG = const Color(0xFFedf4ff);
>>>>>>> Stashed changes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< Updated upstream
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(110.0),
        child: Container(
          decoration: BoxDecoration(
            color: mainColor,
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 50.0, bottom: 10.0),
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
        child: 
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          
          children: [
            //padding 
            
=======
      appBar: AppBar(
        leading: BackButton(onPressed: () {
          Navigator.pop(context);
        }),
        centerTitle: true,
        title: const Text('Alerts', style: TextStyle(color: Colors.white)),
        backgroundColor: mainColor,
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 100.0,
      ),
      body: Center(
        child: Column(
          children: [
>>>>>>> Stashed changes
            AlertSelector(
              onSelectionChanged: (selections) {
                // Handle the selection changes here
                print('Selected buttons: $selections');
              },
            ),
<<<<<<< Updated upstream


            Expanded(
              child: ListView.builder(
                itemCount: itemCount,
                itemBuilder: (BuildContext context, int index) {
                  return AlertItem(isEmergency: isEmergency, alertTitle: "title placeholder", alertContent: "placeholde",);
                },

=======
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: welcomeBG,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.blue.shade200,
                    width: 1.4,
                  ),
                ),
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
                    SizedBox(height: 10),
                    Text(
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
            Expanded(
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    color: (isEmergency) ? Colors.orange : Colors.cyan,
                    child: const Text("placeholder"),
                  );
                },
>>>>>>> Stashed changes
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlertItem extends StatelessWidget {
  const AlertItem({
    super.key,
    required this.isEmergency,
    required this.alertContent,
    required this.alertTitle
  });

  final bool isEmergency;
  final String alertContent;
  final String alertTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: (isEmergency) ? Colors.orange : Colors.cyan,
        borderRadius: const BorderRadius.all(Radius.circular(10.0))
      ),
      padding: const EdgeInsets.all(100.0),
      alignment: Alignment.bottomLeft,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10), //placeholder value
            child:Text(
              alertTitle,
              //style: const TextStyle()
            )
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              alertContent
            )
          )
        ]
    )
    );
  }
}

