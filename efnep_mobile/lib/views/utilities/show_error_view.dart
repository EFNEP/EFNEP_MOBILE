import 'package:flutter/material.dart';

import '../../constants/colors.dart';

void showBottomNotificationMessage(BuildContext context, String message,
    {String? type}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      content: Container(
        height: 70,
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: Center(
          child: Text(
            message,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    ),
  );
}