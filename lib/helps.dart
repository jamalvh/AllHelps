import 'package:flutter/material.dart';

class HelpsPage extends StatelessWidget {
  const HelpsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
          child: Text('Go to Home Page'),
        ),
      ),
    );
  }
}
