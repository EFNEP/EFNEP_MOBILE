// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, use_key_in_widget_constructors, avoid_unnecessary_containers, library_private_types_in_public_api, unrelated_type_equality_checks, unused_local_variable
import 'dart:core';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:efnep_mobile/services/analytics.dart';
import 'package:efnep_mobile/utils/date_time.dart';
import 'package:efnep_mobile/views/widgets/video_card_widget_view.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../entities/User.dart';
import '../../utils/fetch_user.dart';
import '../home_page/app_theme.dart';
import '../widgets/timer_widget_view.dart';
import 'package:efnep_mobile/provider/language_provider.dart';

class CourseDetailScreen extends StatefulWidget {
  final String? dayNumber;
  final String? weekNumber;
  const CourseDetailScreen({
    Key? key,
    this.dayNumber,
    this.weekNumber,
  }) : super(key: key);
  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late LanguageProvider _languageProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageProvider = Provider.of<LanguageProvider>(
        context); // Get the LanguageProvider instance
  }

  final double infoHeight = 364.0;
  bool isCurrentDayUnlocked = false;
  UserData? user;

  @override
  void initState() {
    setData();
analytics('CourseDetailScreen_${widget.weekNumber}_${widget.dayNumber}', 'CourseDetailScreen');
    Future.delayed(Duration.zero, () {
      user = Provider.of<UserData?>(context, listen: false);
      debugPrint(user.toString());
    });
    super.initState();
  }

  Future<bool> checkWeekDayUnlocked(
      String week, String day, String userId) async {
    try {
      int dayInt = int.parse(day);
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> courseData =
            userData['course'] as Map<String, dynamic>;
        bool isWeekUnlocked = courseData.containsKey(week) &&
            courseData[week][dayInt - 1] == true;
        return isWeekUnlocked;
      }
    } catch (e) {
      // Handle errors if any
      debugPrint('Error fetching user data: $e');
    }
    return false;
  }

  void updateUserData(String email, int week, int day) {
    // Update the user's data to mark the content for the specified day as unlocked
    // This logic may vary depending on how your user data is structured
    // For example, if user data is stored in a database, you would update the corresponding document or record
  }

  Future<void> updateWeekAndDay() async {
    String? week = widget.weekNumber;
    int day = int.parse(widget.dayNumber ?? "1");
    DateTime currentTime = DateTime.now();
    DateTime unlockTime = currentTime.add(const Duration(minutes: 0));
    try {
      // Fetch the user document
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.email ?? "")
          .get();

      if (userDoc.exists) {
        // Get the 'course' field from the user document
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> courseData =
            userData['course'] as Map<String, dynamic>;

        // Update the specific week and day index
        String weekKey = 'Week $week';
        if (courseData.containsKey(weekKey)) {
          List<bool> weekData = List.from(courseData[weekKey]);
          if (day >= 1 && day <= weekData.length) {
            if (day != 7) {
              weekData[day - 1] = true;
              courseData[weekKey] = weekData;
            }
          }
        }

        int newWeek =
            (day == 7) ? int.parse(week ?? "1") + 1 : int.parse(week ?? "1");

        // If the new week key exists in courseData, update its initial index to true
        if (day == 7) {
          if (courseData.containsKey('Week $newWeek')) {
            courseData['Week $week'][6] = true;
            courseData['Week $newWeek'][0] = true;
          }
        }
        if (day == 7) {
          int newWeek = int.parse(widget.weekNumber ?? '1') + 1;
          week = newWeek.toString();
          // Update the 'course' field in the user document
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(user!.email)
              .update({
            'course': courseData,
            'currentWeek': "Week $week",
            'currentDay': 1,
            'currentTime': currentTime,
            'unlockTime': unlockTime
          });
        } else {
          // Update the 'course' field in the user document
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(user!.email)
              .update({
            'course': courseData,
            'currentWeek': "Week $week",
            'currentDay': day,
            'currentTime': currentTime,
            'unlockTime': unlockTime
          });
        }
      }
    } catch (e) {
      // Handle errors if any
      debugPrint('Error updating user data: $e');
    }
  }

  Future<void> setData() async {
    // Fetch data based on the passed weekNumber and dayNumber
    String? week = widget.weekNumber;
    String? day = widget.dayNumber;
    if (week != null && day != null) {
      // Fetch data using week and day, and check if it is unlocked in the user document
      // Replace this with your own logic to fetch and check data from Firestore or any other data source
      bool isUnlocked =
          await checkWeekDayUnlocked(week, day, user!.email ?? "");
      setState(() {
        isCurrentDayUnlocked = isUnlocked;
      });
    }
  }

  int extractFirstNumber(String input) {
    String currentNumber = "";

    for (int i = 0; i < input.length; i++) {
      if (input[i].compareTo('0') >= 0 && input[i].compareTo('9') <= 0) {
        currentNumber += input[i];
      } else if (currentNumber.isNotEmpty) {
        return int.parse(currentNumber);
      }
    }

    if (currentNumber.isNotEmpty) {
      return int.parse(currentNumber);
    }

    return 0; // Return a default value if no number found
  }

  @override
  Widget build(BuildContext context) {
    final double tempHeight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).size.width / 1.2) +
        24.0;
    final Stream<QuerySnapshot> videoStream = FirebaseFirestore.instance
        .collection('videos')
        .where('week', isEqualTo: "Week ${widget.weekNumber}")
        .where('day', isEqualTo: "Day ${widget.dayNumber}")
        .snapshots(includeMetadataChanges: true);
    final Stream<QuerySnapshot> tipStream = FirebaseFirestore.instance
        .collection('tips')
        .where('week', isEqualTo: "Week ${widget.weekNumber}")
        .where('day', isEqualTo: "Day ${widget.dayNumber}")
        .snapshots(includeMetadataChanges: true);
    String week = "Week ${widget.weekNumber}";
    final Stream<DocumentSnapshot<Map<String, dynamic>>> weekTitleStream =
        FirebaseFirestore.instance
            .collection("week-titles")
            .doc(week)
            .snapshots(includeMetadataChanges: true);

    return StreamBuilder<QuerySnapshot>(
        stream: videoStream,
        builder: (context, snapshot) {
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
          if (snapshot.data!.docs.isEmpty) {
            return StreamBuilder<QuerySnapshot>(
                stream: tipStream,
                builder: (context, snapshot) {
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
                  if (snapshot.data!.docs.isEmpty) {
                    return Scaffold(
                      body: const Center(
                        child: Text(
                          noData,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: List<Widget>.generate(snapshot.data!.docs.length,
                        (int index) {
                      return Expanded(
                        child: Container(
                          color: AppTheme.nearlyWhite,
                          child: Scaffold(
                            appBar: AppBar(
                              backgroundColor: white,
                              centerTitle: true,
                              title: StreamBuilder<
                                      DocumentSnapshot<Map<String, dynamic>>>(
                                  stream: weekTitleStream,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<
                                              DocumentSnapshot<
                                                  Map<String, dynamic>>>
                                          snapshot) {
                                    if (!snapshot.hasData) {
                                      return Text(
                                        _languageProvider.currentLanguage ==
                                                Language.English
                                            ? 'Week ${widget.weekNumber}, Day ${widget.dayNumber}'
                                            : 'Semana ${widget.weekNumber}, Día ${widget.dayNumber}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 22,
                                          letterSpacing: 0.27,
                                          color: AppTheme.darkerText,
                                        ),
                                      );
                                    }

                                    if (snapshot.hasError) {
                                      return Text(
                                        _languageProvider.currentLanguage ==
                                                Language.English
                                            ? "Error Occurred"
                                            : "Error ocurrido",
                                      );
                                    }

                                    if (snapshot.data == null ||
                                        snapshot.data!.data() == null) {
                                      return Text(
                                        _languageProvider.currentLanguage ==
                                                Language.English
                                            ? 'Week ${widget.weekNumber}, Day ${widget.dayNumber}'
                                            : 'Semana ${widget.weekNumber}, Día ${widget.dayNumber}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 22,
                                          letterSpacing: 0.27,
                                          color: AppTheme.darkerText,
                                        ),
                                      );
                                    }

                                    if (snapshot.data!.data()!.isEmpty) {
                                      return Text(
                                        _languageProvider.currentLanguage ==
                                                Language.English
                                            ? 'Week ${widget.weekNumber}, Day ${widget.dayNumber}'
                                            : 'Semana ${widget.weekNumber}, Día ${widget.dayNumber}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 22,
                                          letterSpacing: 0.27,
                                          color: AppTheme.darkerText,
                                        ),
                                      );
                                    }
                                    // if(snapshot.data)
                                    return Text(
                                      snapshot.data!
                                              .data()!
                                              .containsKey('title')
                                          ? _languageProvider.currentLanguage ==
                                                  Language.English
                                              ? snapshot.data!['title'] +
                                                  "\t-\tDay ${widget.dayNumber}"
                                              : snapshot.data!['S_title'] +
                                                  "\t-\tDía ${widget.dayNumber}"
                                          : _languageProvider.currentLanguage ==
                                                  Language.English
                                              ? 'Week ${widget.weekNumber}, Day ${widget.dayNumber}'
                                              : 'Semana ${widget.weekNumber}, Día ${widget.dayNumber}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 22,
                                        letterSpacing: 0.27,
                                        color: AppTheme.darkerText,
                                      ),
                                    );
                                  }),
                              leading: IconButton(
                                onPressed: () {
                                  // Navigate to the homepage when back button is pressed
                                  Navigator.pushReplacementNamed(
                                      context, '/home');
                                },
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: black,
                                ),
                              ),
                              elevation: 0,
                            ),
                            backgroundColor: Colors.transparent,
                            body: LiquidPullToRefresh(
                              onRefresh: () async {
                                setState(() {});
                              },
                              child: Stack(
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      (snapshot.data!.docs[index].data()
                                                      as Map<String, dynamic>?)!
                                                  .containsKey('imageURL') ==
                                              true
                                          ? AspectRatio(
                                              aspectRatio: 1.2,
                                              child: GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                          _languageProvider
                                                                      .currentLanguage ==
                                                                  Language
                                                                      .English
                                                              ? 'Preview'
                                                              : 'Vista previa',
                                                          // Your text style properties here
                                                        ),
                                                        content:
                                                            CachedNetworkImage(
                                                          imageUrl: snapshot
                                                                          .data!
                                                                          .docs[
                                                                      index][
                                                                  'imageURL'] ??
                                                              'https://brent-mccardle.org/img/placeholder-image.png',
                                                          fit: BoxFit.contain,
                                                          placeholder:
                                                              (context, url) =>
                                                                  Center(
                                                            child: Shimmer(
                                                              gradient:
                                                                  const LinearGradient(
                                                                colors: [
                                                                  greyLight,
                                                                  greyDark
                                                                ],
                                                              ),
                                                              child: Container(
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  color:
                                                                      greyLight,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              const Icon(
                                                                  Icons.error),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Text(
                                                              _languageProvider
                                                                          .currentLanguage ==
                                                                      Language
                                                                          .English
                                                                  ? 'Close'
                                                                  : 'Cerrar',
                                                            ),
                                                          )
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                child: CachedNetworkImage(
                                                  imageUrl: snapshot
                                                              .data!.docs[index]
                                                          ['imageURL'] ??
                                                      "https://brent-mccardle.org/img/placeholder-image.png",
                                                  fit: BoxFit.contain,
                                                  placeholder: (context, url) =>
                                                      Center(
                                                    child: Shimmer(
                                                      gradient:
                                                          const LinearGradient(
                                                        colors: [
                                                          greyLight,
                                                          greyDark
                                                        ],
                                                      ),
                                                      child: Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: greyLight,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                ),
                                              ),
                                            )
                                          : AspectRatio(
                                              aspectRatio: 1.2,
                                              child: GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                          _languageProvider
                                                                      .currentLanguage ==
                                                                  Language
                                                                      .English
                                                              ? 'Preview'
                                                              : 'Vista previa',
                                                        ),
                                                        content:
                                                            CachedNetworkImage(
                                                          imageUrl:
                                                              'https://brent-mccardle.org/img/placeholder-image.png',
                                                          fit: BoxFit.contain,
                                                          placeholder:
                                                              (context, url) =>
                                                                  Center(
                                                            child: Shimmer(
                                                              gradient:
                                                                  const LinearGradient(
                                                                colors: [
                                                                  greyLight,
                                                                  greyDark
                                                                ],
                                                              ),
                                                              child: Container(
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  color:
                                                                      greyLight,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              const Icon(
                                                                  Icons.error),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Text(
                                                              _languageProvider
                                                                          .currentLanguage ==
                                                                      Language
                                                                          .English
                                                                  ? 'Close'
                                                                  : 'Cerrar',
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      'https://brent-mccardle.org/img/placeholder-image.png',
                                                  fit: BoxFit.contain,
                                                  placeholder: (context, url) =>
                                                      Center(
                                                    child: Shimmer(
                                                      gradient:
                                                          const LinearGradient(
                                                        colors: [
                                                          greyLight,
                                                          greyDark
                                                        ],
                                                      ),
                                                      child: Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: greyLight,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                  Positioned(
                                    top: (MediaQuery.of(context).size.width /
                                            1.2) -
                                        30.0,
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.nearlyWhite,
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(32.0),
                                            topRight: Radius.circular(32.0)),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                              color: AppTheme.grey
                                                  .withOpacity(0.2),
                                              offset: const Offset(1.1, 1.1),
                                              blurRadius: 10.0),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8, right: 8, top: 0),
                                        child: SingleChildScrollView(
                                          child: Container(
                                            constraints: BoxConstraints(
                                                minHeight: infoHeight,
                                                maxHeight:
                                                    tempHeight > infoHeight
                                                        ? tempHeight
                                                        : infoHeight),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 0,
                                                          left: 18,
                                                          right: 16,
                                                          bottom: 0),
                                                  child: Text(
                                                    _languageProvider
                                                                .currentLanguage ==
                                                            Language.English
                                                        ? snapshot.data!
                                                                .docs[index]
                                                            ['title']
                                                        : snapshot.data!
                                                                .docs[index]
                                                            ['S_title'],
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 22,
                                                      letterSpacing: 0.27,
                                                      color:
                                                          AppTheme.darkerText,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 16,
                                                          right: 16,
                                                          bottom: 8,
                                                          top: 16),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Row(
                                                          children: <Widget>[
                                                            StreamBuilder<
                                                                    DocumentSnapshot<
                                                                        Map<String,
                                                                            dynamic>>>(
                                                                stream:
                                                                    weekTitleStream,
                                                                builder: (BuildContext
                                                                        context,
                                                                    AsyncSnapshot<
                                                                            DocumentSnapshot<Map<String, dynamic>>>
                                                                        snapshot) {
                                                                  if (!snapshot
                                                                      .hasData) {
                                                                    return Text(
                                                                      _languageProvider.currentLanguage ==
                                                                              Language.English
                                                                          ? 'Week ${widget.weekNumber}, Day ${widget.dayNumber}'
                                                                          : 'Semana ${widget.weekNumber}, Día ${widget.dayNumber}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w200,
                                                                        fontSize:
                                                                            22,
                                                                        letterSpacing:
                                                                            0.27,
                                                                        color: AppTheme
                                                                            .grey,
                                                                      ),
                                                                    );
                                                                  }

                                                                  if (snapshot
                                                                      .hasError) {
                                                                    return Center(
                                                                      child: Text(_languageProvider.currentLanguage ==
                                                                              Language.English
                                                                          ? "Error Occurred"
                                                                          : "Error ocurrido"),
                                                                    );
                                                                  }

                                                                  if (snapshot.data ==
                                                                          null ||
                                                                      snapshot.data!
                                                                              .data() ==
                                                                          null) {
                                                                    return Text(
                                                                      _languageProvider.currentLanguage ==
                                                                              Language.English
                                                                          ? 'Week ${widget.weekNumber}, Day ${widget.dayNumber}'
                                                                          : 'Semana ${widget.weekNumber}, Día ${widget.dayNumber}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w200,
                                                                        fontSize:
                                                                            22,
                                                                        letterSpacing:
                                                                            0.27,
                                                                        color: AppTheme
                                                                            .grey,
                                                                      ),
                                                                    );
                                                                  }

                                                                  if (snapshot
                                                                      .data!
                                                                      .data()!
                                                                      .isEmpty) {
                                                                    return Text(
                                                                      _languageProvider.currentLanguage ==
                                                                              Language.English
                                                                          ? 'Week ${widget.weekNumber}, Day ${widget.dayNumber}'
                                                                          : 'Semana ${widget.weekNumber}, Día ${widget.dayNumber}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w200,
                                                                        fontSize:
                                                                            22,
                                                                        letterSpacing:
                                                                            0.27,
                                                                        color: AppTheme
                                                                            .grey,
                                                                      ),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .clip,
                                                                    );
                                                                  }
                                                                  // if(snapshot.data)
                                                                  return Text(
                                                                    snapshot.data!
                                                                            .data()!
                                                                            .containsKey(
                                                                                'title')
                                                                        ? _languageProvider.currentLanguage ==
                                                                                Language.English
                                                                            ? snapshot.data!['title'] + "\t-\tDay ${widget.dayNumber}"
                                                                            : snapshot.data!['S_title'] + "\t-\tDía ${widget.dayNumber}"
                                                                        : _languageProvider.currentLanguage == Language.English
                                                                            ? 'Week ${widget.weekNumber}, Day ${widget.dayNumber}'
                                                                            : 'Semana ${widget.weekNumber}, Día ${widget.dayNumber}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w200,
                                                                      fontSize:
                                                                          12,
                                                                      letterSpacing:
                                                                          0.27,
                                                                      color: AppTheme
                                                                          .grey,
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .clip,
                                                                  );
                                                                }),
                                                            Icon(
                                                              Icons.star,
                                                              color: AppTheme
                                                                  .nearlyDarkBlue,
                                                              size: 24,
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 16,
                                                      right: 16,
                                                    ),
                                                    child: Text(
                                                      _languageProvider
                                                                  .currentLanguage ==
                                                              Language.English
                                                          ? "${snapshot.data!.docs[index]['category']} - ${snapshot.data!.docs[index]['sub_category']}"
                                                          : "${snapshot.data!.docs[index]['S_category']} - ${snapshot.data!.docs[index]['S_sub_category']}",
                                                      textAlign:
                                                          TextAlign.justify,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w200,
                                                        fontSize: 14,
                                                        letterSpacing: 0.27,
                                                        color: AppTheme.grey,
                                                      ),
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 16,
                                                      right: 16,
                                                    ),
                                                    child: Text(
                                                      _languageProvider
                                                                  .currentLanguage ==
                                                              Language.English
                                                          ? "Description"
                                                          : "Descripción",
                                                      textAlign:
                                                          TextAlign.justify,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        letterSpacing: 0.27,
                                                        color: AppTheme
                                                            .nearlyBlack,
                                                      ),
                                                      // maxLines: 3,
                                                      overflow:
                                                          TextOverflow.clip,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 16,
                                                            right: 16,
                                                            top: 8,
                                                            bottom: 8),
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Text(
                                                        _languageProvider
                                                                    .currentLanguage ==
                                                                Language.English
                                                            ? snapshot.data!.docs[
                                                                        index][
                                                                    'description'] ??
                                                                "No data added yet!"
                                                            : snapshot.data!.docs[
                                                                        index][
                                                                    'S_description'] ??
                                                                "¡Aún no se ha agregado ningún dato!",
                                                        textAlign:
                                                            TextAlign.justify,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w200,
                                                          fontSize: 14,
                                                          letterSpacing: 0.27,
                                                          color: AppTheme.grey,
                                                        ),
                                                        // maxLines: 3,
                                                        overflow:
                                                            TextOverflow.fade,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                FutureBuilder<
                                                    Map<String, dynamic>>(
                                                  future: fetchUserData(
                                                      user!.email ?? ""),
                                                  builder: (context, snaps) {
                                                    if (snaps.connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      // Show loading indicator while fetching data
                                                      return const Center(
                                                          child:
                                                              CircularProgressIndicator());
                                                    } else if (snapshot
                                                        .hasError) {
                                                      // Show an error message if there is an error
                                                      return const Center(
                                                          child: Text(
                                                              'Error fetching data'));
                                                    } else {
                                                      int day =
                                                          extractFirstNumber(
                                                              snapshot.data!
                                                                          .docs[
                                                                      index]
                                                                  ['day']);
                                                      // Show the OngoingContentCard with the extracted data
                                                      return SizedBox(
                                                          child: compareTime(snaps
                                                                          .data?[
                                                                      'unlockTime']) &&
                                                                  snaps.data?['course'][
                                                                          snapshot.data!.docs[index]
                                                                              ['week']][day -
                                                                          1] ==
                                                                      true
                                                              ? Padding(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      left: 16,
                                                                      bottom:
                                                                          16,
                                                                      right:
                                                                          16),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: <Widget>[
                                                                      Expanded(
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              48,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                AppTheme.nearlyDarkBlue,
                                                                            borderRadius:
                                                                                const BorderRadius.all(
                                                                              Radius.circular(16.0),
                                                                            ),
                                                                            boxShadow: <BoxShadow>[
                                                                              BoxShadow(color: isCurrentDayUnlocked == false ? AppTheme.nearlyDarkBlue.withOpacity(0.5) : Colors.transparent, offset: const Offset(1.1, 1.1), blurRadius: 10.0),
                                                                            ],
                                                                          ),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                TimerWidgetView(
                                                                              data: snaps.data?['unlockTime'],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                )
                                                              : SizedBox());
                                                    }
                                                  },
                                                ),
                                                FutureBuilder<
                                                    Map<String, dynamic>>(
                                                  future: fetchUserData(
                                                      user!.email ?? ""),
                                                  builder: (context, snap) {
                                                    if (snap.connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      // Show loading indicator while fetching data
                                                      return const Center(
                                                          child:
                                                              CircularProgressIndicator());
                                                    } else if (snap.hasError) {
                                                      // Show an error message if there is an error
                                                      return const Center(
                                                          child: Text(
                                                              'Error fetching data'));
                                                    } else {
                                                      int day =
                                                          extractFirstNumber(
                                                              snapshot.data!
                                                                          .docs[
                                                                      index]
                                                                  ['day']);
                                                      isCurrentDayUnlocked = snap
                                                                      .data?[
                                                                  'course'][
                                                              snapshot.data!
                                                                          .docs[
                                                                      index][
                                                                  'week']][day -
                                                              1] ??
                                                          false;

                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 16,
                                                                bottom: 40,
                                                                right: 16),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Expanded(
                                                              child:
                                                                  FloatingActionButton
                                                                      .extended(
                                                                onPressed: () {
                                                                  updateWeekAndDay();
                                                                  // Check if the current day is the last day of the week
                                                                  if (widget
                                                                          .dayNumber ==
                                                                      '7') {
                                                                    // Calculate the next week number
                                                                    int nextWeek =
                                                                        int.parse(widget.weekNumber!) +
                                                                            1;
                                                                    // Navigate to the first day of the next week
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                CourseDetailScreen(
                                                                          weekNumber:
                                                                              nextWeek.toString(),
                                                                          dayNumber:
                                                                              '1',
                                                                        ),
                                                                      ),
                                                                    );
                                                                  } else {
                                                                    int nextDay =
                                                                        int.parse(widget.dayNumber!) +
                                                                            1;
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                CourseDetailScreen(
                                                                          weekNumber:
                                                                              widget.weekNumber,
                                                                          dayNumber:
                                                                              nextDay.toString(),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }
                                                                },
                                                                label: Text(
                                                                  _languageProvider
                                                                              .currentLanguage ==
                                                                          Language
                                                                              .English
                                                                      ? 'Next'
                                                                      : 'Siguiente',
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        18,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                backgroundColor:
                                                                    primaryColor, // Use the desired background color
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                      .padding
                                                      .bottom,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  FutureBuilder<Map<String, dynamic>>(
                                    future: fetchUserData(user!.email ?? ""),
                                    builder: (context, snap) {
                                      if (snap.connectionState ==
                                          ConnectionState.waiting) {
                                        // Show loading indicator while fetching data
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (snap.hasError) {
                                        // Show an error message if there is an error
                                        return Center(
                                            child: Text(
                                          _languageProvider.currentLanguage ==
                                                  Language.English
                                              ? "Error Occurred"
                                              : "Error ocurrido",
                                        ));
                                      } else {
                                        int day = extractFirstNumber(
                                            snapshot.data!.docs[index]['day']);
                                        return snap.data?['course'][snapshot
                                                .data!
                                                .docs[index]['week']][day - 1]
                                            ? SizedBox()
                                            : SizedBox();
                                      }
                                    },
                                  ),
                                  // Padding(
                                  //   padding: EdgeInsets.only(
                                  //       top: MediaQuery.of(context).padding.top),
                                  //   child: SizedBox(
                                  //     width: AppBar().preferredSize.height,
                                  //     height: AppBar().preferredSize.height,
                                  //     child: Material(
                                  //       color: Colors.transparent,
                                  //       child: InkWell(
                                  //         borderRadius: BorderRadius.circular(
                                  //             AppBar().preferredSize.height),
                                  //         child: Icon(
                                  //           Icons.arrow_back_ios,
                                  //           color: AppTheme.nearlyBlack,
                                  //         ),
                                  //         onTap: () {
                                  //           Navigator.pop(context);
                                  //         },
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                });
          }
          return Column(
            children:
                List<Widget>.generate(snapshot.data!.docs.length, (int index) {
              return Expanded(
                child: Container(
                  color: AppTheme.nearlyWhite,
                  child: Scaffold(
                    appBar: AppBar(
                      automaticallyImplyLeading: true,
                      backgroundColor: white,
                      centerTitle: true,
                      title: StreamBuilder<
                              DocumentSnapshot<Map<String, dynamic>>>(
                          stream: weekTitleStream,
                          builder: (BuildContext context,
                              AsyncSnapshot<
                                      DocumentSnapshot<Map<String, dynamic>>>
                                  snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                _languageProvider.currentLanguage ==
                                        Language.English
                                    ? 'Week ${widget.weekNumber}, Day ${widget.dayNumber}'
                                    : 'Semana ${widget.weekNumber}, Día ${widget.dayNumber}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 22,
                                  letterSpacing: 0.27,
                                  color: AppTheme.darkerText,
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                  child: Text(
                                _languageProvider.currentLanguage ==
                                        Language.English
                                    ? "Error Occurred"
                                    : "Error ocurrido",
                              ));
                            }

                            if (snapshot.data == null ||
                                snapshot.data!.data() == null) {
                              return Text(
                                _languageProvider.currentLanguage ==
                                        Language.English
                                    ? 'Week ${widget.weekNumber}, Day ${widget.dayNumber}'
                                    : 'Semana ${widget.weekNumber}, Día ${widget.dayNumber}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 22,
                                  letterSpacing: 0.27,
                                  color: AppTheme.darkerText,
                                ),
                                overflow: TextOverflow.clip,
                              );
                            }

                            if (snapshot.data!.data()!.isEmpty) {
                              return Text(
                                _languageProvider.currentLanguage ==
                                        Language.English
                                    ? 'Week ${widget.weekNumber}, Day ${widget.dayNumber}'
                                    : 'Semana ${widget.weekNumber}, Día ${widget.dayNumber}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 22,
                                  letterSpacing: 0.27,
                                  color: AppTheme.darkerText,
                                ),
                                overflow: TextOverflow.clip,
                              );
                            }
                            // if(snapshot.data)
                            return Text(
                              snapshot.data!.data()!.containsKey('title')
                                  ? _languageProvider.currentLanguage ==
                                          Language.English
                                      ? snapshot.data!['title'] +
                                          "\t-\tDay ${widget.dayNumber}"
                                      : snapshot.data!['S_title'] +
                                          "\t-\tDía ${widget.dayNumber}"
                                  : _languageProvider.currentLanguage ==
                                          Language.English
                                      ? 'Week ${widget.weekNumber}, Day ${widget.dayNumber}'
                                      : 'Semana ${widget.weekNumber}, Día ${widget.dayNumber}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                letterSpacing: 0.27,
                                color: AppTheme.darkerText,
                              ),
                              overflow: TextOverflow.clip,
                            );
                          }),
                      leading: IconButton(
                        onPressed: () {
                          // Navigate to the homepage when back button is pressed
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: black,
                        ),
                      ),
                      elevation: 0,
                    ),
                    backgroundColor: Colors.transparent,
                    body: LiquidPullToRefresh(
                      onRefresh: () async {
                        setState(() {});
                      },
                      child: Stack(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              AspectRatio(
                                aspectRatio: 1.2,
                                child: VideoCard(
                                  videoUrl: snapshot.data!.docs[index]['link'],
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: (MediaQuery.of(context).size.width / 1.2) -
                                24.0,
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.nearlyWhite,
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(32.0),
                                    topRight: Radius.circular(32.0)),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: AppTheme.grey.withOpacity(0.2),
                                      offset: const Offset(1.1, 1.1),
                                      blurRadius: 10.0),
                                ],
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
                                child: SingleChildScrollView(
                                  child: Container(
                                    constraints: BoxConstraints(
                                        minHeight: infoHeight,
                                        maxHeight: tempHeight > infoHeight
                                            ? tempHeight
                                            : infoHeight),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 32.0, left: 18, right: 16),
                                          child: Text(
                                            _languageProvider.currentLanguage ==
                                                    Language.English
                                                ? snapshot.data!.docs[index]
                                                    ['title']
                                                : snapshot.data!.docs[index]
                                                    ['S_title'],
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 22,
                                              letterSpacing: 0.27,
                                              color: AppTheme.darkerText,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 16,
                                              right: 16,
                                              bottom: 8,
                                              top: 16),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                child: Row(
                                                  children: <Widget>[
                                                    StreamBuilder<
                                                            DocumentSnapshot<
                                                                Map<String,
                                                                    dynamic>>>(
                                                        stream: weekTitleStream,
                                                        builder: (BuildContext
                                                                context,
                                                            AsyncSnapshot<
                                                                    DocumentSnapshot<
                                                                        Map<String,
                                                                            dynamic>>>
                                                                snapshot) {
                                                          if (!snapshot
                                                              .hasData) {
                                                            return Text(
                                                              _languageProvider
                                                                          .currentLanguage ==
                                                                      Language
                                                                          .English
                                                                  ? 'Week ${widget.weekNumber}, Day ${widget.dayNumber}'
                                                                  : 'Semana ${widget.weekNumber}, Día ${widget.dayNumber}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              overflow:
                                                                  TextOverflow
                                                                      .clip,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w200,
                                                                fontSize: 22,
                                                                letterSpacing:
                                                                    0.27,
                                                                color: AppTheme
                                                                    .grey,
                                                              ),
                                                            );
                                                          }

                                                          if (snapshot
                                                              .hasError) {
                                                            return Center(
                                                                child: Text(
                                                              _languageProvider
                                                                          .currentLanguage ==
                                                                      Language
                                                                          .English
                                                                  ? "Error Occurred"
                                                                  : "Error ocurrido",
                                                            ));
                                                          }

                                                          if (snapshot.data ==
                                                                  null ||
                                                              snapshot.data!
                                                                      .data() ==
                                                                  null) {
                                                            return Text(
                                                              _languageProvider
                                                                          .currentLanguage ==
                                                                      Language
                                                                          .English
                                                                  ? 'Week ${widget.weekNumber}, Day ${widget.dayNumber}'
                                                                  : 'Semana ${widget.weekNumber}, Día ${widget.dayNumber}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              overflow:
                                                                  TextOverflow
                                                                      .clip,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w200,
                                                                fontSize: 22,
                                                                letterSpacing:
                                                                    0.27,
                                                                color: AppTheme
                                                                    .grey,
                                                              ),
                                                            );
                                                          }

                                                          if (snapshot.data!
                                                              .data()!
                                                              .isEmpty) {
                                                            return Text(
                                                              _languageProvider
                                                                          .currentLanguage ==
                                                                      Language
                                                                          .English
                                                                  ? 'Week ${widget.weekNumber}, Day ${widget.dayNumber}'
                                                                  : 'Semana ${widget.weekNumber}, Día ${widget.dayNumber}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              overflow:
                                                                  TextOverflow
                                                                      .clip,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w200,
                                                                fontSize: 22,
                                                                letterSpacing:
                                                                    0.27,
                                                                color: AppTheme
                                                                    .grey,
                                                              ),
                                                            );
                                                          }
                                                          // if(snapshot.data)
                                                          return Text(
                                                            snapshot.data!
                                                                    .data()!
                                                                    .containsKey(
                                                                        'title')
                                                                ? _languageProvider
                                                                            .currentLanguage ==
                                                                        Language
                                                                            .English
                                                                    ? snapshot.data![
                                                                            'title'] +
                                                                        "\t-\tDay ${widget.dayNumber}"
                                                                    : snapshot.data![
                                                                            'S_title'] +
                                                                        "\t-\tDía ${widget.dayNumber}"
                                                                : _languageProvider
                                                                            .currentLanguage ==
                                                                        Language
                                                                            .English
                                                                    ? 'Week ${widget.weekNumber}, Day ${widget.dayNumber}'
                                                                    : 'Semana ${widget.weekNumber}, Día ${widget.dayNumber}',
                                                            textAlign:
                                                                TextAlign.left,
                                                            overflow:
                                                                TextOverflow
                                                                    .clip,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w200,
                                                              fontSize: 12,
                                                              letterSpacing:
                                                                  0.27,
                                                              color:
                                                                  AppTheme.grey,
                                                            ),
                                                          );
                                                        }),
                                                    Icon(
                                                      Icons.star,
                                                      color: AppTheme
                                                          .nearlyDarkBlue,
                                                      size: 24,
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16,
                                                right: 16,
                                                top: 0,
                                                bottom: 0),
                                            child: SingleChildScrollView(
                                              child: Text(
                                                _languageProvider
                                                            .currentLanguage ==
                                                        Language.English
                                                    ? snapshot.data!.docs[index]
                                                        ['description']
                                                    : snapshot.data!.docs[index]
                                                        ['S_description'],
                                                textAlign: TextAlign.justify,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w200,
                                                  fontSize: 14,
                                                  letterSpacing: 0.27,
                                                  color: AppTheme.grey,
                                                ),
                                                // maxLines: 3,
                                                overflow: TextOverflow.fade,
                                              ),
                                            ),
                                          ),
                                        ),
                                        FutureBuilder<Map<String, dynamic>>(
                                          future:
                                              fetchUserData(user!.email ?? ""),
                                          builder: (context, snaps) {
                                            if (snaps.connectionState ==
                                                ConnectionState.waiting) {
                                              // Show loading indicator while fetching data
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            } else if (snapshot.hasError) {
                                              // Show an error message if there is an error
                                              return const Center(
                                                  child: Text(
                                                      'Error fetching data'));
                                            } else {
                                              int day = extractFirstNumber(
                                                  snapshot.data!.docs[index]
                                                      ['day']);
                                              // Show the OngoingContentCard with the extracted data
                                              return SizedBox(
                                                  child: compareTime(snaps.data?[
                                                              'unlockTime']) &&
                                                          snaps.data?['course'][
                                                                  snapshot.data!
                                                                          .docs[index]
                                                                      ['week']][day -
                                                                  1] ==
                                                              true
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 16,
                                                                  bottom: 16,
                                                                  right: 16),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  height: 48,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: AppTheme
                                                                        .nearlyDarkBlue,
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .all(
                                                                      Radius.circular(
                                                                          16.0),
                                                                    ),
                                                                    boxShadow: <BoxShadow>[
                                                                      BoxShadow(
                                                                          color: isCurrentDayUnlocked == false
                                                                              ? AppTheme.nearlyDarkBlue.withOpacity(
                                                                                  0.5)
                                                                              : Colors
                                                                                  .transparent,
                                                                          offset: const Offset(
                                                                              1.1,
                                                                              1.1),
                                                                          blurRadius:
                                                                              10.0),
                                                                    ],
                                                                  ),
                                                                  child: Center(
                                                                    child:
                                                                        TimerWidgetView(
                                                                      data: snaps
                                                                              .data?[
                                                                          'unlockTime'],
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      : SizedBox());
                                            }
                                          },
                                        ),
                                        FutureBuilder<Map<String, dynamic>>(
                                          future:
                                              fetchUserData(user!.email ?? ""),
                                          builder: (context, snap) {
                                            if (snap.connectionState ==
                                                ConnectionState.waiting) {
                                              // Show loading indicator while fetching data
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            } else if (snap.hasError) {
                                              // Show an error message if there is an error
                                              return const Center(
                                                  child: Text(
                                                      'Error fetching data'));
                                            } else {
                                              int day = extractFirstNumber(
                                                  snapshot.data!.docs[index]
                                                      ['day']);

                                              // Check if the content for the current day is unlocked and if the next day exists

                                              bool isCurrentDayUnlocked = snap
                                                          .data?['course'][
                                                      snapshot.data!.docs[index]
                                                          ['week']][day - 1] ??
                                                  false;
                                              bool hasNextDay = (day <
                                                  7); // Assuming 7 days in a week

                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 16,
                                                    bottom: 40,
                                                    right: 16),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child:
                                                          FloatingActionButton
                                                              .extended(
                                                        onPressed: () {
                                                          updateWeekAndDay();
                                                          // Check if the current day is the last day of the week
                                                          if (widget
                                                                  .dayNumber ==
                                                              '7') {
                                                            // Calculate the next week number
                                                            int nextWeek =
                                                                int.parse(widget
                                                                        .weekNumber!) +
                                                                    1;
                                                            // Navigate to the first day of the next week
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        CourseDetailScreen(
                                                                  weekNumber:
                                                                      nextWeek
                                                                          .toString(),
                                                                  dayNumber:
                                                                      '1',
                                                                ),
                                                              ),
                                                            );
                                                          } else {
                                                            int nextDay =
                                                                int.parse(widget
                                                                        .dayNumber!) +
                                                                    1;
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        CourseDetailScreen(
                                                                  weekNumber: widget
                                                                      .weekNumber,
                                                                  dayNumber: nextDay
                                                                      .toString(),
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        label: Text(
                                                          _languageProvider
                                                                      .currentLanguage ==
                                                                  Language
                                                                      .English
                                                              ? 'Next'
                                                              : 'Siguiente',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 18,
                                                            letterSpacing: 0.0,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        backgroundColor:
                                                            primaryColor, // Use the desired background color
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                              .padding
                                              .bottom,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          FutureBuilder<Map<String, dynamic>>(
                            future: fetchUserData(user!.email ?? ""),
                            builder: (context, snap) {
                              if (snap.connectionState ==
                                  ConnectionState.waiting) {
                                // Show loading indicator while fetching data
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snap.hasError) {
                                // Show an error message if there is an error
                                return const Center(
                                    child: Text('Error fetching data'));
                              } else {
                                int day = extractFirstNumber(
                                    snapshot.data!.docs[index]['day']);
                                return snap.data?['course']
                                            [snapshot.data!.docs[index]['week']]
                                        [day - 1]
                                    ? SizedBox()
                                    : SizedBox();
                              }
                            },
                          ),
                          // Padding(
                          //   padding: EdgeInsets.only(
                          //       top: MediaQuery.of(context).padding.top),
                          //   child: SizedBox(
                          //     width: AppBar().preferredSize.height,
                          //     height: AppBar().preferredSize.height,
                          //     child: Material(
                          //       color: Colors.transparent,
                          //       child: InkWell(
                          //         borderRadius: BorderRadius.circular(
                          //             AppBar().preferredSize.height),
                          //         child: Icon(
                          //           Icons.arrow_back_ios,
                          //           color: AppTheme.nearlyBlack,
                          //         ),
                          //         onTap: () {
                          //           Navigator.pop(context);
                          //         },
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        });
  }
}
