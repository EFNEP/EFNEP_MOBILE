// ignore_for_file: library_private_types_in_public_api, no_leading_underscores_for_local_identifiers
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:efnep_mobile/views/recipe_pages/recipe_card_view.dart';
import '../../../constants/colors.dart';
import '../../../constants/strings.dart';

class RecipeView extends StatefulWidget {
  final String type;
  const RecipeView({Key? key, required this.type})
      : super(key: key);

  @override
  _RecipeViewState createState() => _RecipeViewState();
}

class _RecipeViewState extends State<RecipeView> with TickerProviderStateMixin {
  AnimationController? animationController;
  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _recipeStream = FirebaseFirestore.instance
        .collection('recepies')
        .where('type', isEqualTo: widget.type)
        .snapshots(includeMetadataChanges: true);
    return StreamBuilder<QuerySnapshot>(
      stream: _recipeStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text(
            wentWrong,
            style: TextStyle(fontWeight: FontWeight.w500),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          );
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              noData,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          );
        }
        try {
          return GridView(
            padding: const EdgeInsets.all(8),
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 5.0,
              crossAxisSpacing: 5.0,
              childAspectRatio: 0.8,
            ),
            children: List<Widget>.generate(
              snapshot.data!.docs.length,
              (int index) {
                final int count = snapshot.data!.docs.length;
                final Animation<double> animation =
                    Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animationController!,
                    curve: Interval((1 / count) * index, 1.0,
                        curve: Curves.fastOutSlowIn),
                  ),
                );
                animationController?.forward();
                return RecipeCard(
                  animation: animation,
                  animationController: animationController,
                  data: snapshot.data!.docs[index],
                );
              },
            ),
          );
        } catch (e) {
          return const Center(
            child: Text(
              wentWrong,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          );
        }
      },
    );
  }
}
