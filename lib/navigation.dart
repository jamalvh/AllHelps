import 'package:flutter/material.dart';

class NavigationBar extends StatelessWidget {
  const NavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 40),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search, size: 40),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.my_library_books_sharp, size: 40),
          label: 'Library',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, size: 40),
          label: 'Profile',
        ),
      ],
    );
  }
}
