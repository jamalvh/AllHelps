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
      icon: Image.asset('assets/images/Home.png', height: 40),
      selectedIcon: Image.asset('assets/images/Home_selected.png', height: 40),
      label: '',
    ),
    NavigationDestination(
      icon: Image.asset('assets/images/Helps.png', height: 40),
      selectedIcon: Image.asset('assets/images/Helps_selected.png', height: 40),
      label: '',
    ),
    NavigationDestination(
      icon: Image.asset('assets/images/Alert.png', height: 40),
      selectedIcon: Image.asset('assets/images/Alert_selected.png', height: 40),
      label: '',
      
    ),
    NavigationDestination(
      icon: Image.asset('assets/images/My.png', height: 40),
      selectedIcon: Image.asset('assets/images/My_selected.png', height: 40),
      label: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: Scaffold(
        body: pages[selectedIndex],
        bottomNavigationBar: NavigationBar(
          destinations: destinations,
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
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