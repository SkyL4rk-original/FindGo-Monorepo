import 'package:findgo_admin/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const kNotificationTimeEarly = TimeOfDay(hour: 8, minute: 0);
const kNotificationTimeMidday = TimeOfDay(hour: 12, minute: 0);
const kNotificationTimeAfterNoon = TimeOfDay(hour: 16, minute: 0);

class NotificationTimer extends StatefulWidget {
  const NotificationTimer({Key? key}) : super(key: key);

  @override
  _NotificationTimerState createState() => _NotificationTimerState();
}

class _NotificationTimerState extends State<NotificationTimer> {
  late DateTime _nextNotificationDateTime;

  void _setNextNotificationDateTime() {
    final now = DateTime.now();

    final early = DateTime(
      now.year,
      now.month,
      now.day,
      kNotificationTimeEarly.hour,
      kNotificationTimeEarly.minute,
    );
    final midday = DateTime(
      now.year,
      now.month,
      now.day,
      kNotificationTimeMidday.hour,
      kNotificationTimeMidday.minute,
    );
    final afternoon = DateTime(
      now.year,
      now.month,
      now.day,
      kNotificationTimeAfterNoon.hour,
      kNotificationTimeAfterNoon.minute,
    );
    final nextDayEarly = DateTime(
      now.year,
      now.month,
      now.day + 1,
      kNotificationTimeEarly.hour,
      kNotificationTimeEarly.minute,
    );

    if (now.isBefore(early)) {
      _nextNotificationDateTime = early;
    } else if (now.isAfter(early) && now.isBefore(midday)) {
      _nextNotificationDateTime = midday;
    } else if (now.isAfter(midday) && now.isBefore(afternoon)) {
      _nextNotificationDateTime = afternoon;
    } else if (now.isAfter(afternoon)) {
      _nextNotificationDateTime = nextDayEarly;
    }
  }

  @override
  void initState() {
    final now = DateTime.now();
    _nextNotificationDateTime =
        DateTime(now.year, now.month, now.day, kNotificationTimeEarly.hour);
    _setNextNotificationDateTime();
    super.initState();
  }

  String formatDuration(Duration d) =>
      d.toString().split('.').first.padLeft(8, "0");

  @override
  Widget build(BuildContext context) {
    final difference = _nextNotificationDateTime.difference(DateTime.now());
    if (difference < -const Duration(milliseconds: 100)) {
      _setNextNotificationDateTime();
    }
    Future.delayed(const Duration(seconds: 1), () => setState(() {}));

    return SizedBox(
      width: 200.0,
      child: Row(
        children: [
          const Text("Next Notification:", style: kTextStyleSmallSecondary),
          const SizedBox(
            width: 4.0,
          ),
          Text(formatDuration(difference), style: kTextStyleSmallSecondary),
          const SizedBox(
            width: 4.0,
          ),
          const Text("@", style: kTextStyleSmallSecondary),
          const SizedBox(
            width: 4.0,
          ),
          Text(
            DateFormat.Hm().format(_nextNotificationDateTime),
            style: kTextStyleSmallSecondary,
          )
        ],
      ),
    );
  }
}
