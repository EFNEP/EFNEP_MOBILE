  // ignore_for_file: file_names
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';
  import 'package:google_sign_in/google_sign_in.dart';
  import '../../entities/User.dart';
  import '../user/UserHandlerModel.dart';
  import 'IFirebaseAuthService.dart';

  class FirebaseAuthServiceModel implements IFirebaseAuthServiceModel {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
      "email",
    ]);

    // UserModel is a custom Class which we made in user.dart
    // User is a firebase Auth class which comes inbuilt with firebase_auth package.
    UserData? _userFromFirebase(User? user,
        {String? phone, String? name, bool? isNewUser}) {
      if (user != null) {
        return UserData(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName ?? name,
          photoUrl: user.photoURL,
          phone: phone,
          isNewUser: isNewUser,
        );
      }
      return null;
    }

    @override
    User? getFirebaseUser() {
      return _firebaseAuth.currentUser;
    }

    UserData? getUserDetails() {
      User? firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        return _userFromFirebase(firebaseUser);
      }
      return null;
    }

    @override
    Stream<UserData?> onAuthStateChanged() {
      return _firebaseAuth.authStateChanges().map(_userFromFirebase);
    }

    @override
    Future<UserData?> signInWithGoogle() async {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final authResult = await _firebaseAuth.signInWithCredential(credential);
      final user = authResult.user;

      var userData = _userFromFirebase(user);

      if (authResult.additionalUserInfo!.isNewUser) {
        await UserHandlerModel().storeUserDetails(userData);
      }

      return userData;
    }

    @override
    Future signOutUser() async {
      return _firebaseAuth.signOut();
    }

    @override
    void dispose() {}

    @override
    Future<UserData?> signInWithEmailPassword(
        String email, String password) async {
      try {
        final authResult = await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password);
        final user = authResult.user;
        return _userFromFirebase(user);
      } on FirebaseAuthException catch (error) {
        debugPrint("Login Failed with error code : ${error.code}");
        debugPrint(error.message);
        return UserData(
          uid: null,
          email: null,
          displayName: null,
          authStatusMessage: error.message,
        );
      }
    }

    @override
    Future<UserData?> registerWithEmailPassword(
        String email, String password, String name, String phone) async {
      try {
        final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password);
        final user = authResult.user;
        await user!.updateDisplayName(name);
        return _userFromFirebase(
          user,
          phone: phone,
          name: name,
        );
      } on FirebaseAuthException catch (error) {
        debugPrint(
            "********************************Registration Failed with error code : ${error.code}");
        debugPrint(error.message);
        return UserData(
          uid: null,
          email: null,
          displayName: null,
          authStatusMessage: error.message,
        );
      }
    }

    @override
    Future sendForgotPasswordEmail(String email) async {
      try {
        await _firebaseAuth.sendPasswordResetEmail(email: email);
      } on FirebaseAuthException catch (error) {
        debugPrint(
            "******************************** Send password reset link failed with error code : ${error.code}");
        debugPrint(error.message);
        throw Exception(error.message);
      }
    }

    @override
    Future<UserData?> updateUserData({
      String? name,
      String? photoURL,
    }) async {
      try {
        User? user = _firebaseAuth.currentUser!;
        if (name != null) {
          await user.updateDisplayName(name);
        }
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }
        return _userFromFirebase(user);
      } on FirebaseAuthException catch (error) {
        debugPrint("Data update failed with error code : ${error.code}");
        debugPrint(error.message);
        return UserData(
          uid: null,
          email: null,
          displayName: null,
          authStatusMessage: error.message,
        );
      }
    }
  }
