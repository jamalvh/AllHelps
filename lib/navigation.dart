import 'package:flutter/material.dart';

class MyNavigationBar extends StatelessWidget {
  final int currentPageIndex;
  final ValueChanged<int> onItemTapped;

  const MyNavigationBar({
    super.key,
    required this.currentPageIndex,
    required this.onItemTapped,
    });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/Home.png',
            height: 40),
            label: 'Home'
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/Helps.png',
            height: 40),
          label: 'Helps'
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/Alert.png',
            height: 40),
            label: 'Alert'
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/My.png',
            height: 40),
            label: 'My'
        ),
      ],
      currentIndex: currentPageIndex,
      onTap: onItemTapped,
    );
  }
}
