import 'package:flutter/material.dart';
import '../home_page/app_theme.dart';

class TitlePlanWidgetView extends StatelessWidget {
  final String title;
  const TitlePlanWidgetView({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          letterSpacing: 0.27,
          color: AppTheme.darkerText,
        ),
      ),
    );
  }
}

class ErrorPlanWidgetView extends StatelessWidget {
  final String title;
  const ErrorPlanWidgetView({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 16,
            letterSpacing: 0.27,
            color: AppTheme.darkerText,
          ),
        ),
      ),
    );
  }
}
