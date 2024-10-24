// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:efnep_mobile/views/post_pages/models/video_post.dart';
import 'package:uuid/uuid.dart';
import '../models/post.dart';
import '../resources/storage_methods.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String profImage) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);
      String postId = const Uuid().v1(); // creates unique id based on time
      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        likes: [],
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
      );
      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> uploadVideoPost(String description, File file, String uid,
      String username, String profImage) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      String videoUrl =
          await StorageMethods().uploadVideoToStorage('video-posts', file);
      String videoId = const Uuid().v1(); // creates unique id based on time
      VideoPost post = VideoPost(
        description: description,
        uid: uid,
        username: username,
        likes: [],
        videoId: videoId,
        datePublished: DateTime.now(),
        videoUrl: videoUrl,
        profImage: profImage,
      );
      _firestore.collection('video-posts').doc(videoId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> likePost(String postId, String uid, List likes) async {
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> likeVideos(String videoId, String uid, List likes) async {
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _firestore.collection('video-posts').doc(videoId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _firestore.collection('video-posts').doc(videoId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Post comment
  Future<String> postComment(String postId, String text, String uid,
      String name, String profilePic) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        // if the likes list contains the user uid, we need to remove it
        String commentId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Post video comment
  Future<String> postVideoComment(String videoId, String text, String uid,
      String name, String profilePic) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        // if the likes list contains the user uid, we need to remove it
        String commentId = const Uuid().v1();
        _firestore
            .collection('video-posts')
            .doc(videoId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Post poll comment
  Future<String> postPollComment(String videoId, String text, String uid,
      String name, String profilePic) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        // if the likes list contains the user uid, we need to remove it
        String commentId = const Uuid().v1();
        _firestore
            .collection('polls')
            .doc(videoId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> postReply(
      String postId, String replyText, String replyToCommentId) async {
    try {
      // Get the current user's information
      final user = FirebaseAuth.instance.currentUser;

      // Create a new document reference for the reply
      final replyDocRef = _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(replyToCommentId)
          .collection('replies')
          .doc();

      // Create a map of the reply data
      final replyData = {
        'text': replyText,
        'uid': user!.uid,
        'name': user.displayName,
        'profilePic': user.photoURL,
        'datePublished': FieldValue.serverTimestamp(),
      };

      // Write the reply data to Firestore
      await replyDocRef.set(replyData);

      return 'success'; // Return a success message
    } catch (error) {
      return 'Error posting reply: ${error.toString()}';
    }
  }

  Future<String> postVideoReply(
      String postId, String replyText, String replyToCommentId) async {
    try {
      // Get the current user's information
      final user = FirebaseAuth.instance.currentUser;

      // Create a new document reference for the reply
      final replyDocRef = _firestore
          .collection('video-posts')
          .doc(postId)
          .collection('comments')
          .doc(replyToCommentId)
          .collection('replies')
          .doc();

      // Create a map of the reply data
      final replyData = {
        'text': replyText,
        'uid': user!.uid,
        'name': user.displayName,
        'profilePic': user.photoURL,
        'datePublished': FieldValue.serverTimestamp(),
      };

      // Write the reply data to Firestore
      await replyDocRef.set(replyData);

      return 'success'; // Return a success message
    } catch (error) {
      return 'Error posting reply: ${error.toString()}';
    }
  }

  Future<String> postPollReply(
      String postId, String replyText, String replyToCommentId) async {
    try {
      // Get the current user's information
      final user = FirebaseAuth.instance.currentUser;

      // Create a new document reference for the reply
      final replyDocRef = _firestore
          .collection('polls')
          .doc(postId)
          .collection('comments')
          .doc(replyToCommentId)
          .collection('replies')
          .doc();

      // Create a map of the reply data
      final replyData = {
        'text': replyText,
        'uid': user!.uid,
        'name': user.displayName,
        'profilePic': user.photoURL,
        'datePublished': FieldValue.serverTimestamp(),
      };

      // Write the reply data to Firestore
      await replyDocRef.set(replyData);

      return 'success'; // Return a success message
    } catch (error) {
      return 'Error posting reply: ${error.toString()}';
    }
  }

  Future<List<Map<String, dynamic>>> getReplies(
      String postId, String commentId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .orderBy('datePublished',
              descending: false) // Change ordering as needed
          .get();

      List<Map<String, dynamic>> replies = [];
      for (var doc in querySnapshot.docs) {
        replies.add(doc.data() as Map<String, dynamic>);
      }

      return replies;
    } catch (error) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getVideoReplies(
      String postId, String commentId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('video-posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .orderBy('datePublished',
              descending: false) // Change ordering as needed
          .get();

      List<Map<String, dynamic>> replies = [];
      for (var doc in querySnapshot.docs) {
        replies.add(doc.data() as Map<String, dynamic>);
      }

      return replies;
    } catch (error) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPollReplies(
      String postId, String commentId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('polls')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .orderBy('datePublished',
              descending: false) // Change ordering as needed
          .get();

      List<Map<String, dynamic>> replies = [];
      for (var doc in querySnapshot.docs) {
        replies.add(doc.data() as Map<String, dynamic>);
      }

      return replies;
    } catch (error) {
      rethrow;
    }
  }

  // Delete Post
  Future<String> deletePost(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Delete Video Post
  Future<String> deleteVideo(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('video-posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
