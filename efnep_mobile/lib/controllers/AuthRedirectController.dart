// ignore_for_file: file_names
import 'dart:ui';
import 'package:efnep_mobile/views/home_page/home_screen.dart';
import '../entities/User.dart';
import '../models/authentication/FirebaseAuthServiceModel.dart';
import '../views/auth_pages/add_profile_image_view.dart';
import '../views/auth_pages/login_page_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthRedirectController extends StatelessWidget {
  const AuthRedirectController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authServiceProvider = Provider.of<FirebaseAuthServiceModel>(context);
    return StreamBuilder<UserData?>(
      stream: authServiceProvider.onAuthStateChanged(),
      builder: (_, AsyncSnapshot<UserData?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200.withOpacity(0.5)),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return const Center(child: Text("Something went wrong!"));
        } else {
          final user = snapshot.data;
          debugPrint("****** YO2 ${user?.displayName} - ${user?.email}");
          if (user != null) {
            debugPrint("*************** HELLO HOMEPAGE *****************");
            if (user.photoUrl == null) {
              return const AddProfileImageView();
            }
            // Go to HomePage
            return const HomeScreen();
          }
          return const LoginPageView();
        }
      },
    );
  }
}
