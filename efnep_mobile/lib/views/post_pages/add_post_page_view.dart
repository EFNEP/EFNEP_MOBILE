import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:efnep_mobile/constants/strings.dart';
import 'package:efnep_mobile/models/authentication/FirebaseAuthServiceModel.dart';
import 'package:efnep_mobile/views/post_pages/screens/feed_screen.dart';
import 'package:efnep_mobile/views/post_pages/screens/polls_screen.dart';
import 'package:efnep_mobile/views/post_pages/screens/profile_screen.dart';
import 'package:efnep_mobile/views/post_pages/screens/video_feed_scree.dart';
import 'package:efnep_mobile/views/widgets/custom_dialog_widget_view.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../entities/User.dart';
import '../../provider/language_provider.dart';
import 'package:efnep_mobile/models/authentication/FirebaseAuthServiceModel.dart'; // Import your FirebaseAuthServiceModel

List<String> types = ["Posts", "Videos", "Polls"];

List<String> S_types = ["Publicaciones", "Vídeos", "Centro"];

List<Widget> screens = [
  const FeedScreen(),
  const VideoFeedScreen(),
  PollsScreen(user: FirebaseAuth.instance.currentUser!,),
];

class PostPage extends StatefulWidget {
  final int index;
  const PostPage({Key? key, required this.index}) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> with TickerProviderStateMixin {
  late LanguageProvider _languageProvider;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageProvider = Provider.of<LanguageProvider>(context); // Get the LanguageProvider instance
  }

  late TabController _tabs;

  @override
  void initState() {
    _tabs = TabController(
        initialIndex: widget.index, length: types.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserData?>(context, listen: false);
    final authProvider = Provider.of<FirebaseAuthServiceModel>(context, listen: false); // Get the FirebaseAuthServiceModel instance

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: const SizedBox(),
          title: Text(
            _languageProvider.currentLanguage == Language.English
                ? "Community"
                : "Comunidad",
            style: const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return PostsProfileScreen(
                      uid: userProvider!.uid ?? "",
                      email: userProvider.email ?? "",
                    );
                  },
                ),
              ),
              icon: const Icon(
                Icons.person,
                color: primaryColor,
              ),
            ),
          ],
          backgroundColor: white,
          bottom: TabBar(
            controller: _tabs,
            isScrollable: true,
            indicatorColor: primaryColor,
            indicatorWeight: 4,
            tabs: List.generate(
              types.length,
              (index) => Tab(
                child: Text(
                  _languageProvider.currentLanguage == Language.English
                      ? types[index]
                      : S_types[index],
                  style: const TextStyle(
                    color: black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabs,
          children: List.generate(
            types.length,
            (index) => screens[index],
          ),
        ),
      ),
    );
  }
}