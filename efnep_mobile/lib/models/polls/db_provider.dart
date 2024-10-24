import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DbProvider extends ChangeNotifier {
  String _message = "";

  bool _status = false;
  bool _deleteStatus = false;

  String get message => _message;
  bool get status => _status;
  bool get deleteStatus => _deleteStatus;

  User? user = FirebaseAuth.instance.currentUser;

  CollectionReference pollCollection =
      FirebaseFirestore.instance.collection("polls");

  void addPoll(
      {required String question,
      required String duration,
      required List<Map> options}) async {
    _status = true;
    notifyListeners();
    try {
      ///
      final data = {
        "dateCreated": DateTime.now(),
        "poll": {
          "total_votes": 0,
          "voters": <Map>[],
          "question": question,
          "options": options,
        }
      };

      await pollCollection.add(data);
      _message = "Poll Created";
      _status = false;
      notifyListeners();
    } on FirebaseException catch (e) {
      _message = e.message!;
      _status = false;
      notifyListeners();
    } catch (e) {
      _message = "Please try again...";
      _status = false;
      notifyListeners();
    }
  }

  void deletePoll({required String pollId}) async {
    _deleteStatus = true;
    notifyListeners();

    try {
      await pollCollection.doc(pollId).delete();
      _message = "Poll Deleted";
      _deleteStatus = false;
      notifyListeners();
    } on FirebaseException catch (e) {
      _message = e.message!;
      _deleteStatus = false;
      notifyListeners();
    } catch (e) {
      _message = "Please try again...";
      _deleteStatus = false;
      notifyListeners();
    }
  }

  void votePoll({
    required String? pollId,
    required DocumentSnapshot pollData,
    required int previousTotalVotes,
    required String selectedOptions,
  }) async {
    _status = true;
    notifyListeners();

    try {
      List voters = pollData['poll']["voters"];

      voters.add({
        "name": user!.displayName,
        "uid": user!.uid,
        "selected_option": selectedOptions,
      });

      // Create options and update items
      List options = List.from(pollData["poll"]["options"]); // Clone the list

      var totalVotes = previousTotalVotes + 1;

      for (var i in options) {
        if (i["answer"] == selectedOptions) {
          i["percent"] = (i["percent"] ?? 0) + 1;
        }
      }

      // Update poll
      final data = {
        "dateCreated": pollData["dateCreated"],
        "poll": {
          "total_votes": totalVotes,
          "voters": voters,
          "question": pollData["poll"]["question"],
          "options": options,
        }
      };

      await pollCollection.doc(pollId).update(data);
      _message = "Vote Recorded";
    } on FirebaseException catch (e) {
      _message = e.message!;
    } catch (e) {
      debugPrint(e.toString());
      _message = "Please try again...";
    } finally {
      _status = false;
      notifyListeners();
    }
  }

  void clear() {
    _message = "";
    notifyListeners();
  }
}
