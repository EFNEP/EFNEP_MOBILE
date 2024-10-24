// ignore_for_file: library_private_types_in_public_api, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, no_leading_underscores_for_local_identifiers, unused_field
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:efnep_mobile/services/analytics.dart';
import 'package:efnep_mobile/views/home_page/my_diary/goal_list_view.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../constants/strings.dart';
import '../../../entities/User.dart';
import '../../../main.dart';
import '../app_theme.dart';
import 'package:efnep_mobile/provider/language_provider.dart';

class MealsListView extends StatefulWidget {
  const MealsListView(
      {Key? key, this.mainScreenAnimationController, this.mainScreenAnimation})
      : super(key: key);

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;

  @override
  _MealsListViewState createState() => _MealsListViewState();
}

class _MealsListViewState extends State<MealsListView>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void initState() {
    analytics('Meals', 'MealsListView');
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  late LanguageProvider _languageProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageProvider = Provider.of<LanguageProvider>(
        context); // Get the LanguageProvider instance
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserData?>(context)!;
    final Stream<QuerySnapshot> goalsStream = FirebaseFirestore.instance
        .collection('goals')
        .orderBy('created', descending: true)
        .snapshots(includeMetadataChanges: true);
    return LiquidPullToRefresh(
      onRefresh: () async {
        setState(() {});
      },
      child: StreamBuilder<QuerySnapshot>(
        stream: goalsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text(wentWrong);
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
              child: Text(noData),
            );
          }

