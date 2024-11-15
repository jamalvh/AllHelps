import 'package:allhelps/alert.dart';
import 'package:allhelps/helps.dart';
import 'package:allhelps/home.dart';
import 'package:allhelps/my.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Change initialRoute to your team's page during development
      initialRoute: '/',
      // Update this theme to unify basic color palette/font across project
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      routes: {
        // '/': (context) => Scaffold(
        //       body: Center(
        //         child: ElevatedButton(
        //           onPressed: () {
        //             Navigator.pushNamed(context, '/alert');
        //           },
        //           child: const Text('Go to Alert Page'),
        //         ),
        //       ),
        //     ),
        '/': (context) => MyHomePage(),
        '/helps': (context) => HelpsPage(),
        '/alert': (context) => AlertPage(),
        '/my': (context) => MyPage(),
      },
    );
  }
}
