import 'package:findgo_admin/data_models/user.dart';
import 'package:flutter/material.dart';

const kVersion = "v 0.2.4"; // 15:30 22 June 2022

// NETWORKING
const kTimeOutDuration = Duration(minutes: 1);

const kMaxImageByteSize = 2000000;

//const kServerUrl = 'http://10.0.2.2:8080'; // Android Emulator
//const kServerUrl = 'http://localhost:8080'; // IOS Emulator / Web

//const kServerUrl = 'http://161.35.173.217:8080'; // Internet Local
//const kServerUrl = 'http://10.0.0.46:8080'; // Local PC

// const kServerUrl = 'http://localhost'; // Kubernetes Pod / Docker Container

// COLORS
// const kColorBackground = Color(0xff000000);
const kColorBackground = Color(0xff383838);
//const kColorPrimary = Color(0xff383838);

const kColorButton = Color(0xff181818);
const kColorCard = Color(0xff262727);
const kColorSelected = Color(0xff181818);

const kColorAccent = Colors.deepOrangeAccent;
const kColorUpdate = Colors.blue;
const kColorUpdateInactive = Colors.grey;

const kColorActive = Colors.green;
const kColorInactive = Colors.red;
const kColorRepeated = Colors.blue;

const kColorSuccess = Colors.green;
// const kColorSuccess = Color(0xff89b482);
const kColorError = Colors.red;
// const kColorError = Color(0xffea6962);
const kColorWarning = Color(0xffcc973d);

const kColorTextContent = Color(0xfff9f5d7);
const kColorSecondaryText = Color(0xffa8a8a8);

const kColorNavBar = Color(0xffc91c1c);

// STYLES
const kTextStyleHeading = TextStyle(
  fontSize: 26,
  fontWeight: FontWeight.bold,
);

const kTextStyleSubHeading = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  letterSpacing: 1.5,
);

const kTextStyleSubHeadingSecondary = TextStyle(
  color: kColorSecondaryText,
  fontSize: 18,
);

const kTextStyleMedium = TextStyle(
  color: kColorSecondaryText,
);

const kTextStyleSmall = TextStyle(
  fontSize: 12,
);

const kTextStyleSmallSecondary = TextStyle(
  fontSize: 12,
  color: kColorSecondaryText,
);

const kTextStyleTiny = TextStyle(
  fontSize: 10,
);

const kTextStyleTinySecondary = TextStyle(
  fontSize: 10,
  color: kColorSecondaryText,
);

const kPhotoPrice = 25;
const kVideoPrice = 50;
const kServicePrice = 10;

const kCardWidth = 250.0;
const kCardHeight = 310.0;

// const kCardImageHeight = 200.0;
const kCardImageHeight = 180.0;

const kDrawerMenuTilePadding =
    EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0);
const kDrawerMenuTileHeight = 40.0;
const kDrawerWidth = 230.0;
const kDrawerDivider = Divider(
  height: 26.0,
  thickness: 2,
  indent: 18,
  endIndent: 18,
  color: kColorBackground,
);

/// SCREEN BREAK POINTS
const kTabletBreakPoint = 830.0;
const kMobileBreakPoint = 530.0;

/// MESSAGES
const kPasswordNotLongEnough = 'Password must be at least 6 characters long';
const kPasswordMissMatch = "Passwords don't match";

const kFieldNotEnteredMessage = 'Field cannot be left empty';
const kConnectionErrorMessage =
    "Connection error, please check your device has internet connection";

const kMessageOfflineError = 'Offline Error: Check Internet Connection';
const kMessageAuthError = 'Authorization Error';

const kMessageEmailUpdateSuccess = 'Email update success';
const kMessagePasswordUpdateSuccess = 'Password update success';
const kMessageUsernameUpdateSuccess = 'Username update success';

const kMessagePasswordResetRequestEmailError = "[ERROR] Password Reset Request";
const kMessagePasswordResetUpdateSuccess = 'Password reset email sent success';

/// Error Messages / Codes
const kXMLHttpRequestError = "XMLHttpRequest";
const kTimeOutError = "TimeoutException";

/// Support Email
final Uri kSupportEmailLaunchUri = Uri(
  scheme: 'mailto',
  path: 'support@fingo.co.za',
  query: 'subject=FindGo Support',
);

final kUnauthorizedUser = User(uuid: "-1");

extension CapExtension on String {
  String get inCaps =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
  String get allInCaps => toUpperCase();
  String get capitalizeFirsTofEach => replaceAll(RegExp(' +'), ' ')
      .split(" ")
      .map((str) => str.inCaps)
      .join(" ");
}
