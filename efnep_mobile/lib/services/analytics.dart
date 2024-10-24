
  import 'package:firebase_analytics/firebase_analytics.dart';

Future<void> analytics(name, className) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'firebase_screen': name,
        'firebase_screen_class': className,
      },
    );
  }
