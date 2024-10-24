// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:efnep_mobile/provider/language_provider.dart';
import 'package:efnep_mobile/views/widgets/timer_widget_view.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../constants/colors.dart';
import '../../entities/User.dart';
import '../../utils/date_time.dart';
import '../../utils/fetch_user.dart';
import '../week_course/course_view.dart';
import 'video_card_widget_view.dart';

class OngoingContentCard extends StatefulWidget {
  final String week;
  final int day;
  final data;

  const OngoingContentCard({
    Key? key,
    required this.week,
    required this.day,
    this.data,
  }) : super(key: key);

  @override
  State<OngoingContentCard> createState() => _OngoingContentCardState();
}

class _OngoingContentCardState extends State<OngoingContentCard> {
  late String numbersOnly;
  late Stream<QuerySnapshot> videoStream;
  late Stream<QuerySnapshot> tipStream;
  UserData? user;

  late LanguageProvider _languageProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageProvider = Provider.of<LanguageProvider>(
        context); // Get the LanguageProvider instance
  }

  @override
  void initState() {
    super.initState();
    numbersOnly = widget.week.replaceAll(RegExp(r'[^0-9]'), '');
    videoStream = FirebaseFirestore.instance
        .collection('videos')
        .where('week', isEqualTo: widget.week)
        .where('day', isEqualTo: "Day ${widget.day}")
        .snapshots(includeMetadataChanges: true);
    tipStream = FirebaseFirestore.instance
        .collection('tips')
        .where('week', isEqualTo: widget.week)
        .where('day', isEqualTo: "Day ${widget.day}")
        .snapshots(includeMetadataChanges: true);
    Future.delayed(Duration.zero, () {
      user = Provider.of<UserData?>(context, listen: false);
    });
  }

  Future<void> updateWeekAndDay() async {
    String? week = numbersOnly;
    DateTime currentTime = DateTime.now();
    DateTime unlockTime = currentTime.add(const Duration(minutes: 0));

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.email ?? "")
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> courseData =
            userData['course'] as Map<String, dynamic>;

        String weekKey = 'Week $week';
        if (courseData.containsKey(weekKey)) {
          List<bool> weekData = List.from(courseData[weekKey]);

          if (widget.day >= 1 && widget.day <= weekData.length) {
            if (widget.day != 7) {
              weekData[widget.day] = true; // Adjusted index
              courseData[weekKey] = weekData;
            }

            int newDay = (widget.day == 7) ? 1 : widget.day + 1;
            int newWeek =
                (widget.day == 7) ? int.parse(week) + 1 : int.parse(week);
            String newWeekKey = (widget.day == 7) ? 'Week $newWeek' : weekKey;

            // If the new week key exists in courseData, update its initial index to true
            if (widget.day == 7) {
              if (courseData.containsKey('Week $newWeek')) {
                courseData['Week $newWeek'][0] = true;
              }
            }

            await FirebaseFirestore.instance
                .collection('Users')
                .doc(user!.email)
                .update({
              'course': courseData, // Update courseData array
              'currentWeek': newWeekKey,
              'currentDay': newDay,
              'currentTime': currentTime,
              'unlockTime': unlockTime
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error updating user data: $e');
      // Handle errors more gracefully or log them.
    }
  }

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot<Map<String, dynamic>>> weekTitleStream =
        FirebaseFirestore.instance
            .collection("week-titles")
            .doc(widget.week)
            .snapshots(includeMetadataChanges: true);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                    _languageProvider.currentLanguage == Language.English
                        ? 'Continue your program'
                        : 'Continúe su programa',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: weekTitleStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (!snapshot.hasData) {
                        return Text(
                          _languageProvider.currentLanguage == Language.English
                              ? '${widget.week}, Day ${widget.day}'
                              : '${widget.week}, Día ${widget.day}',
                          style: const TextStyle(fontSize: 16),
                        );
                      }

                      if (snapshot.hasError) {
                        return const Text("Error Occurred");
                      }

                      if (snapshot.data == null ||
                          snapshot.data!.data() == null) {
                        return Text(
                            _languageProvider.currentLanguage ==
                                    Language.English
                                ? '${widget.week}, Day ${widget.day}'
                                : '${widget.week}, Día ${widget.day}',
                            style: const TextStyle(fontSize: 16));
                      }

                      if (snapshot.data!.data()!.isEmpty) {
                        return Text(
                            _languageProvider.currentLanguage ==
                                    Language.English
                                ? '${widget.week}, Day ${widget.day}'
                                : '${widget.week}, Día ${widget.day}',
                            style: const TextStyle(fontSize: 16));
                      }

                      return Text(
                        _languageProvider.currentLanguage == Language.English
                            ? '${snapshot.data!.data()!.containsKey('title') ? snapshot.data!['title'] + "\t-\tDay ${widget.day}" : '${widget.week}, Day ${widget.day}'}'
                            : '${snapshot.data!.data()!.containsKey('S_title') ? snapshot.data!['S_title'] + "\t-\tDía ${widget.day}" : '${widget.week}, Día  ${widget.day}'}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      );
                    }),
              ],
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: videoStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.data!.docs.isEmpty) {
                return StreamBuilder<QuerySnapshot>(
                  stream: tipStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          _languageProvider.currentLanguage == Language.English
                              ? 'No data'
                              : 'Sin datos',
                        ),
                      );
                    }

                    var tipData =
                        snapshot.data!.docs[0].data() as Map<String, dynamic>?;

                    if (tipData != null) {
                      return Column(
                        children: [
                          const SizedBox(height: 8),
                          tipData.containsKey('imageURL')
                              ? CachedNetworkImage(
                                  imageUrl: tipData['imageURL'] ??
                                      'https://brent-mccardle.org/img/placeholder-image.png',
                                  height: 200,
                                  width: 200,
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
                                )
                              : const SizedBox(),
                          Text(
                            _languageProvider.currentLanguage ==
                                    Language.English
                                ? tipData['title'] ?? 'No Title'
                                : tipData['S_title'] ?? 'No Title',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          FutureBuilder<Map<String, dynamic>>(
                            future: fetchUserData(user!.email ?? ""),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                // Show loading indicator while fetching data
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                // Show an error message if there is an error
                                return const Center(
                                    child: Text('Error fetching data'));
                              } else {
                                var userData = snapshot.data;

                                // Check if 'unlockTime' field exists
                                if (userData != null &&
                                    userData.containsKey('unlockTime')) {
                                  return compareTime(userData['unlockTime'])
                                      ? TimerWidgetView(
                                          data: userData['unlockTime'],
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                // Handle the "View Details" button press
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: ((context) =>
                                                        CourseDetailScreen(
                                                          weekNumber:
                                                              numbersOnly,
                                                          dayNumber:
                                                              (widget.day)
                                                                  .toString(),
                                                        )),
                                                  ),
                                                );
                                                setState(() {});
                                              },
                                              child: Text(
                                                _languageProvider
                                                            .currentLanguage ==
                                                        Language.English
                                                    ? 'View Details'
                                                    : 'Ver Detalles',
                                              ),
                                            ),
                                          ],
                                        );
                                } else {
                                  // Handle case where 'unlockTime' is not present in userData
                                  return const Text(
                                      'Unlock time not available');
                                }
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    } else {
                      return const Text('Tip data not available');
                    }
                  },
                );
              }

              return Column(
                children: [
                  VideoCard(videoUrl: snapshot.data!.docs[0]['link']),
                  const SizedBox(height: 8),
                  Text(
                    _languageProvider.currentLanguage == Language.English
                        ? snapshot.data!.docs[0]['title']
                        : snapshot.data!.docs[0][
                            'S_title'], // Assuming 'title' is the key for video title
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<Map<String, dynamic>>(
                    future: fetchUserData(user!.email ?? ""),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Show loading indicator while fetching data
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        // Show an error message if there is an error
                        return const Center(child: Text('Error fetching data'));
                      } else {
                        // Show the OngoingContentCard with the extracted data
                        return SizedBox(
                          child: compareTime(snapshot.data?['unlockTime'])
                              ? TimerWidgetView(
                                  data: snapshot.data?['unlockTime'],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        // Handle the "View Details" button press
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: ((context) =>
                                                CourseDetailScreen(
                                                  weekNumber: numbersOnly,
                                                  dayNumber:
                                                      (widget.day).toString(),
                                                )),
                                          ),
                                        );
                                        setState(() {});
                                      },
                                      child: Text(
                                        _languageProvider.currentLanguage ==
                                                Language.English
                                            ? 'View Details'
                                            : 'Ver Detalles',
                                      ),
                                    ),
                                  ],
                                ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
