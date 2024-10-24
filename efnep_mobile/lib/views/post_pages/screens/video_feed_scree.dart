// VideoFeedScreen
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:efnep_mobile/provider/language_provider.dart';
import 'package:efnep_mobile/services/analytics.dart';
import 'package:efnep_mobile/views/post_pages/screens/add_video_screen.dart';
import 'package:efnep_mobile/views/post_pages/widgets/video_post_card.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';

const webScreenSize = 600;

class VideoFeedScreen extends StatefulWidget {
  const VideoFeedScreen({Key? key}) : super(key: key);

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  late LanguageProvider _languageProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageProvider = Provider.of<LanguageProvider>(
        context); // Get the LanguageProvider instance
  }

  @override
  void initState() {
    analytics('VideoFeed', 'VideoFeedScreen');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: width > webScreenSize ? notWhite : notWhite,
      body: LiquidPullToRefresh(
        onRefresh: () async {
          setState(() {});
        },
        child: StreamBuilder(
          stream:
              FirebaseFirestore.instance.collection('video-posts').snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  _languageProvider.currentLanguage == Language.English
                      ? 'No posts yet'
                      : 'Aún no hay publicaciones',
                ),
              );
            }
            // Sort the posts by date published
            List<QueryDocumentSnapshot<Map<String, dynamic>>> sortedPosts =
                snapshot.data!.docs;
            sortedPosts.sort((a, b) {
              Timestamp aTimestamp = a['datePublished'];
              Timestamp bTimestamp = b['datePublished'];
              return bTimestamp.compareTo(aTimestamp);
            });

            return Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (ctx, index) => Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: width > webScreenSize ? width * 0.3 : 0,
                    vertical: width > webScreenSize ? 15 : 0,
                  ),
                  child: VideoPostCard(
                    snap: sortedPosts[index].data(),
                    videoUrl: sortedPosts[index].data()['videoUrl'],
                    caption: sortedPosts[index].data()['description'],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.15),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddVideoPostScreen(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
