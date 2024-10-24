import 'package:flutter/material.dart';
import 'package:efnep_mobile/controllers/AuthRedirectController.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _SplashScreen();
  }
}

class _SplashScreen extends State<SplashScreen> {
  int splashtime = 3;
  // duration of splash screen on second

  @override
  void initState() {
    Future.delayed(Duration(seconds: splashtime), () async {
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
        return const AuthRedirectController();
      }));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          //vertically align center
          children: <Widget>[
            SizedBox(
              height: 200,
              width: 200,
              child: Image.asset(
                "assets/logo.png",
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 30),
              //margin top 30
              child: const Text(
                "Good Bowls",
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 15),
              child: const Text(
                "Good Bowls for Good Health",
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
