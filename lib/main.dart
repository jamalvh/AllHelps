import 'package:flutter/material.dart';
import 'package:allhelps/alert.dart';
import 'package:allhelps/helps.dart';
import 'package:allhelps/home.dart';
import 'package:allhelps/my.dart';

int selectedIndex = 0;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<Widget> pages = [
    MyHomePage(),
    HelpsPage(),
    AlertPage(),
    MyPage(),
  ];

  final List<NavigationDestination> destinations = [
    NavigationDestination(
      icon: Center(
        child: Image.asset('assets/images/Home.png', height: 40),
      ),
      selectedIcon: Center(
        child: Image.asset('assets/images/Home_selected.png', height: 40),
      ),
      label: '',
    ),
    NavigationDestination(
      icon: Center(
        child: Image.asset('assets/images/Helps.png', height: 40),
      ),
      selectedIcon: Center(
        child: Image.asset('assets/images/Helps_selected.png', height: 40),
      ),
      label: '',
    ),
    NavigationDestination(
      icon: Center(
        child: Image.asset('assets/images/Alert.png', height: 40),
      ),
      selectedIcon: Center(
        child: Image.asset('assets/images/Alert_selected.png', height: 40),
      ),
      label: '',
    ),
    NavigationDestination(
      icon: Center(
        child: Image.asset('assets/images/My.png', height: 40),
      ),
      selectedIcon: Center(
        child: Image.asset('assets/images/My_selected.png', height: 40),
      ),
      label: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Background color for app
      ),
      home: Scaffold(
        body: Stack(
          children: [
            pages[selectedIndex], // App content behind NavigationBar
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA), // Your navbar color
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: Offset(0, -2), // Subtle shadow effect
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: NavigationBar(
                    backgroundColor:
                        Colors.transparent, // Matches container color
                    destinations: destinations,
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (index) {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      routes: {
        '/home': (context) => MyHomePage(),
        '/helps': (context) => HelpsPage(),
        '/alert': (context) => AlertPage(),
        '/my': (context) => MyPage(),
      },
    );
  }
}
