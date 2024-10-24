// ignore_for_file: prefer_typing_uninitialized_variables, library_private_types_in_public_api, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../entities/User.dart';
import '../resources/firestore_methods.dart';
import '../utils/utils.dart';

class VideoProfileCard extends StatefulWidget {
  final snap;
  final String videoUrl;
  final String caption;

  const VideoProfileCard(
      {Key? key,
      required this.snap,
      required this.videoUrl,
      required this.caption})
      : super(key: key);

  @override
  _VideoProfileCardState createState() => _VideoProfileCardState();
}

class _VideoProfileCardState extends State<VideoProfileCard> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  int commentLen = 0;
  bool isLikeAnimating = false;

  @override
  void initState() {
    _controller = VideoPlayerController.network(widget.videoUrl);
    _initializeVideoPlayerFuture = _controller.initialize();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  deletePost(String videoId) async {
    try {
      await FireStoreMethods().deleteVideo(videoId)
      .then((value) => {
        Fluttertoast.showToast(msg: "Post deleted successfully")
      });
      setState(() { });
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserData>(context, listen: false);

    return Card(
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // HEADER SECTION OF THE POST
          Row(
            children: <Widget>[
              widget.snap['uid'].toString() == user.uid
                  ? IconButton(
                      onPressed: () {
                        showDialog(
                          useRootNavigator: false,
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: ListView(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shrinkWrap: true,
                                  children: [
                                    'Delete',
                                  ]
                                      .map(
                                        (e) => InkWell(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 16),
                                              child: Text(e),
                                            ),
                                            onTap: () {
                                              deletePost(
                                                widget.snap['videoId']
                                                    .toString(),
                                              );
                                              // remove the dialog box
                                              Navigator.of(context).pop();
                                              setState(() {});
                                            }),
                                      )
                                      .toList()),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.delete),
                    )
                  : Container(),
            ],
          ),
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return AspectRatio(
                  aspectRatio: _controller.value.aspectRatio * 1.11,
                  child: VideoPlayer(_controller),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),
          // LIKE, COMMENT SECTION OF THE POST
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
