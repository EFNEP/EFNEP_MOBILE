// ignore_for_file: library_private_types_in_public_api, prefer_typing_uninitialized_variables
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:efnep_mobile/constants/colors.dart';
import 'package:efnep_mobile/entities/User.dart';
import 'package:efnep_mobile/provider/language_provider.dart';
import 'package:efnep_mobile/services/analytics.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../../../services/notification.dart';
import '../resources/firestore_methods.dart';
import '../utils/utils.dart';
import '../widgets/comment_card.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class CommentsScreen extends StatefulWidget {
  final postId;
  const CommentsScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  NotificationServices notificationServices = NotificationServices();
  final TextEditingController commentEditingController =
      TextEditingController();
  static final _formKey = GlobalKey<FormState>();

  late LanguageProvider _languageProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageProvider = Provider.of<LanguageProvider>(
        context); // Get the LanguageProvider instance
  }


  @override
  void initState() {
    super.initState();
    analytics('Comments', 'CommentsScreen');
    notificationServices.requestNotificationPermission();
    notificationServices.forgroundMessage();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();

    notificationServices.getDeviceToken().then((value) {
      if (kDebugMode) {
        print('device token');
        print(value);
      }
    });
  }

  void postComment(String uid, String name, String profilePic) async {
    try {
      String res = await FireStoreMethods().postComment(
        widget.postId,
        commentEditingController.text,
        uid,
        name,
        profilePic,
      );

      // send notification from one device to another
      notificationServices.getDeviceToken().then((value) async {
        var data = {
          'to': '/topics/all',
          'notification': {
            'title': 'New Comment',
            'body': 'Commented by $name'
          },
          'data': {'type': 'msj'}
        };

        await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
            body: jsonEncode(data),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization':
                  'key=AAAAMYZh6jU:APA91bEH8Jv_QKb0PPHIQSlM6RLcgF5oQoEIvW9H0OSh3CVgE5k9Dwfyg2HXPbPdW-aD3JzfkDfAKERTFyK9qk4eByWotAiHUgQx39zNmxIebLxLZBBmlRgFUVIDeAFP6Wr1skB1raVg'
            }).then((value) {
          if (kDebugMode) {
            print(value.body.toString());
          }
        }).onError((error, stackTrace) {
          if (kDebugMode) {
            print(error);
          }
        });
      });

      if (res == 'sucess') {
        Fluttertoast.showToast(msg: 'Replied Successfully');
      }

      if (res != 'success') {
        if (mounted) showSnackBar(context, res);
      }
      setState(() {
        commentEditingController.text = "";
      });
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  void dispose() {
    commentEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserData?>(context, listen: false);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: notWhite,
        title: Text(
          _languageProvider.currentLanguage == Language.English
              ? 'Comments'
              : 'Comentarios',
        ),
        centerTitle: false,
      ),
      body: LiquidPullToRefresh(
        onRefresh: () async {
          setState(() {});
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.postId)
                    .collection('comments')
                    .snapshots(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (ctx, index) => CommentCard(
                      snap: snapshot.data!.docs[index],
                      postId: widget.postId,
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user!.photoUrl ?? ""),
                    radius: 18,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: commentEditingController,
                        decoration: InputDecoration(
                          hintText: 'Comment as ${user.displayName}',
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        postComment(
                          user.uid!,
                          user.displayName!,
                          user.photoUrl!,
                        );
                        setState(() {});
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                      child: Text(
                        _languageProvider.currentLanguage == Language.English
                            ? 'Post'
                            : 'Publicar',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
