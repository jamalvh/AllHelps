import 'package:flutter/material.dart';

class HelpsPage extends StatefulWidget {
  HelpsPage({super.key});

  @override
  State<HelpsPage> createState() => _HelpsPageState();
}
class _HelpsPageState extends State<HelpsPage> {
 int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 50,),
          Text('Helps page'),
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
      
    );
  }
}
