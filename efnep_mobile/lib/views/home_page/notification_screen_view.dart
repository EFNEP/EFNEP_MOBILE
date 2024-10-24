// ignore_for_file: library_private_types_in_public_api
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';

class NotificationPageView extends StatefulWidget {
  const NotificationPageView({Key? key}) : super(key: key);

  @override
  _NotificationPageViewState createState() => _NotificationPageViewState();
}

class _NotificationPageViewState extends State<NotificationPageView> {
  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> notificationStream = FirebaseFirestore.instance
        .collection('push-notifications')
        .snapshots(includeMetadataChanges: true);
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Notifications History',
          style: TextStyle(
            color: white,
          ),
        ),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notificationStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(
                child: Text(
                  wentWrong,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              ),
            );
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Scaffold(
              body: Center(
                child: Text(
                  noData,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            );
          }

          // Sort the notifications by date published
          List<QueryDocumentSnapshot> reversedDocs = snapshot.data!.docs;
          reversedDocs.sort((a, b) {
            Timestamp aTimestamp = a['created'];
            Timestamp bTimestamp = b['created'];
            return bTimestamp.compareTo(aTimestamp);
          });

          try {
            return ListView.builder(
              itemCount: reversedDocs.length,
              itemBuilder: (context, index) {
                final doc = reversedDocs[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(12),
                    elevation: 2,
                    child: ListTile(
                      title: Text(doc['title']),
                      subtitle: Text(doc['body']),
                      // also display timestamp only date
                      trailing: Text(
                        doc['created'].toDate().toString().substring(0, 10),
                      ),
                    ),
                  ),
                );
              },
            );
          } catch (e) {
            return const Scaffold(
              body: Center(
                child: Text(
                  wentWrong,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
