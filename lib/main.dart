import 'package:allhelps/filter_model.dart';
import 'package:flutter/material.dart';
import 'package:allhelps/alert.dart';
import 'package:allhelps/helps.dart';
import 'package:allhelps/home.dart';
import 'package:allhelps/my.dart';
import 'package:allhelps/help_page_filters.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int selectedIndex = 0;

  FilterModel filterModel = FilterModel();



  // Callback to change the selected index
  void onIndexChanged(int index, {String? filter}) {
    setState(() {
      selectedIndex = index;
      if (index == 1 && filter != null) {
        filterModel.setChosenFilter(filter);
      }
    });
  }

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    // Initialize the pages with the callback
    pages = [
      MyHomePage(onIndexChanged: onIndexChanged),
      HelpsPage(),
      AlertPage(),
      MyPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Background color for app
      ),
      home: Scaffold(
        body: Stack(
          children: [
            pages[selectedIndex], // Display the selected page
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 110, // Set your desired height
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 10), // Move icons up by 10 pixels
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Home Icon
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = 0;
                          });
                        },
                        child: Image.asset(
                          selectedIndex == 0
                              ? 'assets/images/Home_selected.png'
                              : 'assets/images/Home.png',
                          height: 40,
                        ),
                      ),
                      // Helps Icon
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = 1;
                          });
                        },
                        child: Image.asset(
                          selectedIndex == 1
                              ? 'assets/images/Helps_selected.png'
                              : 'assets/images/Helps.png',
                          height: 40,
                        ),
                      ),
                      // Alert Icon
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = 2;
                          });
                        },
                        child: Image.asset(
                          selectedIndex == 2
                              ? 'assets/images/Alert_selected.png'
                              : 'assets/images/Alert.png',
                          height: 40,
                        ),
                      ),
                      // My Icon
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = 3;
                          });
                        },
                        child: Image.asset(
                          selectedIndex == 3
                              ? 'assets/images/My_selected.png'
                              : 'assets/images/My.png',
                          height: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      routes: {
        '/home': (context) => MyHomePage(onIndexChanged: onIndexChanged),
        '/helps': (context) => HelpsPage(),
        '/alert': (context) => AlertPage(),
        '/my': (context) => MyPage(),
      },
    );
  }
}
