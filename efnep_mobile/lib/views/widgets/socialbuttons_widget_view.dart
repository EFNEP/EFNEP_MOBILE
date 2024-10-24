import 'package:flutter/material.dart';
import '../../controllers/AuthController.dart';

class SocialButtonWidget extends StatelessWidget {
  const SocialButtonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () async {
          // Trigger Google Sign in
          await AuthController().loginWithGoogle();
        },
        child: Image.asset(
          "assets/google_logo.png",
          width: 80,
        ),
      ),
    );
  }
}
