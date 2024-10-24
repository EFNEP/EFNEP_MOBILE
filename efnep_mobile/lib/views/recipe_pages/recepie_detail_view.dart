// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, use_key_in_widget_constructors, avoid_unnecessary_containers, library_private_types_in_public_api, prefer_interpolation_to_compose_strings
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:efnep_mobile/services/analytics.dart';
import 'package:shimmer/shimmer.dart';
import '../../views/recipe_pages/title_widget_view.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../entities/User.dart';
import 'package:provider/provider.dart';
 import 'package:efnep_mobile/provider/language_provider.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String id;
  final String? title;
  const RecipeDetailScreen({
    Key? key,
    required this.id,
    this.title,
  }) : super(key: key);
  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final double infoHeight = 364.0;
  double opacity2 = 0.0;
  bool isCurrentDayUnlocked = false;
  UserData? user;


   late LanguageProvider _languageProvider;
    @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      _languageProvider = Provider.of<LanguageProvider>(context); // Get the LanguageProvider instance
    }
  @override
  void initState() {
    super.initState();
    analytics('Recipe_${widget.title}', 'RecipeDetailScreen');
  }

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot<Map<String, dynamic>>> recipeStream =
        FirebaseFirestore.instance
            .collection('recepies')
            .doc(widget.id)
            .snapshots(includeMetadataChanges: true);
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
  _languageProvider.currentLanguage == Language.English ? 'Details' : 'Detalles',
),
          backgroundColor: white,
          elevation: 0,
        ),
        body: StreamBuilder(
          stream: recipeStream,
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasError) {
              return Scaffold(
                body: const Text(
                  wentWrong,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: const Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                ),
              );
            }
            if (!snapshot.data!.exists) {
              return Scaffold(
                body: const Center(
                  child: Text(
                    noData,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              );
            }
            return SingleChildScrollView(
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CachedNetworkImage(
                      imageUrl: snapshot.data!.data()!.containsKey('servings')
                          ? snapshot.data!['thumb_img']
                          : "https://brent-mccardle.org/img/placeholder-image.png",
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height * 0.4,
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
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: TitleWidgetView(
                          title: _languageProvider.currentLanguage == Language.English ? snapshot.data!.data()!.containsKey('title') &&
                                  snapshot.data!.data()!.containsKey('type')
                              ? snapshot.data!['title'] +
                                  "\t-\t" +
                                  snapshot.data!['type']
                              : "-": snapshot.data!.data()!.containsKey('S_title') &&
          snapshot.data!.data()!.containsKey('type')
      ? snapshot.data!['S_title'] + "\t-\t" + snapshot.data!['type']
      : "-",
),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 8, left: 16),
                      child: Text(
                          snapshot.data!.data()!.containsKey('meal_type')
                              ? "Type\t:\t" + snapshot.data!['meal_type']
                              : "-"),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    TitleWidgetView(
  title: _languageProvider.currentLanguage == Language.English ? 'Servings' : 'Porciones',
),

                    Padding(
                      padding: EdgeInsets.only(top: 8, left: 16, right: 8),
                      child: Text(_languageProvider.currentLanguage == Language.English ?
                        snapshot.data!.data()!.containsKey('servings')
                            ? snapshot.data!['servings'].toString()
                            : "-": snapshot.data!.data()!.containsKey('S_servings')
                            ? snapshot.data!['S_servings'].toString()
                            : "-",
                        style: TextStyle(fontSize: 16.0),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    TitleWidgetView(
  title: _languageProvider.currentLanguage == Language.English ? 'Ingredients' : 'Ingredientes',
),

                    Padding(
                      padding: EdgeInsets.only(top: 8, left: 16, right: 8),
                      child: Text( _languageProvider.currentLanguage == Language.English ?
                        snapshot.data!.data()!.containsKey('ingredients')
                            ? snapshot.data!['ingredients'].toString()
                            : "-":snapshot.data!.data()!.containsKey('S_ingredients')
                            ? snapshot.data!['S_ingredients'].toString()
                            : "-",
                        style: TextStyle(fontSize: 16.0),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                   TitleWidgetView(
  title: _languageProvider.currentLanguage == Language.English ? 'Instructions' : 'Instrucciones',
),

                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(_languageProvider.currentLanguage == Language.English ? 
                        snapshot.data!.data()!.containsKey('description')
                            ? snapshot.data!['description'].toString()
                            : "-": 
                        snapshot.data!.data()!.containsKey('S_description')
                            ? snapshot.data!['S_description'].toString()
                            : "-",
                        style: TextStyle(fontSize: 16.0),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    TitleWidgetView(
  title: _languageProvider.currentLanguage == Language.English ? 'Nutrition' : 'Nutrición',
),

                    Padding(
                      padding: EdgeInsets.only(top: 8, left: 16),
                      child: Text(_languageProvider.currentLanguage == Language.English ?
                        "Carbs\t:\t " +
                            (snapshot.data!.data()!.containsKey('carbs')
                                ? snapshot.data!['carbs']
                                : "-"):"Carbohidratos\t:\t " +
                            (snapshot.data!.data()!.containsKey('carbs')
                                ? snapshot.data!['carbs']
                                : "-"),
                        style: TextStyle(fontSize: 16.0),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 8, left: 16),
                      child: Text(_languageProvider.currentLanguage == Language.English ? 
                        "Fat\t:\t " +
                            (snapshot.data!.data()!.containsKey('fat')
                                ? snapshot.data!['fat']
                                : "-"):"Grasa\t:\t " +
                            (snapshot.data!.data()!.containsKey('fat')
                                ? snapshot.data!['fat']
                                : "-"),
                        style: TextStyle(fontSize: 16.0),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 8, left: 16),
                      child: Text(_languageProvider.currentLanguage == Language.English ? 
                        "Calories\t:\t " +
                            (snapshot.data!.data()!.containsKey('calories')
                                ? snapshot.data!['calories']
                                : "-"):"Calorías\t:\t" +
                            (snapshot.data!.data()!.containsKey('calories')
                                ? snapshot.data!['calories']
                                : "-"),
                        style: TextStyle(fontSize: 16.0),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 8, left: 16),
                      child: Text(_languageProvider.currentLanguage == Language.English ? 
                        "Proteins\t:\t " +
                            (snapshot.data!.data()!.containsKey('protein')
                                ? snapshot.data!['protein']
                                : "-"):"Proteínas\t:\t" +
                            (snapshot.data!.data()!.containsKey('calories')
                                ? snapshot.data!['calories']
                                : "-"),
                        style: TextStyle(fontSize: 16.0),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                      TitleWidgetView(
  title: _languageProvider.currentLanguage == Language.English ? 'Source' : 'Fuente',
),

                    Padding(
                      padding: EdgeInsets.only(top: 8, left: 16),
                      child: Text(
                        snapshot.data!.data()!.containsKey('source')
                            ? snapshot.data!['source'].toString()
                            : "-",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: primaryColor,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}