import 'package:findgo/core/constants.dart';
import 'package:flutter/material.dart';

enum SnackBarColor { success, warning, error }

const kErrorTextColor = Colors.white;

// ignore: avoid_classes_with_only_static_members
class InfoSnackBar {
  static Future<void> show(
    BuildContext context,
    String message, {
    SnackBarColor color = SnackBarColor.success,
    String? title,
  }) async {
    ScaffoldMessenger.of(context).showSnackBar(
      await _create(color: color, message: message, title: title),
    );
  }

  static Future<SnackBar> _create({
    SnackBarColor color = SnackBarColor.success,
    required String message,
    String? title,
  }) async {
    Color getColor(SnackBarColor color) {
      switch (color) {
        case SnackBarColor.success:
          {
            return kColorSuccess;
          }

        case SnackBarColor.warning:
          {
            return kColorWarning;
          }

        case SnackBarColor.error:
          {
            return kColorError;
          }

        default:
          {
            return kColorSuccess;
          }
      }
    }

    return SnackBar(
      backgroundColor: getColor(color),
      content: title == null
          ? Text(
              message,
              style: const TextStyle(color: kErrorTextColor),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kErrorTextColor,
                  ),
                ),
                Text(message)
              ],
            ),
      action: SnackBarAction(
        textColor: kErrorTextColor,
        label: 'ok',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
  }
}

