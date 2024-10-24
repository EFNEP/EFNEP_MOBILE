// ignore_for_file: file_names
import '../../entities/User.dart';
import '../user/UserHandlerModel.dart';
import 'FirebaseAuthServiceModel.dart';

class AuthServiceModel {
  Future<UserData?> loginWithGoogle() async {
    final authServiceProvider = FirebaseAuthServiceModel();
    UserData? userModel = await authServiceProvider.signInWithGoogle();
    return userModel;
  }

  Future<void> signOutUser() async {
    await FirebaseAuthServiceModel().signOutUser();
  }

  Future<UserData?> loginWithEmailPassword(
      String email, String password) async {
    final authServiceProvider = FirebaseAuthServiceModel();
    UserData? userModel = await authServiceProvider.signInWithEmailPassword(
      email,
      password,
    );
    return userModel;
  }

  Future<UserData?> registerWithEmailPassword(
      String email, String password, String name, String phone) async {
    final authServiceProvider = FirebaseAuthServiceModel();
    UserData? userModel = await authServiceProvider.registerWithEmailPassword(
      email,
      password,
      name,
      phone,
    );
    if (userModel != null) {
      await UserHandlerModel().storeUserDetails(userModel);
    }
    return userModel;
  }

  Future forgotPassword(String email) async {
    await FirebaseAuthServiceModel().sendForgotPasswordEmail(email);
  }

  // 
}
