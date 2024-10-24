import 'package:flutter/material.dart';
import '../../utils/fetch_user.dart';
import '../widgets/ongoing_content_card_widget_view.dart';

class CurrentView extends StatelessWidget {
  final String userId; // Pass the user ID to the home page

  const CurrentView({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchUserData(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator while fetching data
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Show an error message if there is an error
          return const Center(child: Text('Error fetching data'));
        } else {
          // Extract the ongoing week and day data from the snapshot
          String ongoingWeek = snapshot.data?['currentWeek'] ?? '';
          int ongoingDay = snapshot.data?['currentDay'] ?? 0;

          debugPrint(snapshot.data?.toString());

          // Show the OngoingContentCard with the extracted data
          return OngoingContentCard(
            week: ongoingWeek,
            day: ongoingDay,
            data: snapshot.data,
          );
        }
      },
    );
  }
}
