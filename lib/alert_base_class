import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Alert extends StatelessWidget {
  final AlertBase alertBase;

  Alert({required this.alertBase});

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('MM/dd/yyyy');
    final String formattedDate =
        formatter.format(alertBase.date ?? DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize
              .min, // This ensures the column takes the minimum vertical space required
          children: [
            Row(
              children: [
                Text(
                  alertBase.header!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              alertBase.message!,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlertBase {
  // Instance variables
  String? _type;
  String? _header;
  String? _message;
  DateTime? _date;
  final Color _welcomeText = const Color(0xFF3d3a8d);
  final Color _welcomeBG = const Color.fromRGBO(237, 244, 255, 1);
  final Color _welcomeBorder = const Color.fromRGBO(220, 220, 224, 1);

  // Constructor
  AlertBase(this._type, this._header, this._message, this._date);

  // Getter methods
  String? get type => _type;
  String? get header => _header;
  String? get message => _message;
  DateTime? get date => _date;
  Color get welcomeText => _welcomeText;
  Color get welcomeBG => _welcomeBG;
  Color get welcomeBorder => _welcomeBorder;

  void show() {
    print('AlertBase.show()');
  }
}
