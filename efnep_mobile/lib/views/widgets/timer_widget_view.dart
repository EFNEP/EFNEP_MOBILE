// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'package:flutter/widgets.dart';
import '../../utils/date_time.dart';

class TimerWidgetView extends StatefulWidget {
  final data;
  const TimerWidgetView({Key? key, this.data}) : super(key: key);

  @override
  State<TimerWidgetView> createState() => _TimerWidgetViewState();
}

class _TimerWidgetViewState extends State<TimerWidgetView> {
  late Timer _timer;
  String remainingTime = '';


  @override
  void initState() {
    startTimer();
    super.initState();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (compareTime(widget.data)) {
          Duration timeRemaining =
              widget.data.toDate().difference(DateTime.now());
          remainingTime = formatDuration(timeRemaining);
        } else {
          _timer.cancel(); // Stop the timer when unlock time is reached
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('Course will be unlocked in $remainingTime');
  }
}
