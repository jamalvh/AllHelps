import 'package:allhelps/filter_model.dart';
import 'package:allhelps/my.dart';
import 'package:allhelps/signin.dart';
import 'package:allhelps/utils/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:allhelps/alert.dart';
import 'package:allhelps/helps.dart';
import 'package:allhelps/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  int selectedIndex = 0;
  final FilterModel filterModel = FilterModel();
  void onIndexChanged(int index, {String? filter}) {
    setState(() {
      selectedIndex = index;
      if (index == 1 && filter != null) {
        filterModel.setChosenFilter(filter);
      }
    });
  }

  var routeMap = {0: '/', 1: '/helps', 2: '/alerts', 3: '/my'};

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Background color for app
      ),
      // Define routes here
      routes: {
        '/': (context) => auth.currentUser == null
            ? SignInPage(
                selectedIndex: selectedIndex,
                onIndexChanged: onIndexChanged,
              )
            : NavBarPage(
                onIndexChanged: onIndexChanged,
                selectedIndex: selectedIndex,
              ),
        '/home': (context) =>
            MyHomePage(onIndexChanged: (int index, {String? filter}) {}),
        '/helps': (context) => HelpsPage(
              onIndexChanged: onIndexChanged,
            ), // Define the /helps route
        '/alert': (context) => const AlertPage(),
        '/my': (context) => MyPage(
              selectedIndex: selectedIndex,
              onIndexChanged: onIndexChanged,
            ),
      },
      initialRoute: '/', // Set the initial route
    );
  }
}

class NavBarPage extends StatefulWidget {
  final Function(int, {String? filter}) onIndexChanged;
  final int selectedIndex;

  const NavBarPage({
    super.key,
    required this.onIndexChanged,
    required this.selectedIndex,
  });

  @override
  _NavBarPageState createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarPage> {
  // Callback to change the selected index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(
          widget.selectedIndex), // Update the body based on the selected index
      bottomNavigationBar: BottomNavBar(
        selectedIndex: widget.selectedIndex,
        onIndexChanged: widget.onIndexChanged,
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return MyHomePage(onIndexChanged: widget.onIndexChanged);
      case 1:
        return HelpsPage(onIndexChanged: widget.onIndexChanged);
      case 2:
        return const AlertPage();
      case 3:
        return MyPage(
          onIndexChanged: widget.onIndexChanged,
          selectedIndex: widget.selectedIndex,
        );
      default:
        return Container(); // Fallback in case of an invalid index
    }
  }
}

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
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
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              imagePath: 'assets/images/Home.png',
              selectedImagePath: 'assets/images/Home_selected.png',
              index: 0,
            ),
            _buildNavItem(
              imagePath: 'assets/images/Helps.png',
              selectedImagePath: 'assets/images/Helps_selected.png',
              index: 1,
            ),
            _buildNavItem(
              imagePath: 'assets/images/Alert.png',
              selectedImagePath: 'assets/images/Alert_selected.png',
              index: 2,
            ),
            GestureDetector(
              onTap: () => onIndexChanged(3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: 35,
                    color: selectedIndex == 3 ? Colors.deepPurple : Colors.grey,
                  ),
                  const Text(
                    "My",
                    style: TextStyle(fontSize: 8, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String imagePath,
    required String selectedImagePath,
    required int index,
  }) {
    return GestureDetector(
      onTap: () => onIndexChanged(index),
      child: Image.asset(
        selectedIndex == index ? selectedImagePath : imagePath,
        height: 40,
      ),
    );
  }
}