          return Column(
            children: [
              // getAppBarUI(),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 2.0,
                  mainAxisSpacing: 2.0,
                  childAspectRatio: 0.9,
                  children:
                      List.generate(snapshot.data!.docs.length, (int index) {
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
                    return AspectRatio(
                      aspectRatio: 0.9,
                      child: Center(
                          child: MealsView(
                        animation: animation,
                        animationController: animationController,
                        userGoals: snapshot.data!.docs[index],
                        currentUserId: user.email ?? "",
                      )),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MealsView extends StatefulWidget {
  const MealsView({
    Key? key,
    this.animationController,
    this.animation,
    required this.userGoals,
    required this.currentUserId,
  }) : super(key: key);

  final AnimationController? animationController;
  final Animation<double>? animation;
  final userGoals;
  final String currentUserId;

  @override
  State<MealsView> createState() => _MealsViewState();
}

class _MealsViewState extends State<MealsView> {
  late LanguageProvider _languageProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageProvider = Provider.of<LanguageProvider>(
        context); // Get the LanguageProvider instance
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final desiredWidth = screenWidth * 0.45;
    int target = int.parse(widget.userGoals['target']) *
        int.parse(widget.userGoals['unit']);

    void _incrementDailyProgress() async {
      final today = DateTime.now();
      final userProgressRef = FirebaseFirestore.instance
          .collection('progress') // collection for progress
          .doc(widget.currentUserId)
          .collection('goals') // Subcollection for user's goals
          .doc(widget.userGoals['name'])
          .collection('daily_progress') // Subcollection for daily progress
          .doc(today.toLocal().toString().split(' ')[0]); // Document for today

      // Increment progress for today
      await userProgressRef.set({
        'progress': FieldValue.increment(1), // Increment by 1, adjust as needed
      }, SetOptions(merge: true)); // Merge to update or create if not exists
      Fluttertoast.showToast(msg: 'Progress updated successfully');
    }

    void _decrementDailyProgress() async {
      final today = DateTime.now();
      final userProgressRef = FirebaseFirestore.instance
          .collection('progress') // collection for progress
          .doc(widget.currentUserId)
          .collection('goals') // Subcollection for user's goals
          .doc(widget.userGoals['name'])
          .collection('daily_progress') // Subcollection for daily progress
          .doc(today.toLocal().toString().split(' ')[0]); // Document for today

      // Get the current progress
      final DocumentSnapshot doc = await userProgressRef.get();
      final currentProgress = doc.exists ? doc['progress'] ?? 0 : 0;

      // Check if the updated progress will be greater than or equal to 0
      if (currentProgress > 0) {
        // Decrement progress for today
        await userProgressRef.set({
          'progress': FieldValue.increment(-1), // Decrement by 1
        }, SetOptions(merge: true)); // Merge to update or create if not exists
        Fluttertoast.showToast(msg: 'Progress updated successfully');
      } else {
        Fluttertoast.showToast(msg: 'Progress cannot be less than 0');
      }
      setState(() {});
    }

    Future<int> _fetchProgress() async {
      final today = DateTime.now();
      final userProgressRef = FirebaseFirestore.instance
          .collection('progress')
          .doc(widget.currentUserId)
          .collection('goals')
          .doc(widget.userGoals['name'])
          .collection('daily_progress')
          .doc(today.toLocal().toString().split(' ')[0]);

      final docSnapshot = await userProgressRef.get();
      if (docSnapshot.exists) {
        return docSnapshot['progress'] ?? 0;
      } else {
        return 0;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SafeArea(
          child: AnimatedBuilder(
            animation: widget.animationController!,
            builder: (BuildContext context, Widget? child) {
              return FadeTransition(
                opacity: widget.animation!,
                child: Transform(
                  transform: Matrix4.translationValues(
                    100 * (1.0 - widget.animation!.value),
                    0.0,
                    0.0,
                  ),
                  child: SizedBox(
                    width: constraints.maxWidth * 0.9,
                    height: constraints.maxHeight * 1.1,
                    child: Stack(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 32,
                            left: 8,
                            right: 8,
                            bottom: 16,
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push<dynamic>(
                                context,
                                MaterialPageRoute<dynamic>(
                                  builder: (BuildContext context) =>
                                      GoalListView(
                                    goal: widget.userGoals['name'],
                                    type: widget.userGoals['type'],
                                    unit: widget.userGoals['unit'],
                                  ),
                                ),
                              );
                            },
                            child: FutureBuilder<int>(
                                future: _fetchProgress(),
                                builder: (context, snapshot) {
                                  int progress = snapshot.data ?? 0;
                                  int progressCount = progress *
                                      int.parse(widget.userGoals['unit']);
                                  return Container(
                                    width: desiredWidth,
                                    decoration: BoxDecoration(
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: HexColor('#6F72CA')
                                              .withOpacity(0.6),
                                          offset: const Offset(1.1, 4.0),
                                          blurRadius: 8.0,
                                        ),
                                      ],
                                      gradient: LinearGradient(
                                        colors: <HexColor>[
                                          HexColor('#87CEEB'),
                                          HexColor('#6F72CA'),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        bottomRight: Radius.circular(8.0),
                                        bottomLeft: Radius.circular(8.0),
                                        topLeft: Radius.circular(8.0),
                                        topRight: Radius.circular(54.0),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 44,
                                        left: 16,
                                        right: 16,
                                        bottom: 8,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _languageProvider
                                                              .currentLanguage ==
                                                          Language.English
                                                      ? 'Goal\t:\t' +
                                                          widget
                                                              .userGoals['name']
                                                      : 'Meta:\t:\t' +
                                                          widget.userGoals[
                                                              'S_name'],
                                                  style: const TextStyle(
                                                    fontFamily:
                                                        AppTheme.fontName,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 10,
                                                    letterSpacing: 0.2,
                                                    color: AppTheme.white,
                                                  ),
                                                  softWrap: true,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 3),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _languageProvider
                                                              .currentLanguage ==
                                                          Language.English
                                                      ? 'Target\t:$target\t' +
                                                          widget
                                                              .userGoals['type']
                                                      : 'Objectivo\t:$target\t' +
                                                          widget.userGoals[
                                                              'type'],
                                                  style: const TextStyle(
                                                    fontFamily:
                                                        AppTheme.fontName,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 10,
                                                    letterSpacing: 0.2,
                                                    color: AppTheme.white,
                                                  ),
                                                  softWrap: true,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 2),
                                            child: Text(
                                              _languageProvider
                                                          .currentLanguage ==
                                                      Language.English
                                                  ? 'Progress: $progressCount\t' +
                                                      widget.userGoals['type']
                                                  : 'Progreso: $progressCount\t' +
                                                      widget.userGoals[
                                                          'type'], // Display progress
                                              style: const TextStyle(
                                                fontFamily: AppTheme.fontName,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 10,
                                                letterSpacing: 0.2,
                                                color: AppTheme.white,
                                              ),
                                              softWrap: true,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 3),
                                                  child: Transform.scale(
                                                    scale: 0.8,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: AppTheme
                                                            .nearlyWhite,
                                                        shape: BoxShape.circle,
                                                        boxShadow: <BoxShadow>[
                                                          BoxShadow(
                                                            color: AppTheme
                                                                .nearlyBlack
                                                                .withOpacity(
                                                                    0.4),
                                                            offset:
                                                                const Offset(
                                                                    8.0, 8.0),
                                                            blurRadius: 8.0,
                                                          ),
                                                        ],
                                                      ),
                                                      child: IconButton(
                                                        icon: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 4),
                                                          child: Icon(
                                                            Icons.add,
                                                            color: HexColor(
                                                                '#6F72CA'),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext
                                                                dialogContext) {
                                                              return AlertDialog(
                                                                title: const Text(
                                                                    'Update Progress'),
                                                                actions: <Widget>[
                                                                  TextButton(
                                                                    child: const Text(
                                                                        'Cancel'),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          dialogContext);
                                                                    },
                                                                  ),
                                                                  TextButton(
                                                                    child: const Text(
                                                                        'Update'),
                                                                    onPressed:
                                                                        () {
                                                                      _incrementDailyProgress();
                                                                      Navigator.pop(
                                                                          dialogContext);
                                                                      setState(
                                                                          () {});
                                                                    },
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 3),
                                                  child: Transform.scale(
                                                    scale: 0.8,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: AppTheme
                                                            .nearlyWhite,
                                                        shape: BoxShape.circle,
                                                        boxShadow: <BoxShadow>[
                                                          BoxShadow(
                                                            color: AppTheme
                                                                .nearlyBlack
                                                                .withOpacity(
                                                                    0.4),
                                                            offset:
                                                                const Offset(
                                                                    8.0, 8.0),
                                                            blurRadius: 8.0,
                                                          ),
                                                        ],
                                                      ),
                                                      child: IconButton(
                                                        icon: Icon(
                                                          Icons.remove,
                                                          color: HexColor(
                                                              '#6F72CA'),
                                                        ),
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext
                                                                dialogContext) {
                                                              return AlertDialog(
                                                                title: const Text(
                                                                    'Update Progress'),
                                                                actions: <Widget>[
                                                                  TextButton(
                                                                    child: const Text(
                                                                        'Cancel'),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          dialogContext);
                                                                    },
                                                                  ),
                                                                  TextButton(
                                                                    child: const Text(
                                                                        'Update'),
                                                                    onPressed:
                                                                        () {
                                                                      _decrementDailyProgress();
                                                                      Navigator.pop(
                                                                          dialogContext);
                                                                      setState(
                                                                          () {});
                                                                    },
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: AppTheme.nearlyWhite.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 8,
                          child: SizedBox(
                            width: 80,
                            height: 80,
                            child: Lottie.asset('assets/a2.json'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
