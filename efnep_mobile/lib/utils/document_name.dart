import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// Helper function to fetch all document names from a collection
Future<List<String>> getAllDocumentNames(String collectionName) async {
  List<String> documentNames = [];
  try {
    // Get a reference to the collection
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection(collectionName);

    // Get all the documents in the collection
    QuerySnapshot querySnapshot = await collectionReference.get();

    // Extract the document names from the documents
    for (var document in querySnapshot.docs) {
      documentNames.add(document.id);
    }

    return documentNames;
  } catch (e) {
    // Handle any errors that might occur during the fetch
    if (kDebugMode) {
      print('Error getting document names: $e');
    }
    return [];
  }
}
