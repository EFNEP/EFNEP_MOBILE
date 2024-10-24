// ignore_for_file: no_leading_underscores_for_local_identifiers, unused_import
import 'package:flutter/material.dart';
import 'package:efnep_mobile/services/analytics.dart';
import 'package:efnep_mobile/views/recipe_pages/recipes_view.dart';
import '../../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../provider/language_provider.dart';
import 'package:provider/provider.dart';



List<String> types = [
  "Breakfast",
  "Lunch",
  "Snacks",
  "Dinner",
  "Sides",
  "Desserts"
];

List<String> spanish_types = [
  "Desayuno",
  "Almuerza",
  "Aperitivos",
  "Cena",
  "Acompañamientos",
  "Postres"
];

class RecipeMainView extends StatefulWidget {
  const RecipeMainView({Key? key}) : super(key: key);

  @override
  State<RecipeMainView> createState() => _RecipeMainViewState();
}
class _RecipeMainViewState extends State<RecipeMainView> {
  
   late LanguageProvider _languageProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageProvider = Provider.of<LanguageProvider>(context); // Get the LanguageProvider instance
  }

  @override
  void initState() {
    super.initState();
    analytics('RecipeHome', 'RecipeMainView');
  }


  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
        _languageProvider.currentLanguage == Language.English
        ? "Recipes"
        : "Recetas",
            style: const TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
          ),
          backgroundColor: white,
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: primaryColor,
            indicatorWeight: 4,
            tabs: List.generate(
              types.length,
              (index) => Tab(
                child: Text(
    _languageProvider.currentLanguage == Language.English
        ?   types[index]
        : spanish_types[index],
                  style: const TextStyle(
                      color: black, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: List.generate(
            types.length,
            (index) => RecipeView(
              type: types[index],
            ),
          ),
        ),
      ),
    );
  }
}
