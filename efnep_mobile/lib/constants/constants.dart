import 'package:flutter/material.dart';

String defaultProfileImageURL =
    "assets/default_user_avatar.png";

Color kAppPrimaryColor = Colors.grey.shade200;
Color kWhite = Colors.white;
Color kLightBlack = Colors.black.withOpacity(0.075);
Color mCC = Colors.green.withOpacity(0.65);
Color fCL = Colors.grey.shade600;

IconData twitter = const IconData(0xe900, fontFamily: "CustomIcons");
IconData facebook = const IconData(0xe901, fontFamily: "CustomIcons");
IconData googlePlus = const IconData(0xe902, fontFamily: "CustomIcons");
IconData linkedin = const IconData(0xe903, fontFamily: "CustomIcons");

const kSpacingUnit = 10;

const kTitleTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
);

BoxDecoration avatarDecoration =
    BoxDecoration(shape: BoxShape.circle, color: kAppPrimaryColor, boxShadow: [
  BoxShadow(
    color: kWhite,
    offset: const Offset(10, 10),
    blurRadius: 10,
  ),
  BoxShadow(
    color: kWhite,
    offset: const Offset(-10, -10),
    blurRadius: 10,
  ),
]);
