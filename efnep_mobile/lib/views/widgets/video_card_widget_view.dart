import 'package:flutter/material.dart';
import 'package:efnep_mobile/constants/colors.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoCard extends StatefulWidget {
  final String videoUrl;

  const VideoCard({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  String extractVideoId(String url) {
    RegExp regExp = RegExp(
      r"(?<=v=|v\/|vi=|vi\/|youtu\.be\/|embed\/)([a-zA-Z0-9_-]{11})",
      caseSensitive: false,
      multiLine: false,
    );

    Match? match = regExp.firstMatch(url);
    if (match != null) {
      return match.group(1)!;
    }

    return '';
  }

  late String videID;
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    videID = extractVideoId(widget.videoUrl);
    _controller = YoutubePlayerController(
      initialVideoId: videID,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: primaryColor,
    );
  }
}
