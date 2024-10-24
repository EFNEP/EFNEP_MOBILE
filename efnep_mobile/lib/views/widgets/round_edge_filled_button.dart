import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class RoundEdgeFilledButton extends StatelessWidget {
  const RoundEdgeFilledButton(
      {Key? key, required this.buttonText, this.onPressed, this.backgroundColor})
      : super(key: key);
  final Color? backgroundColor;
  final String buttonText;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        elevation: 18,
        padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
      ),
      child: Container(
        height: 50,
        alignment: Alignment.center,
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 16,
            letterSpacing: 2,
            color: white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
