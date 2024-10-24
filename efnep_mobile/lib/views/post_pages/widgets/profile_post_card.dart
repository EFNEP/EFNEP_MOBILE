// ignore_for_file: prefer_typing_uninitialized_variables, library_private_types_in_public_api, deprecated_member_use
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../constants/colors.dart';
import '../../../entities/User.dart';
import '../resources/firestore_methods.dart';
import '../utils/utils.dart';

class PostProfileCard extends StatefulWidget {
  final snap;
  final String postUrl;
  final String caption;

  const PostProfileCard(
      {Key? key,
      required this.snap,
      required this.postUrl,
      required this.caption})
      : super(key: key);

  @override
  _PostProfileCardState createState() => _PostProfileCardState();
}

class _PostProfileCardState extends State<PostProfileCard> {
  deletePost(String videoId) async {
    try {
      await FireStoreMethods().deletePost(videoId).then((value) =>
          {Fluttertoast.showToast(msg: "Post deleted successfully")});
      setState(() {});
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
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
                                                widget.snap['postId']
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
          CachedNetworkImage(
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 0.5,
            fit: BoxFit.contain,
            imageUrl: widget.postUrl,
            placeholder: (context, url) => Center(
              child: Shimmer(
                gradient: const LinearGradient(
                  colors: [greyLight, greyDark],
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: greyLight,
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ],
      ),
    );
  }
}
