// ignore_for_file: prefer_final_fields, library_private_types_in_public_api, unused_field
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:efnep_mobile/constants/colors.dart';
import 'package:efnep_mobile/models/authentication/FirebaseAuthServiceModel.dart';
import 'package:efnep_mobile/services/analytics.dart';
import 'package:efnep_mobile/views/plan_pages/single_recipe_tile_widget_view.dart';
import 'package:efnep_mobile/views/plan_pages/title_plan_widget_view.dart';
import 'package:efnep_mobile/views/recipe_pages/main_view.dart';
import 'package:provider/provider.dart';
import '../../entities/User.dart';
import '../home_page/app_theme.dart';
import 'package:efnep_mobile/provider/language_provider.dart';

List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
List<String> S_days = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];

class MyTabBar extends StatefulWidget {
  const MyTabBar({Key? key}) : super(key: key);

  @override
  _MyTabBarState createState() => _MyTabBarState();
}

class _MyTabBarState extends State<MyTabBar> with TickerProviderStateMixin {
  late TabController _tabController;
  late int _initialIndex;
  Map<String, List<String>> dataMap = {};
  late LanguageProvider _languageProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageProvider = Provider.of<LanguageProvider>(context);
  }

  Future<void> fetchDocument() async {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('recepies_id').doc('recepies_id');

    final snapshot = await docRef.get();
    if (snapshot.exists) {
      Map<String, dynamic> rawData = snapshot.data() as Map<String, dynamic>;

      Map<String, List<String>> convertedData = {};
      rawData.forEach((key, value) {
        if (value is List) {
          convertedData[key] = List<String>.from(value);
        }
      });

      setState(() {
        dataMap = convertedData;
      });
    }
  }

  void createSubcollection(String userId, Map<String, List<String>> data) async {
    final firestore = FirebaseFirestore.instance;

    for (int i = 0; i < 7; i++) {
      Map<String, dynamic> dayData = {};

      for (String category in data.keys) {
        List<String> ids = data[category]!;
        ids.shuffle();

        List<String> selectedIds = ids.length > 1 ? ids.sublist(0, 1) : ids;

        dayData[category] = selectedIds;
      }

      await firestore
          .collection('Users')
          .doc(userId)
          .collection('plan')
          .doc('day$i')
          .set(dayData)
          .then((value) async {
        await firestore.collection('Users').doc(userId).update({
          'plan': true,
        });
      });
      Fluttertoast.showToast(msg: 'Plan Created');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDocument();
    analytics('CustomPlan', 'CustomPlanScreenView');
    _initialIndex = DateTime.now().weekday - 1;
    if (_initialIndex < 0) {
      _initialIndex = 0;
    } else if (_initialIndex > 6) {
      _initialIndex = 6;
    }
    _tabController =
        TabController(initialIndex: _initialIndex, length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authServiceProvider = Provider.of<FirebaseAuthServiceModel>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: StreamBuilder<UserData?>(
        stream: authServiceProvider.onAuthStateChanged(),
        builder: (_, AsyncSnapshot<UserData?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          } else if (snapshot.hasError) {
            debugPrint(snapshot.error.toString());
            return const Center(child: Text("Something went wrong!"));
          } else {
            final user = snapshot.data;

            if (user == null) {
              return Center(
                child: Text(languageProvider.currentLanguage == Language.English ? 'No user found' : 'No se encontró usuario'),
              );
            }

            
            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(user.email!)
                  .snapshots(),
              builder: (_, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  );
                } else if (userSnapshot.hasError) {
                  debugPrint(userSnapshot.error.toString());
                  return const Center(child: Text("Something went wrong!"));
                } else {
                  final userDoc = userSnapshot.data;
                  bool hasSubcollection = userDoc != null && userDoc.exists && userDoc.data()!.containsKey("plan");

                  if (hasSubcollection) {
                    return Column(
                      children: [
                        getAppBarUI(languageProvider),
                        TabBar(
                          labelStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          isScrollable: true,
                          controller: _tabController,
                          tabs: [
                            for (int i = 0; i < 7; i++)
                              Tab(
                                height: 70,
                                text: _languageProvider.currentLanguage == Language.English ? days[i] : S_days[i],
                              ),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              for (int i = 0; i < 7; i++)
                                _buildTabViewContent(i, user.email!, languageProvider),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Center(
                      child: ElevatedButton(
                        onPressed: () {
                          createSubcollection(user.email!, dataMap);
                        },
                        child: Text(languageProvider.currentLanguage == Language.English ? 'Lets start' : 'Empecemos'),
                      ),
                    );
                  }
                }
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildTabViewContent(int index, String id, LanguageProvider languageProvider) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(id)
          .collection('plan')
          .doc('day$index')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching plan'));
        } else {
          Map<String, dynamic>? recipes = snapshot.data?.data();
          debugPrint(recipes.toString());
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitlePlanWidgetView(title: languageProvider.currentLanguage == Language.English ? 'Breakfast' : 'Desayuno'),
                  (recipes!['Breakfast'] != null && recipes['Breakfast'].length > 0)
                      ? Column(
                          children: (recipes['Breakfast'] as List<dynamic>)
                              .map(
                                (recipeId) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SingleRecipeTile(
                                    id: recipeId,
                                    type: 'Breakfast',
                                    index: index,
                                    email: id,
                                  ),
                                ),
                              )
                              .toList(),
                        )
                      : const ErrorPlanWidgetView(title: 'No Breakfast'),
                  const SizedBox(
                    height: 10,
                  ),
                  TitlePlanWidgetView(title: languageProvider.currentLanguage == Language.English ? 'Lunch' : 'Almuerzo'),
                  (recipes['Lunch'] != null && recipes['Lunch'].length > 0)
                      ? Column(
                          children: (recipes['Lunch'] as List<dynamic>)
                              .map(
                                (recipeId) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SingleRecipeTile(
                                    id: recipeId,
                                    type: 'Lunch',
                                    index: index,
                                    email: id,
                                  ),
                                ),
                              )
                              .toList(),
                        )
                      : const ErrorPlanWidgetView(title: 'No Lunch'),
                  const SizedBox(
                    height: 10,
                  ),
                  TitlePlanWidgetView(title: languageProvider.currentLanguage == Language.English ? 'Snacks' : 'Bocadillos'),
                  (recipes['Snacks'] != null && recipes['Snacks'].length > 0)
                      ? Column(
                          children: (recipes['Snacks'] as List<dynamic>)
                              .map(
                                (recipeId) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SingleRecipeTile(
                                    id: recipeId,
                                    type: 'Snacks',
                                    index: index,
                                    email: id,
                                  ),
                                ),
                              )
                              .toList(),
                        )
                      : const ErrorPlanWidgetView(title: 'No Snacks'),
                  const SizedBox(
                    height: 10,
                  ),
                  TitlePlanWidgetView(title: languageProvider.currentLanguage == Language.English ? 'Dinner' : 'Cena'),
                  (recipes['Dinner'] != null && recipes['Dinner'].length > 0)
                      ? Column(
                          children: (recipes['Dinner'] as List<dynamic>)
                              .map(
                                (recipeId) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SingleRecipeTile(
                                    id: recipeId,
                                    type: 'Dinner',
                                    email: id,
                                    index: index,
                                  ),
                                ),
                              )
                              .toList(),
                        )
                      : const ErrorPlanWidgetView(title: 'No Dinner'),
                  const SizedBox(
                    height: 10,
                  ),
                  TitlePlanWidgetView(title: languageProvider.currentLanguage == Language.English ? 'Sides' : 'Acompañamientos'),
                  (recipes['Sides'] != null && recipes['Sides'].length > 0)
                      ? Column(
                          children: (recipes['Sides'] as List<dynamic>)
                              .map(
                                (recipeId) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SingleRecipeTile(
                                    id: recipeId,
                                    type: 'Sides',
                                    email: id,
                                    index: index,
                                  ),
                                ),
                              )
                              .toList(),
                        )
                      : const ErrorPlanWidgetView(title: 'No Sides'),
                  const SizedBox(
                    height: 10,
                  ),
                  TitlePlanWidgetView(title: languageProvider.currentLanguage == Language.English ? 'Desserts' : 'Postres'),
                  (recipes['Desserts'] != null &&
                          recipes['Desserts'].length > 0)
                      ? Column(
                          children: (recipes['Desserts'] as List<dynamic>)
                              .map(
                                (recipeId) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SingleRecipeTile(
                                    id: recipeId,
                                    type: 'Desserts',
                                    email: id,
                                    index: index,
                                  ),
                                ),
                              )
                              .toList(),
                        )
                      : const Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: ErrorPlanWidgetView(title: 'No Desserts'),
                        ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget getAppBarUI(LanguageProvider languageProvider) {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32.0),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: AppTheme.grey.withOpacity(0.4),
                  offset: const Offset(1.1, 1.1),
                  blurRadius: 10.0),
            ],
          ),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).padding.top,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 16 - 8.0, bottom: 12 - 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                            languageProvider.currentLanguage == Language.English
    ? 'Meal Plan'
    : 'Plan de Comidas',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontWeight: FontWeight.w700,
                            fontSize: 22 + 6 - 6,
                            letterSpacing: 1.2,
                            color: AppTheme.darkerText,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      child: Text(languageProvider.currentLanguage == Language.English ? 'View All' : 'Ver todo'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const RecipeMainView();
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
