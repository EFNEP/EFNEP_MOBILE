// ignore_for_file: prefer_typing_uninitialized_variables
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoPost {
  final String description;
  final String uid;
  final String username;
  final likes;
  final String videoId;
  final DateTime datePublished;
  final String videoUrl;
  final String profImage;

  const VideoPost(
      {required this.description,
      required this.uid,
      required this.username,
      required this.likes,
      required this.videoId,
      required this.datePublished,
      required this.videoUrl,
      required this.profImage,
      });

  static VideoPost fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return VideoPost(
      description: snapshot["description"],
      uid: snapshot["uid"],
      likes: snapshot["likes"],
      videoId: snapshot["videoId"],
      datePublished: snapshot["datePublished"],
      username: snapshot["username"],
      videoUrl: snapshot['videoUrl'],
      profImage: snapshot['profImage']
    );
  }

   Map<String, dynamic> toJson() => {
        "description": description,
        "uid": uid,
        "likes": likes,
        "username": username,
        "videoId": videoId,
        "datePublished": datePublished,
        'videoUrl': videoUrl,
        'profImage': profImage
      };
}
