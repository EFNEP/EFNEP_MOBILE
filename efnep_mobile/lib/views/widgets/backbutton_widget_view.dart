import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class BackButtonWidget extends StatelessWidget {
  const BackButtonWidget({
    Key? key,
    this.iconColor,
  }) : super(key: key);

  final Color? iconColor;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: Icon(
        Icons.arrow_back_ios,
        color: iconColor ?? black,
      ),
    );
  }
}
