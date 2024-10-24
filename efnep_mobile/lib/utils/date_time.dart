// Replace with your Firebase Timestamp
import 'package:cloud_firestore/cloud_firestore.dart';

bool compareTime(Timestamp t) {
  Timestamp currentTime = Timestamp.now();

  // Compare the timestamps
  int comparisonResult = t.compareTo(currentTime);

  return comparisonResult > 0;
}

String formatDuration(Duration duration) {
  int hours = duration.inHours;
  int minutes = (duration.inMinutes % 60);
  int seconds = (duration.inSeconds % 60);

  return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}