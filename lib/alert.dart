import 'package:flutter/material.dart';
import 'package:allhelps/navigation.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}
class _AlertPageState extends State<AlertPage> {
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Alerts page'),
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
