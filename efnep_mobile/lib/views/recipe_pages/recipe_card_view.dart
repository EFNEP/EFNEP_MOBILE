// ignore_for_file: use_build_context_synchronously

import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:efnep_mobile/services/analytics.dart';
import 'package:efnep_mobile/views/recipe_pages/recepie_detail_view.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../constants/colors.dart';
import '../../provider/language_provider.dart';

class RecipeCard extends StatefulWidget {
  const RecipeCard(
      {Key? key, this.animationController, this.animation, this.data})
      : super(key: key);

  final QueryDocumentSnapshot? data;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool isLoading = false;

late LanguageProvider _languageProvider;
    @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      _languageProvider = Provider.of<LanguageProvider>(context); // Get the LanguageProvider instance
    }
  /// Converts the network image to Uint8List format for image_editor_plus processing
  Future<Uint8List> getImageData(String url) async {
    Uint8List bytes = (await NetworkAssetBundle(Uri.parse(url)).load(url))
        .buffer
        .asUint8List();
    return bytes;
  }

   @override
  void initState() {
    super.initState();
    analytics('Recipe', 'RecipeCard');
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: widget.animationController!,
          builder: (BuildContext context, Widget? child) {
            final screenWidth = MediaQuery.of(context).size.width;

            return FadeTransition(
              opacity: widget.animation!,
              child: Transform(
                transform: Matrix4.translationValues(
                  0.0,
                  50 * (1.0 - widget.animation!.value),
                  0.0,
                ),
                child: InkWell(
                  splashColor: Colors.transparent,
                  onTap: () {
                    // Handle onTap
                  },
                  child: SizedBox(
                    width: screenWidth * 0.5,
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: screenWidth * 0.4,
                          height: screenWidth * 0.3 * 1,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(16.0),
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: notWhite,
                                offset: Offset(0.0, 0.0),
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(16.0)),
                            child: AspectRatio(
                              aspectRatio: 3 / 4, // Adjust as needed
                              child: CachedNetworkImage(
                                imageUrl: widget.data!["thumb_img"] == ""
                                    ? widget.data!["recepie_img"]
                                    : widget.data!["thumb_img"],
                                placeholder: (context, url) => SizedBox(
                                  width: screenWidth * 0.225,
                                  height: screenWidth * 0.225,
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
                        const SizedBox(
                          height: 4,
                        ),
                        SizedBox(
                          width: screenWidth * 0.3,
                          child: Text(
    _languageProvider.currentLanguage == Language.English
        ? widget.data!["title"]
        : widget.data!["S_title"],
                            
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: screenWidth * 0.3,
                          child: OutlinedButton(
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetailScreen(
                                    id: widget.data!["id"],
                                    title: widget.data!["title"],
                                  ),
                                ),
                              );
                            },
                            child: Text(
    _languageProvider.currentLanguage == Language.English
        ? 'View Details'
        : 'Ver Detalles',
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
                        color: Colors.grey.shade200.withOpacity(0.5),
                      ),
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
