import 'package:flutter/material.dart';
import '../home_page/app_theme.dart';

class TitleWidgetView extends StatelessWidget {
  final String title;
  const TitleWidgetView({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Text(title,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            letterSpacing: 0.27,
            color: AppTheme.darkerText,
          )),
    );
  }
}
