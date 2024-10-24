import 'package:firebase_auth/firebase_auth.dart';
import '../../entities/User.dart';

abstract class IFirebaseAuthServiceModel {
  User? getFirebaseUser();
  Stream<UserData?> onAuthStateChanged();
  Future<UserData?> signInWithGoogle();
  Future signOutUser();
  Future sendForgotPasswordEmail(String email);
  void dispose();
  Future<UserData?> signInWithEmailPassword(
    String email,
    String password,
  );
  Future<UserData?> registerWithEmailPassword(
    String email,
    String password,
    String name,
    String phone,
  );

  Future<UserData?> updateUserData({
    String? name,
    String? photoURL,
  });

}
