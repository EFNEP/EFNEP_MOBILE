// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class MessageHandler {
  static void showSnackBar(var _scaffoldKey, String message) {
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 2),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 18,
            color: white,
          ),
        ),
      ),
    );
  }
}
