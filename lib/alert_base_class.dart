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
          color: alertBase._type == AlertType.Welcome
              ? alertBase.welcomeBG
              : alertBase._type == AlertType.Safety
                  ? alertBase._safetyBG
                  : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: alertBase.welcomeBorder,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (alertBase._type == AlertType.Safety) ...[
                  const Icon(
                    Icons.warning_amber,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  alertBase.header!,
                  style: TextStyle(
                    color: alertBase._type == AlertType.Safety
                        ? alertBase._safetyText
                        : alertBase._type == AlertType.Welcome
                            ? alertBase.welcomeText
                            : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (alertBase._type != AlertType.Welcome)
                  Text(
                    getRelativeTime(alertBase.date!),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              alertBase.message!,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays >= 7) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1
          ? '1 day ago'
          : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? '1 hr ago'
          : '${difference.inHours} hrs ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1
          ? '1 min ago'
          : '${difference.inMinutes} mins ago';
    } else if (difference.inSeconds > 30) {
      return '${difference.inSeconds} secs ago';
    } else {
      return 'just now';
    }
  }
}

enum AlertType { Welcome, Event, Resources, Safety }

class AlertBase {
  // Instance variables
  AlertType? _type;
  String? _header;
  String? _message;
  DateTime? _date;
  final Color _welcomeText = const Color(0xFF3d3a8d);
  final Color _safetyText = Colors.red;
  final Color _welcomeBG = const Color.fromRGBO(237, 244, 255, 1);
  final Color _welcomeBorder = const Color.fromRGBO(220, 220, 224, 1);
  final Color _safetyBG = const Color.fromRGBO(255, 241, 184, 1);

  // Constructor
  AlertBase({
    AlertType? type,
    String? header,
    String? message,
    DateTime? date,
  }) {
    _type = type;
    _header = header ?? 'Welcome to the App!';
    _message = message ?? 'We are excited to have you on board!';
    _date = type == AlertType.Welcome ? null : (date ?? DateTime.now());
  }

  // Getter methods
  AlertType? get type => _type;
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
