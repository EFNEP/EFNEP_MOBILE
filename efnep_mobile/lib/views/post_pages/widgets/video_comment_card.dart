// ignore_for_file: prefer_typing_uninitialized_variables
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:efnep_mobile/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../entities/User.dart';
import '../resources/firestore_methods.dart';
import '../utils/utils.dart';
import 'reply_card.dart';

class VideoCommentCard extends StatefulWidget {
  final snap;
  final String videoId;
  const VideoCommentCard({Key? key, required this.snap, required this.videoId})
      : super(key: key);

  @override
  State<VideoCommentCard> createState() => _VideoCommentCardState();
}

class _VideoCommentCardState extends State<VideoCommentCard> {
  bool _showReplies = false;
  final TextEditingController replyEditingController = TextEditingController();
  List<Map<String, dynamic>> replies = [];
  static final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    loadReplies();
    super.initState();
  }

  void postVideoReply(String commentId) async {
    try {
      String res = await FireStoreMethods().postVideoReply(
        widget.videoId,
        replyEditingController.text,
        commentId, // You need to pass the commentId to identify the comment being replied to
      );

      if (res == 'sucess') {
        Fluttertoast.showToast(msg: 'Replied Successfully');
      }

      if (res != 'success') {
        if (mounted) showSnackBar(context, res);
      }
      setState(() {
        replyEditingController.text = "";
      });
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  void loadReplies() async {
    try {
      List<Map<String, dynamic>> replyData = await FireStoreMethods()
          .getVideoReplies(widget.videoId, widget.snap.data()['commentId']);

      if (mounted) {
        setState(() {
          replies = replyData;
        });
      }
    } catch (err) {
      debugPrint('Error loading replies: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserData?>(context, listen: false);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  widget.snap.data()['profilePic'],
                ),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: widget.snap.data()['name'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: black.withOpacity(.6)),
                            ),
                            TextSpan(
                              text: ' ${widget.snap.data()['text']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w400, color: black),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          DateFormat.yMMMd().format(
                            widget.snap.data()['datePublished'].toDate(),
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showReplies = !_showReplies;
                  });
                },
                icon: Icon(
                  _showReplies
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 24,
                ),
              ),
            ],
          ),
          _showReplies
              ? Padding(
                  padding: const EdgeInsets.only(left: 56, top: 8),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Input field for replying
                        Row(
                          children: [
                            Expanded(
                              child: Form(
                                key: _formKey,
                                child: TextFormField(
                                  controller: replyEditingController,
                                  key: const Key('replyTextField'),
                                  style: TextStyle(
                                    color: black.withOpacity(.6),
                                    fontSize: 14,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Reply as ${user?.displayName}',
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
                            TextButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  postVideoReply(
                                      widget.snap.data()['commentId']);
                                  setState(() {});
                                }
                              },
                              child: const Text(
                                'Reply',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: replies.length,
                          itemBuilder: (context, index) {
                            return ReplyCard(reply: replies[index]);
                          },
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
