import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../entities/User.dart';

class UserHandlerModel {
  final CollectionReference users =
      FirebaseFirestore.instance.collection("Users");

  /// Creates a document in database with the user data
  Future<void> storeUserDetails(UserData? user) async {
    return await users.doc(user!.email).set({
      "uid": user.uid,
      "email": user.email,
      "name": user.displayName,
      "photoUrl": user.photoUrl,
      "phone": user.phone,
      "signUpTime": FieldValue.serverTimestamp(),
      "purchases": [], // Initialize purchases as an empty array
    }).catchError((error) =>
        debugPrint("Failed to add user details to database: $error"));
  }

  /// Update a single user detail in the database
  Future<void> updateSingleUserDetail(BuildContext context,
      {required String key, required dynamic value}) {
    var user = Provider.of<UserData?>(context, listen: false);
    return users.doc(user!.uid).update({
      key: value,
    }).catchError((error) =>
        debugPrint("Failed to update user details to database: $error"));
  }

  /// Add a purchase for the current user
  Future<void> addPurchase(BuildContext context, String purchaseDetails) async {
    var user = Provider.of<UserData?>(context, listen: false);
    DocumentReference userDocRef = users.doc(user!.uid);
    List<dynamic> purchases = [];

    // Retrieve the current purchases
    await userDocRef.get().then((docSnapshot) {
      if (docSnapshot.exists) {
        purchases = docSnapshot['purchases'] ?? [];
      }
    }).catchError((error) {
      debugPrint("Error fetching user document: $error");
    });

    // Add the new purchase to the list of purchases
    purchases.add(purchaseDetails);

    // Update the purchases in the user document
    await userDocRef.update({'purchases': purchases}).catchError((error) {
      debugPrint("Failed to update purchases in database: $error");
    });
  }
}
