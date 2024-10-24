import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:efnep_mobile/models/authentication/FirebaseAuthServiceModel.dart';
import 'package:efnep_mobile/provider/language_provider.dart';
import 'package:efnep_mobile/services/analytics.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:efnep_mobile/constants/colors.dart';
import 'package:efnep_mobile/entities/User.dart';
import "package:http/http.dart" as http;
import '../../../services/notification.dart';
import '../add_post_page_view.dart';
import '../resources/firestore_methods.dart';
import '../utils/utils.dart';

class AddVideoPostScreen extends StatefulWidget {
  const AddVideoPostScreen({Key? key}) : super(key: key);

  @override
  _AddVideoPostScreenState createState() => _AddVideoPostScreenState();
}

class _AddVideoPostScreenState extends State<AddVideoPostScreen> {
  late LanguageProvider _languageProvider;
  late UserData? _user; // Updated to hold user data

  File? _file; // Use File for video
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();
  late VideoPlayerController _controller;
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    super.initState();
    _languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    notificationServices.requestNotificationPermission();
    notificationServices.forgroundMessage();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();
    analytics('AddVideoScreen', 'AddVideoScreen');

    notificationServices.getDeviceToken().then((value) {
      if (kDebugMode) {
        print('device token');
        print(value);
      }
    });

    _controller = VideoPlayerController.asset("assets/video_placeholder.mp4")
      ..initialize().then((_) {
        // Ensure the first frame is shown and set the initial value of _controller.
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  _selectImage(BuildContext parentContext) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedVideo =
        await picker.pickVideo(source: ImageSource.gallery);

    if (pickedVideo != null) {
      setState(() {
        _file = File(pickedVideo.path);
        _controller = VideoPlayerController.file(_file!)
          ..initialize().then((_) {
            setState(() {}); // Ensure the first frame is shown and set the initial value of _controller.
          });
      });
    }
  }

  void postImage(String uid, String username, String profImage) async {
    setState(() {
      isLoading = true;
    });
    try {
      String res = await FireStoreMethods().uploadVideoPost(
        _descriptionController.text,
        _file!,
        uid,
        username,
        profImage,
      );

      // send notification from one device to another
      notificationServices.getDeviceToken().then((value) async {
        var data = {
          'to': '/topics/all',
          'notification': {'title': 'New Post', 'body': 'Posted by $username'},
          'data': {'type': 'msj'}
        };

        await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          body: jsonEncode(data),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization':
                'key=AAAAMYZh6jU:APA91bEH8Jv_QKb0PPHIQSlM6RLcgF5oQoEIvW9H0OSh3CVgE5k9Dwfyg2HXPbPdW-aD3JzfkDfAKERTFyK9qk4eByWotAiHUgQx39zNmxIebLxLZBBmlRgFUVIDeAFP6Wr1skB1raVg'
          },
        ).then((value) {
          if (kDebugMode) {
            print(value.body.toString());
          }
        }).onError((error, stackTrace) {
          if (kDebugMode) {
            print(error);
          }
        });
      });

      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Posted!'),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PostPage(index: 1),
            ),
          );
          Navigator.popUntil(context, (route) => route.isFirst);
        }
        clearImage();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res),
            ),
          );
        }
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.toString()),
        ),
      );
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authServiceProvider =
        Provider.of<FirebaseAuthServiceModel>(context);

    return StreamBuilder<UserData?>(
      stream: authServiceProvider.onAuthStateChanged(),
      builder: (_, AsyncSnapshot<UserData?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          );
        } else if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return const Center(child: Text("Something went wrong!"));
        } else {
          _user = snapshot.data;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                _languageProvider.currentLanguage == Language.English
                    ? 'Create a Video Post'
                    : 'Crear una publicación de vídeo',
              ),
              backgroundColor: notWhite,
              elevation: 0,
            ),
            body: _file == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _languageProvider.currentLanguage == Language.English
                              ? 'Create a Video Post'
                              : 'Crear una publicación de vídeo',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.upload),
                          onPressed: () => _selectImage(context),
                        ),
                        Text(
                          _languageProvider.currentLanguage == Language.English
                              ? 'Click the upload icon to create a video post'
                              : 'Haz clic en el ícono de carga para crear una publicación de video',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: <Widget>[
                      isLoading
                          ? const LinearProgressIndicator()
                          : const Padding(padding: EdgeInsets.only(top: 0.0)),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage:
                                NetworkImage(_user!.photoUrl ?? ""),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: TextField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                hintText: "Write a caption...",
                                border: InputBorder.none,
                              ),
                              maxLines: 8,
                            ),
                          ),
                          SizedBox(
                            height: 45.0,
                            width: 45.0,
                            child: AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: clearImage,
                          ),
                          TextButton(
                            onPressed: () => postImage(
                              _user!.uid ?? "",
                              _user!.displayName ?? "",
                              _user!.photoUrl ?? "",
                            ),
                            child: Text(
                              _languageProvider.currentLanguage ==
                                      Language.English
                                  ? "Post"
                                  : "Publicar",
                              style: const TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          );
        }
      },
    );
  }
}
