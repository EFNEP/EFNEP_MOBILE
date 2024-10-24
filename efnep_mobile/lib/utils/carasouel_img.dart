// import 'package:cloud_firestore/cloud_firestore.dart';

// Future<List<String>> fetchCarouselImages() async {
//   List<String> imageUrls = [];

//   // Replace 'your_collection_name' with the actual name of your collection in Firestore
//   CollectionReference collectionRef = FirebaseFirestore.instance.collection('your_collection_name');

//   try {
//     QuerySnapshot querySnapshot = await collectionRef.get();
//     querySnapshot.docs.forEach((doc) {
//       // Replace 'image_url_field_name' with the field name where the image URL is stored in each document
//       String? imageUrl = doc.data()['image_url_field_name'] as String?;
//       if (imageUrl != null) {
//         imageUrls.add(imageUrl);
//       }
//     });
//   } catch (e) {
//     print("Error fetching carousel images: $e");
//   }

//   return imageUrls;
// }
