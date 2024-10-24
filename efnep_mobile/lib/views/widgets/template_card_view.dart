// ignore_for_file: use_build_context_synchronously

import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:efnep_mobile/views/all_video_pages/category_pages/video_player_view.dart';
import 'package:shimmer/shimmer.dart';
import '../../constants/colors.dart';

class TemplateCard extends StatefulWidget {
  const TemplateCard(
      {Key? key, this.animationController, this.animation, this.data})
      : super(key: key);

  final QueryDocumentSnapshot? data;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  State<TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<TemplateCard> {
  bool isLoading = false;

  /// Converts the network image to Uint8List format for image_editor_plus processing
  Future<Uint8List> getImageData(String url) async {
    Uint8List bytes = (await NetworkAssetBundle(Uri.parse(url)).load(url))
        .buffer
        .asUint8List();
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: widget.animationController!,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: widget.animation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 50 * (1.0 - widget.animation!.value), 0.0),
                child: InkWell(
                  splashColor: transparent,
                  onTap: () {
                    //
                  },
                  child: SizedBox(
                    child: Column(
                      children: <Widget>[
                        Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(16.0),
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: notWhite,
                                  offset: Offset(0.0, 0.0),
                                  blurRadius: 6.0),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(16.0)),
                            child: AspectRatio(
                              aspectRatio: 1.28,
                              child: CachedNetworkImage(
                                imageUrl: widget.data!["thumb_img"] == ""
                                    ? widget.data!["yt_thumb"]
                                    : widget.data!["thumb_img"],
                                placeholder: (context, url) => SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.225,
                                  height:
                                      MediaQuery.of(context).size.width * 0.225,
                                  child: Shimmer.fromColors(
                                    period: const Duration(milliseconds: 500),
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[200]!,
                                    child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.225,
                          child: OutlinedButton(
                            onPressed: () async {
                              setState(() {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VideoDetailScreen(),
                                  ),
                                );
                              });
                            },
                            child: const Text(
                              "View",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        isLoading
            ? Center(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200.withOpacity(0.5)),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
