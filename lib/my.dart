import 'package:flutter/material.dart';
import 'package:allhelps/navigation.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}
class _MyPageState extends State<MyPage> {
  int _selectedIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('My Page'),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
              child: Text('Go to Home Page'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyNavigationBar(
        currentPageIndex: _selectedIndex,
        onItemTapped: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        }
      ),
    );
  }
}
