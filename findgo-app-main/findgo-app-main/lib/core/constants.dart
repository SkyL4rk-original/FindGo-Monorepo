import 'package:flutter/material.dart';

const kVersion = 'Version 1.1.1'; // 15:00 06 July 2021

// NETWORKING
const kTimeOutDuration = Duration(seconds: 30);

// COLORS
const kColorBackgroundDark = Color(0xff181818);
const kColorBackgroundLight = Color(0xffc8c8c8);

//const kColorPrimary = Color(0xff383838);

const kColorButton = Color(0xff383838);
const kColorCardDark = Color(0xff272727);
const kColorCardLight = Color(0xffe8e8e8);

const kColorAccent = Colors.deepOrangeAccent;
const kColorUpdate = Colors.blue;

const kColorActive = Colors.green;
const kColorInactive = Colors.red;
const kColorRepeated = Colors.blue;

const kColorSuccess = Colors.green;
// const kColorSuccess = Color(0xff89b482);
const kColorError = Color(0xffc91c1c);
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

const kTextStyleSubHeading =
    TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5);

const kTextStyleSubHeadingSecondary = TextStyle(
  // color: kColorSecondaryText,
  fontSize: 18,
);

const kTextStyleMedium = TextStyle(
    // color: kColorSecondaryText
    );

const kTextStyleSmall = TextStyle(
  fontSize: 12,
);

const kTextStyleSmallSecondary = TextStyle(
  fontSize: 12,
  // color: kColorSecondaryText
);

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
  color: kColorBackgroundDark,
);

/// SCREEN BREAK POINTS
const kTabletBreakPoint = 768.0;
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
    path: 'support@findgo.co.za',
    query: 'subject=FindGo Support');
