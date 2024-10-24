import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'services/notification.dart';
import 'spalsh_screen_view.dart';
import './views/home_page/home_screen.dart';
import './constants/colors.dart';
import './controllers/AuthRedirectController.dart';
import './entities/ProfileImage.dart';
import './views/auth_pages/add_profile_image_view.dart';
import './views/auth_pages/login_page_view.dart';
import './views/auth_pages/forgot_password_page_view.dart';
import 'package:provider/provider.dart';
import 'entities/User.dart';
import 'models/authentication/FirebaseAuthServiceModel.dart';
import 'models/polls/db_provider.dart';
import 'models/polls/fetch_polls_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:efnep_mobile/provider/language_provider.dart';
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background messages
}

void main() async {
  runZonedGuarded<Future<void>>(() async {
     WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isIOS) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBW2KWBC6UyzQyKONOy_f_ttca65tZoeE4",
        appId: "1:405004722252:ios:00ea455543f624c8e8d4e9",
        messagingSenderId: "405004722252",
        projectId: "efnep-mobile",
      ),
    );

    NotificationServices notificationServices = NotificationServices();
    notificationServices.requestNotificationPermission();

    String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnsToken != null) {
       await FirebaseMessaging.instance.subscribeToTopic("all");
    }
  } else {
    await Firebase.initializeApp();
    NotificationServices notificationServices = NotificationServices();
    notificationServices.requestNotificationPermission();
    await FirebaseMessaging.instance.subscribeToTopic("all");
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_) => runApp(const MyApp()));


  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstRun = prefs.getBool('first_run') ?? true;
  
  if (isFirstRun) {
    await clearCache();
    await prefs.setBool('first_run', false);
  }


    runApp(const MyApp());
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));

}

class MyApp extends StatefulWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:
          !kIsWeb && Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return MultiProvider(
      providers: [
        // Provider for base class instance of [FirebaseAuthServiceModel]
        Provider<FirebaseAuthServiceModel>(
          create: (_) => FirebaseAuthServiceModel(),
        ),
        // Provider for instance of UserModel
        Provider<UserData?>(
          create: (_) => FirebaseAuthServiceModel().getUserDetails(),
        ),
        Provider<ProfileImage?>(
          create: (_) => ProfileImage(null),
        ),
        ChangeNotifierProvider(
          create: (context) => DbProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => FetchPollsProvider(),
        ),
        ChangeNotifierProvider(create: (context)=>LanguageProvider())  
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Good Bowls',
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: MyApp.analytics),
        ],
        theme: ThemeData(
          
          primarySwatch: const MaterialColor(
            0xFF40BAD4,
            <int, Color>{
              50: primaryColor,
              100: primaryColor,
              200: primaryColor,
              300: primaryColor,
              400: primaryColor,
              500: primaryColor,
              600: primaryColor,
              700: primaryColor,
              800: primaryColor,
              900: primaryColor,
            },
          ),
          platform: TargetPlatform.iOS,
          fontFamily: 'Nanami',
          useMaterial3: false
        ),
        initialRoute: "/splash",
        routes: {
          "/splash": (context) => const SplashScreen(),
          "/": (context) => const AuthRedirectController(),
          "/login": (context) => const LoginPageView(),
          "/setProfileImage": (context) => const AddProfileImageView(),
          "/forgotPassword": (context) => const ForgotPasswordView(),
          "/home": (context) => const HomeScreen()
        },
      ),
    );
  }
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}

Future<void> clearCache() async {
  // Implement cache clearing logic here
}