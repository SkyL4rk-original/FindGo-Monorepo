import 'package:flutter/material.dart';

import '../core/constants.dart';

enum SnackBarColor{ success, warning, error }

const kTextColor = Colors.white;

class InfoSnackBar {

  static Future<void> show(BuildContext context, String message, {SnackBarColor color=SnackBarColor.success, String? title}) async {
    ScaffoldMessenger.of(context).showSnackBar(await _create(color: color, message: message, title: title));
  }

  static Future<SnackBar> _create({
    SnackBarColor color=SnackBarColor.success,
    required String message,
    String? title
  }) async {
    Color getColor(SnackBarColor color) {
      switch(color) {
        case SnackBarColor.success: {
          return kColorSuccess;
        }

        case SnackBarColor.warning: {
          return kColorWarning;
        }

        case SnackBarColor.error: {
          return kColorError;
        }

        default: {
          return kColorSuccess;
        }
      }
    }

    return SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: getColor(color),
        content: title == null
            ? Text(message, style: const TextStyle(color: kTextColor),)
            : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: kTextColor),),
                Text(message, style: const TextStyle(color: kTextColor))
              ],
            ),
        action: SnackBarAction(
          textColor: kTextColor,
            label: 'ok',
            onPressed: () {
              // Some code to undo the change.
            }
        )
    );
  }
}