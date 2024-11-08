import 'package:flutter/material.dart';
import 'helps.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEDF4FF),
      body: Column(
        children: [
          Header(),
          Column(
            children: [
              SizedBox(height: 112), // TODO: Replace this with Search Bar
              //SearchBar(),
              HelpsRow(),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget for header
class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        child:
            // Stack to overlay image over header
            Stack(children: [
      // Header
      Container(
        height: 213,
        decoration: BoxDecoration(
            color: Color(0xFF6359CA),
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(26),
                bottomRight: Radius.circular(26))),
        alignment: Alignment.center,
      ),
      // Image
      Positioned(
        top: 0,
        left: 20,
        child: Center(
          child: Image.asset(
            'assets/images/header_image.png',
            height: 180,
            fit: BoxFit.cover,
          ),
        ),
      ),
    ]));
  }
}

// Widget for Helps Row
class HelpsRow extends StatelessWidget {
  const HelpsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            alignment: Alignment.centerLeft,
            child: Text(
              "We are here to help",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.left,
            ),
          )),
      SizedBox(height: 10),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              HelpsButton(
                  backgroundColor: Color(0xFFE57701),
                  text: "Searching for Food",
                  imageURL: "assets/images/helps_food_icon.png",
                  onTap: () {
                    Navigator.pushNamed(context, '/helps');
                  }),
              HelpsButton(
                  backgroundColor: Color(0xFF50714A),
                  text: "Looking for Shelter",
                  imageURL: "assets/images/helps_shelter_icon.png"),
              HelpsButton(
                  backgroundColor: Color(0xFF4F77C0),
                  text: "Get Medical Relief",
                  imageURL: "assets/images/helps_medicine_icon.png")
            ],
          ))
    ]);
  }
}


// Widget for Helps Button
class HelpsButton extends StatelessWidget {
  final Color backgroundColor;
  final String text;
  final String imageURL;
  final VoidCallback? onTap; // Add this line

  const HelpsButton({
    Key? key,
    required this.backgroundColor,
    required this.text,
    required this.imageURL,
    this.onTap, // And this line
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // Ensures the ripple effect is clipped to the border radius
      borderRadius: BorderRadius.circular(14),
      child: Material(
        color: backgroundColor, // Use the background color here
        child: InkWell(
          onTap: onTap, // Detects taps
          child: Container(
            width: 116,
            height: 144,
            // Remove the decoration color since it's now set in Material
            child: Stack(
              children: [
                // Icon
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    height: 46,
                    width: 46,
                    child: Image.asset(
                      imageURL,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Text caption
                Positioned(
                  bottom: 20,
                  left: 12,
                  right: 12,
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}