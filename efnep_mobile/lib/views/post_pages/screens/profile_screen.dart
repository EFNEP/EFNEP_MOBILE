import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:efnep_mobile/views/post_pages/widgets/profile_post_card.dart';
import 'package:efnep_mobile/views/post_pages/widgets/profile_vide_card.dart';
import 'package:efnep_mobile/views/widgets/backbutton_widget_view.dart';
import '../../../constants/colors.dart';
import '../utils/utils.dart';

class PostsProfileScreen extends StatefulWidget {
  final String uid;
  final String email;
  const PostsProfileScreen({Key? key, required this.uid, required this.email})
      : super(key: key);

  @override
  State<PostsProfileScreen> createState() => _PostsProfileScreenState();
}

class _PostsProfileScreenState extends State<PostsProfileScreen>
    with TickerProviderStateMixin {
  var userData = {};
  int postLen = 0;
  int videoLen = 0;
  bool isLoading = false;
  late TabController _tabController;
  bool _isMounted = false;

  @override
  void initState() {
    getData();
    _tabController = TabController(length: 2, vsync: this);
    _isMounted = true;
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.email)
          .get();

      // get post lENGTH
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      // get video length
      var videoSnap = await FirebaseFirestore.instance
          .collection('video-posts')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (_isMounted) {
        // Update the state only if the widget is still mounted
        postLen = postSnap.docs.length;
        videoLen = videoSnap.docs.length;
        userData = userSnap.data()!;
        setState(() {});
      }
    } catch (e) {
      if (_isMounted) {
        showSnackBar(
          context,
          e.toString(),
        );
      }
    }

    if (_isMounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: notWhite,
          title: Text(
            userData['name'] ?? "No username",
          ),
          centerTitle: false,
          leading: const BackButtonWidget(),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            getData();
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey,
                          backgroundImage: NetworkImage(
                            userData['photoUrl'] ?? "https://brent-mccardle.org/img/placeholder-image.png",
                          ),
                          radius: 40,
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  buildStatColumn(postLen, "posts"),
                                  buildStatColumn(videoLen, "videos"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(
                        top: 15,
                      ),
                      child: Text(
                        userData['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                color: greyLight,
              ),
              TabBar(
                isScrollable: true,
                controller: _tabController,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.grid_on),
                  ),
                  Tab(
                    icon: Icon(Icons.video_collection),
                  ),
                ],
              ),
              const Divider(
                color: greyLight,
              ),
              const SizedBox(
                height: 3,
              ),
              Expanded(
                child: TabBarView(controller: _tabController, children: [
                  FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('posts')
                        .where('uid', isEqualTo: widget.uid)
                        .orderBy('datePublished', descending: true)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          getData();
                        },
                        child: GridView.builder(
                          shrinkWrap: true,
                          itemCount: (snapshot.data! as dynamic).docs.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 1.5,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            DocumentSnapshot snap =
                                (snapshot.data! as dynamic).docs[index];
                      
                            return PostProfileCard(
                                snap: snap,
                                postUrl: snap['postUrl'],
                                caption: snap['description']);
                          },
                        ),
                      );
                    },
                  ),
                  FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('video-posts')
                        .where('uid', isEqualTo: widget.uid)
                        .orderBy('datePublished', descending: true)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          getData();
                        },
                        child: GridView.builder(
                          shrinkWrap: true,
                          itemCount: (snapshot.data! as dynamic).docs.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 1.5,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            DocumentSnapshot snap =
                                (snapshot.data! as dynamic).docs[index];
                      
                            return VideoProfileCard(
                                snap: snap,
                                videoUrl: snap['videoUrl'],
                                caption: snap['description']);
                          },
                        ),
                      );
                    },
                  ),
                ]),
              )
            ],
          ),
        ),
      );
    }
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
