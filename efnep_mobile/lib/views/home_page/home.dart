// ignore_for_file: library_private_types_in_public_api, deprecated_member_use
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:efnep_mobile/views/home_page/notification_screen_view.dart';
import 'package:efnep_mobile/views/widgets/modern_card_widget_view.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../provider/language_provider.dart';
import 'current_view.dart';
import '../../entities/User.dart';
import 'app_theme.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();
  late SharedPreferences _prefs;

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
    _initSharedPreferences().then((_) {
      _checkAndShowAlert();
    });
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void _checkAndShowAlert() {
    final lastAlertDate = _prefs.getString('lastAlertDate');

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastAlertDate != null) {
      final lastDate = DateTime.parse(lastAlertDate);
      if (lastDate.isBefore(today)) {
        // A new day has started, show the alert
        _showAlertDialog();

        // Update the stored date
        _prefs.setString('lastAlertDate', today.toIso8601String());
      }
    } else {
      // First time running the app, show the alert
      _showAlertDialog();

      // Store the current date
      _prefs.setString('lastAlertDate', today.toIso8601String());
    }
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Text(
    _languageProvider.currentLanguage == Language.English
        ? 'Rate App'
        : 'Calificar aplicacion',
          ),
          content: 
            Text(
    _languageProvider.currentLanguage == Language.English
        ? 'Rate our app now!'
        : '¡Califica nuestra aplicación ahora!',
            ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // launch to playstore
                launch(
                    'https://play.google.com/store/apps/details?id=com.official.good_bowls&pli=1');
              },
              child: Text(
    _languageProvider.currentLanguage == Language.English
        ? 'Rate now'
        : 'Califica ahora',
            ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
    _languageProvider.currentLanguage == Language.English
        ? 'Remind me later'
        : 'Recuérdame más tarde',
            ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserData?>(context);
    final Stream<DocumentSnapshot<Map>> userStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.email)
        .snapshots(includeMetadataChanges: true);

    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: LiquidPullToRefresh(
          key: _refreshIndicatorKey,
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            setState(() {});
            return;
          },
          child: Column(
            children: [
              getAppBarUI(user),
              const SizedBox(
                height: 10,
              ),
              StreamBuilder<DocumentSnapshot<Map>>(
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
                    // if (!snapshot.data!.data()!.containsKey('age') &&
                    //     !snapshot.data!.data()!.containsKey('gender')) {
                    //   WidgetsBinding.instance.addPostFrameCallback((_) {
                    //     showDialog(
                    //       context: context,
                    //       builder: (BuildContext context) {
                    //         return AlertDialog(
                    //           title: const Text("Update Age and Gender"),
                    //           content: const Text(
                    //               "Please update your age and gender in your profile."),
                    //           actions: [
                    //             // text button to redirrect to edit profile page
                    //             TextButton(
                    //               onPressed: () {
                    //                 Navigator.push(
                    //                   context,
                    //                   MaterialPageRoute(
                    //                     builder: (context) =>
                    //                         const UserProfileView(),
                    //                   ),
                    //                 );
                    //               },
                    //               child: const Text("Edit Profile"),
                    //             ),
                    //             TextButton(
                    //               onPressed: () {
                    //                 Navigator.of(context).pop();
                    //               },
                    //               child: const Text("Cancel"),
                    //             ),
                    //           ],
                    //         );
                    //       },
                    //     );
                    //   });
                    // }
                    return (snapshot.data!.data()!.containsKey('course'))
                        ? CurrentView(userId: user.email ?? "")
                        : const SizedBox();
                  }),
              const ModernCard(),
              const SizedBox(
                height: 80,
              )
            ],
          ),
        ),
      ),
    );
  }
  
  Widget getAppBarUI(UserData user) {
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
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
    _languageProvider.currentLanguage == Language.English
        ? 'Welcome\t${user.displayName}'
        : 'Bienvenida\t${user.displayName}',
            
                          
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontWeight: FontWeight.w700,
                            fontSize: 22 + 6 - 6,
                            letterSpacing: 1.2,
                            color: Color.fromARGB(255, 114, 189, 210),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationPageView(),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.notifications,
                        color: AppTheme.nearlyDarkBlue,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
