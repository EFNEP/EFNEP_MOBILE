// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:efnep_mobile/provider/language_provider.dart';
import 'package:efnep_mobile/views/plan_pages/title_plan_widget_view.dart';
import 'package:efnep_mobile/views/recipe_pages/recepie_detail_view.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SingleRecipeTile extends StatefulWidget {
  final String id;
  final String type;
  final int index;
  final String email;
  const SingleRecipeTile(
      {Key? key,
      required this.id,
      required this.type,
      required this.index,
      required this.email})
      : super(key: key);

  @override
  State<SingleRecipeTile> createState() => _SingleRecipeTileState();
}

class _SingleRecipeTileState extends State<SingleRecipeTile> {
  late LanguageProvider _languageProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageProvider = Provider.of<LanguageProvider>(
        context); // Get the LanguageProvider instance
  }

  Future<List<Map<String, dynamic>>> fetchRecipesByType(String mealType) async {
    final firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
        .collection('recepies')
        .where('type', isEqualTo: mealType)
        .get();

    List<Map<String, dynamic>> recipes = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
        in querySnapshot.docs) {
      recipes.add(documentSnapshot.data());
    }

    return recipes;
  }

  void _openEditDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchRecipesByType(
              widget.type), // Fetch recipes of the selected type
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error fetching recipes'));
            } else {
              List<Map<String, dynamic>> recipes = snapshot.data ?? [];

              return AlertDialog(
                title: Text(
                  _languageProvider.currentLanguage == Language.English
                      ? 'Select a new Recipe'
                      : 'Seleccione una nueva receta',
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        recipes.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: ErrorPlanWidgetView(title: 'No Recipes'),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: recipes.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: CachedNetworkImage(
                                        imageUrl: recipes[index]['thumb_img'],
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                    title: Text(
                                      _languageProvider.currentLanguage ==
                                              Language.English
                                          ? recipes[index]['title']
                                          : recipes[index]['S_title'],
                                    ),
                                    // subtitle: Text(
                                    //   recipes[index]['description']
                                    //               .toString()
                                    //               .length >
                                    //           50
                                    //       ? '${recipes[index]['description'].toString().substring(0, 50)}...'
                                    //       : recipes[index]['description']
                                    //           .toString(),
                                    // ),
                                    onTap: () async {
                                      // Handle recipe selection
                                      await updateSelectedRecipe(
                                          recipes[index]['id'], widget.index);
                                      Navigator.pop(
                                          context); // Close the dialog
                                    },
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      _languageProvider.currentLanguage == Language.English
                          ? 'Cancel'
                          : 'Cancelar',
                    ),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  Future<void> updateSelectedRecipe(String newRecipeId, int dayIndex) async {
    final firestore = FirebaseFirestore.instance;

    // Construct the document path for the selected day
    String dayDocumentPath = 'day$dayIndex';

    // Fetch the existing recipes for the selected day
    DocumentSnapshot<Map<String, dynamic>> daySnapshot = await firestore
        .collection('Users')
        .doc(widget.email)
        .collection('plan')
        .doc(dayDocumentPath)
        .get();

    if (daySnapshot.exists) {
      Map<String, dynamic> dayData = daySnapshot.data()!;

      // Update the recipe list by removing the current recipe ID and adding the new one
      List<String> currentRecipeIds = dayData[widget.type].cast<String>();
      currentRecipeIds.remove(widget.id); // Remove the current recipe ID
      currentRecipeIds.add(newRecipeId); // Add the new recipe ID

      dayData[widget.type] = currentRecipeIds;

      // Update the subcollection document with the modified data
      await firestore
          .collection('Users')
          .doc(widget.email)
          .collection('plan')
          .doc(dayDocumentPath)
          .set(dayData);

      Fluttertoast.showToast(msg: 'Recipe updated');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("recepies")
            .doc(widget.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching plan'));
          }

          if (snapshot.data == null || snapshot.data!.data() == null) {
            return ListTile(
              title: Text(
                _languageProvider.currentLanguage == Language.English
                    ? "Select Your Recipe"
                    : "Selecciona tu receta",
              ),
              leading: CachedNetworkImage(
                imageUrl:
                    "https://brent-mccardle.org/img/placeholder-image.png",
                placeholder: (context, url) => const Shimmer(
                  gradient: LinearGradient(
                    colors: [Colors.grey, Colors.grey],
                  ),
                  child: SizedBox(
                    height: 80,
                    width: 80,
                  ),
                ),
                height: 80,
                width: 80,
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit_note_sharp),
                onPressed: () {
                  _openEditDialog();
                },
              ),
            );
          }

          if (snapshot.data!.data()!.isEmpty) {
            return ListTile(
              title: Text(
                _languageProvider.currentLanguage == Language.English
                    ? "Select Your Recipe"
                    : "Selecciona tu receta",
              ),
              leading: CachedNetworkImage(
                imageUrl:
                    "https://brent-mccardle.org/img/placeholder-image.png",
                placeholder: (context, url) => const Shimmer(
                  gradient: LinearGradient(
                    colors: [Colors.grey, Colors.grey],
                  ),
                  child: SizedBox(
                    height: 80,
                    width: 80,
                  ),
                ),
                height: 80,
                width: 80,
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit_note_sharp),
                onPressed: () {
                  _openEditDialog();
                },
              ),
            );
          } else {
            return ListTile(
              title: Text(_languageProvider.currentLanguage == Language.English
                  ? snapshot.data!['title']
                  : snapshot.data!['S_title']),

              // subtitle: Text(snapshot.data!['description'].toString().length >
              //         50
              //     ? '${snapshot.data!['description'].toString().substring(0, 50)}...'
              //     : snapshot.data!['description'].toString()),
              leading: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return RecipeDetailScreen(
                          id: snapshot.data!['id'],
                        );
                      },
                    ),
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: snapshot.data!['thumb_img'],
                  placeholder: (context, url) => const Shimmer(
                    gradient: LinearGradient(
                      colors: [Colors.grey, Colors.grey],
                    ),
                    child: SizedBox(
                      height: 80,
                      width: 80,
                    ),
                  ),
                  height: 80,
                  width: 80,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit_note_sharp),
                onPressed: () {
                  _openEditDialog();
                },
              ),
            );
          }
        });
  }
}
