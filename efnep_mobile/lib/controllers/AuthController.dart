// ignore_for_file: file_names
import '../entities/User.dart';
import '../models/authentication/AuthServiceModel.dart';

class AuthController {
  // Login user with Google
  Future<void> loginWithGoogle() async {
    await AuthServiceModel().loginWithGoogle();
  }

  Future<void> logOutUser() async {
    await AuthServiceModel().signOutUser();
  }

  Future<UserData?> loginWithEmailPassword(
      String email, String password) async {
    return await AuthServiceModel().loginWithEmailPassword(email, password);
  }

  Future<UserData?> registerWithEmailPassword(
      String email, String password, String name, String phone) async {
    return await AuthServiceModel()
        .registerWithEmailPassword(email, password, name, phone);
  }

  Future forgotPassword(String email) async {
    return await AuthServiceModel().forgotPassword(email);
  }
}
