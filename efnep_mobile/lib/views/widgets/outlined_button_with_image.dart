// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class CustomOutlineButton extends StatelessWidget {
  final String buttonText;
  final String? imageUrl;
  final Function()? onPressed;
  const CustomOutlineButton(
      {Key? key,
        required this.buttonText,
        this.imageUrl,
        required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: primaryColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              imageUrl != null
                  ? Image.asset(
                imageUrl!,
                width: 30,
                fit: BoxFit.fill,
              )
                  : const SizedBox(),
              Text(
                buttonText,
                style: const TextStyle(
                  color: Color(0xffb1e4155),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
