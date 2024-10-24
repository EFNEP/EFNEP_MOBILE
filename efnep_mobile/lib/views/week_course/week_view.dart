import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:efnep_mobile/views/week_course/course_view.dart';
import 'package:provider/provider.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import '../../constants/colors.dart';
import '../home_page/app_theme.dart';
import '../../entities/User.dart';
import '../../utils/document_name.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:efnep_mobile/provider/language_provider.dart';

class WeekView extends StatefulWidget {
  const WeekView({Key? key}) : super(key: key);

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  late List<String> weeks;
  late List<Map<String, List<bool>>> weeksUnlocked;
  int length = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();

  late LanguageProvider _languageProvider; // Declare LanguageProvider instance

  void fetchUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> courseData =
            userData['course'] as Map<String, dynamic>;
        List<String> weekKeys = courseData.keys.toList();
        weekKeys.sort(); // Sort the week keys to maintain the order

        List<Map<String, List<bool>>> unlockedList = [];
        for (String weekKey in weekKeys) {
          Map<String, List<bool>> weekData = {weekKey: []};
          List<dynamic> weekValues = courseData[weekKey];
          for (var value in weekValues) {
            weekData[weekKey]!.add(value as bool);
          }
          unlockedList.add(weekData);
        }

        setState(() {
          weeksUnlocked = unlockedList;
        });
      }
    } catch (e) {
      // Handle errors if any
      debugPrint('Error fetching user data: $e');
    }
  }

  void getList() async {
    weeks = await getAllDocumentNames('weeks');
    length = weeks.length;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getList();
    Future.delayed(Duration.zero, () {
      final user = Provider.of<UserData?>(context, listen: false);
      debugPrint(user.toString());
      if (user != null) {
        fetchUserData(user.email ?? "");
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageProvider = Provider.of<LanguageProvider>(context); // Initialize LanguageProvider instance
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: LiquidPullToRefresh(
        key: _refreshIndicatorKey,
        onRefresh: () async {
          final user = Provider.of<UserData?>(context, listen: false);
          debugPrint(user.toString());
          if (user != null) {
            fetchUserData(user.email ?? "");
          }
        },
        child: Column(
          children: [
            getAppBarUI(),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: length,
                itemBuilder: (context, index) {
                  return WeekSection(
                    weekNumber: index + 1,
                    weeksUnlocked: weeksUnlocked,
                    languageProvider: _languageProvider, // Pass _languageProvider here
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getAppBarUI() {
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
                blurRadius: 10.0,
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).padding.top,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: AppBar().preferredSize.height,
                    height: AppBar().preferredSize.height,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          AppBar().preferredSize.height,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: AppTheme.nearlyBlack,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        _languageProvider.currentLanguage == Language.English
                            ? 'Week Details'
                            : 'Detalles de la Semana',
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
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}

class WeekSection extends StatelessWidget {
  final int weekNumber;
  final List<Map<String, List<bool>>> weeksUnlocked;
  final LanguageProvider languageProvider; // Declare LanguageProvider instance here
  const WeekSection({
    Key? key,
    required this.weekNumber,
    required this.weeksUnlocked,
    required this.languageProvider, // Add LanguageProvider parameter here
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, List<bool>>? weekData;
    for (var week in weeksUnlocked) {
      if (week.containsKey('Week $weekNumber')) {
        weekData = week;
        break;
      }
    }
    final Stream<DocumentSnapshot<Map<String, dynamic>>> weekTitleStream =
        FirebaseFirestore.instance
            .collection("week-titles")
            .doc('Week $weekNumber')
            .snapshots(includeMetadataChanges: true);

            

    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: weekData != null && isAllLocked(weekData!['Week $weekNumber']!)
                ? greyDark
                : primaryColor,
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: weekTitleStream,
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Text(
                      languageProvider.currentLanguage == Language.English
                          ? 'Week $weekNumber'
                          : 'Semana $weekNumber',
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return  Center(
                    child: Text(
                      languageProvider.currentLanguage == Language.English
                          ? "Error Occurred"
                          : "Se produjo un error",
                    ),
                  );
                }

                if (snapshot.data == null || snapshot.data!.data() == null) {
                  return Center(
                    child: Text(
                      languageProvider.currentLanguage == Language.English
                          ? 'Week $weekNumber'
                          : 'Semana $weekNumber',
                    ),
                  );
                }

                if (snapshot.data!.data()!.isEmpty) {
                  return Center(
                    child: Text(
                      languageProvider.currentLanguage == Language.English
                          ? 'Week $weekNumber'
                          : 'Semana $weekNumber',
                    ),
                  );
                }
                return Center(
                  child: Text(
                    snapshot.data!.data()!.containsKey('title')
                        ? languageProvider.currentLanguage == Language.English
                            ? snapshot.data!['title']
                            : snapshot.data!['S_title']
                        : languageProvider.currentLanguage == Language.English
                            ? 'Week $weekNumber'
                            : 'Semana $weekNumber',
                    style: const TextStyle(
                      color: white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 7,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 7,
            itemBuilder: (context, index) {
              if (weekData != null) {
                List<bool> dayData = weekData!['Week $weekNumber']!;
                bool isUnlocked = dayData[index];
                return DayTab(
                  dayNumber: index + 1,
                  isUnlocked: isUnlocked,
                  weekNumber: weekNumber,
                  languageProvider: languageProvider,
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }

  bool isAllLocked(List<bool> dayData) {
    return dayData.every((isUnlocked) => !isUnlocked);
  }
}

class DayTab extends StatelessWidget {
  final int dayNumber;
  final bool isUnlocked;
  final int weekNumber;
   final LanguageProvider languageProvider;

  const DayTab({
    Key? key,
    required this.dayNumber,
    required this.isUnlocked,
    required this.weekNumber,
    required this.languageProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isCompleted = isUnlocked;

    return Neumorphic(
      style: NeumorphicStyle(
        depth: 0.5,
        intensity: 0.8,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16.0)),
        color: Colors.green[200],
      ),
      child: GestureDetector(
        onTap: () {
          if (isUnlocked) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: ((context) => CourseDetailScreen(
                  weekNumber: weekNumber.toString(),
                  dayNumber: dayNumber.toString(),
                )),
              ),
            );
          } else {
            Fluttertoast.showToast(msg: 'Day $dayNumber locked');
          }
        },
        child: Container(
          color: isCompleted ? Colors.green[300] : greyLight,
          child: Center(
            child: Text(
              languageProvider.currentLanguage == Language.English
      ? 'Day $dayNumber'
      : 'Día $dayNumber',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isCompleted ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
