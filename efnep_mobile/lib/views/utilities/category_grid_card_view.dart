import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CategoryGridCardView extends StatefulWidget {
  const CategoryGridCardView({
    Key? key,
    required this.data,
    this.onTap,
    required this.animationController,
    required this.animation,
  }) : super(key: key);
  final QueryDocumentSnapshot? data;
  final Function()? onTap;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  State<CategoryGridCardView> createState() => _CategoryGridCardViewState();
}

class _CategoryGridCardViewState extends State<CategoryGridCardView> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 50 * (1.0 - widget.animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(children: [
                GestureDetector(
                  onTap: widget.onTap,
                  child: Card(
                    elevation: 5,
                    shape: const CircleBorder(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(200),
                      child: CachedNetworkImage(
                        width: 100,
                        height: 100,
                        imageUrl: widget.data!["img"],
                        placeholder: (context, url) => ClipRRect(
                          borderRadius: BorderRadius.circular(200),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.225,
                            height: MediaQuery.of(context).size.width * 0.225,
                            child: Shimmer.fromColors(
                              period: const Duration(milliseconds: 500),
                              baseColor: Colors.grey[400]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
                Text(
                  widget.data!['name'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}
