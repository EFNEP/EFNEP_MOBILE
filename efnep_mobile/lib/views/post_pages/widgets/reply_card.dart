// ignore_for_file: prefer_interpolation_to_compose_strings
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants/colors.dart';

class ReplyCard extends StatelessWidget {
  final Map<String, dynamic> reply;

  const ReplyCard({Key? key, required this.reply}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reply by\t' + reply['name'],
            style: TextStyle(color: black.withOpacity(.6)),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            reply['text'],
            style: const TextStyle(fontWeight: FontWeight.w400, color: black),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              DateFormat.yMMMd().format(reply['datePublished'].toDate()),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }
}
