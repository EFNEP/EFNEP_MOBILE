import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:efnep_mobile/utils/document_name.dart';
import 'package:efnep_mobile/views/week_course/week_view.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../entities/User.dart';
import 'package:efnep_mobile/provider/language_provider.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class ModernCard extends StatefulWidget {
  const ModernCard({Key? key}) : super(key: key);

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard> {
  List<String> weeks = [];
  int length = 0;
  late LanguageProvider _languageProvider;
  String? currentUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageProvider = Provider.of<LanguageProvider>(context);
  }

  void getList() async {
    weeks = await getAllDocumentNames('weeks');
    length = weeks.length;
    debugPrint(weeks.length.toString());
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getList();
  }

  /// Identify the user in PostHog with the Firebase `uid` and set user properties
  void identifyUserInPosthog(String uid, String email, String name) {
    Posthog().identify(
      userId: uid, // Using Firebase `uid` as the unique identifier
      userProperties: {
        'name': name,
        'email': email, // Email is passed as a user property
      },
      userPropertiesSetOnce: {
        'date_of_first_log_in': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Reset PostHog session on logout
  void resetPosthog() {
    Posthog().reset(); // Clear all session data
  }

  /// Save the initial weeks map to Firestore for the current user
  void saveWeeksMapToFirestore(String userId) {
    DateTime currentTime = DateTime.now();
    DateTime unlockTime = currentTime.add(const Duration(minutes: 0));
    Map<String, List<bool>> weeksMap = createInitialWeeksMap(length);

    FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .update({
      'course': weeksMap,
      'currentTime': currentTime,
      'currentWeek': 'Week 1',
      'currentDay': 1,
      'unlockTime': unlockTime
    });
  }

  /// Helper function to create the initial weeks map
  Map<String, List<bool>> createInitialWeeksMap(int numberOfWeeks) {
    Map<String, List<bool>> weeksMap = {};
    for (int i = 1; i <= numberOfWeeks; i++) {
      List<bool> weekDays = List.generate(7, (index) => (i == 1 && index == 0));
      weeksMap['Week $i'] = weekDays;
    }
    return weeksMap;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserData?>(context);
    final Stream<DocumentSnapshot<Map>> userStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.email)
        .snapshots(includeMetadataChanges: true);

    return Container(
      margin: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: StreamBuilder<DocumentSnapshot<Map>>(
          stream: userStream,
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot<Map>> snapshot) {
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

            final userData = snapshot.data!.data();
            final String uid = userData!['uid']; // Firebase uid as unique identifier
            final String email = userData['email'] ?? '';
            final String name = userData['name'] ?? 'User';

            // Identify the user in PostHog only if the uid has changed
            if (currentUserId != uid) {
              identifyUserInPosthog(uid, email, name);
              currentUserId = uid; // Update the current user id
            }

            return Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      bottomLeft: Radius.circular(16.0),
                    ),
                    child: Image.asset(
                      'assets/signup.png',
                      fit: BoxFit.cover,
                      height: 120,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _languageProvider.currentLanguage == Language.English
                              ? 'Welcome to the Good Bowls Program!'
                              : '¡Bienvenido al programa de Good Bowls!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _languageProvider.currentLanguage == Language.English
                              ? 'Supercharge your life and health with quick tips and easy, delicious recipes'
                              : 'Potencia tu vida y tu salud con consejos rápidos y recetas fáciles y deliciosas',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        (snapshot.data!.data()!.containsKey('course'))
                            ? ElevatedButton(
                                onPressed: () async {
                                  await Posthog().capture(
                                    eventName: 'Opened Courses Page',
                                    properties: {
                                      'clicked': true,
                                    },
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: ((context) => const WeekView()),
                                    ),
                                  );
                                },
                                child: Text(
                                  _languageProvider.currentLanguage == Language.English
                                      ? 'Continue Journey'
                                      : 'Continuar el Viaje',
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  saveWeeksMapToFirestore(user.email ?? '');
                                  Fluttertoast.showToast(
                                    msg:
                                        "Welcome to Good Bowls! We are excited to have you on board. Let's get started!",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.black,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: ((context) => const WeekView()),
                                    ),
                                  );
                                },
                                child: Text(
                                  _languageProvider.currentLanguage == Language.English
                                      ? 'Get Started'
                                      : 'Empezar',
                                ),
                              )
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
