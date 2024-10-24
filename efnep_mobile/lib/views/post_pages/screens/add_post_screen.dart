// ignore_for_file: library_private_types_in_public_api
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:efnep_mobile/entities/User.dart';
import 'package:efnep_mobile/services/analytics.dart';
import 'package:efnep_mobile/views/post_pages/add_post_page_view.dart';
import 'package:image_picker/image_picker.dart';
import '../../../provider/language_provider.dart';
import '../../../services/notification.dart';
import '../resources/firestore_methods.dart';
import '../../../constants/colors.dart';
import '../utils/utils.dart';
import 'package:provider/provider.dart';
import "package:http/http.dart" as http;

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  late LanguageProvider _languageProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageProvider = Provider.of<LanguageProvider>(
        context); // Get the LanguageProvider instance
  }

  Uint8List? _file;
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    super.initState();
    notificationServices.requestNotificationPermission();
    notificationServices.forgroundMessage();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();
    analytics('AddPostScreen', 'AddPostScreen');

    notificationServices.getDeviceToken().then((value) {
      if (kDebugMode) {
        print('device token');
        print(value);
      }
    });
  }

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            _languageProvider.currentLanguage == Language.English
                ? 'Create a Post'
                : 'Crear una Publicación',
          ),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: Text(
                  _languageProvider.currentLanguage == Language.English
                      ? 'Take a photo'
                      : 'Toma una foto',
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: Text(
                  _languageProvider.currentLanguage == Language.English
                      ? 'Choose from Gallery'
                      : 'Elegir de la galería',
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: Text(
                _languageProvider.currentLanguage == Language.English
                    ? 'Cancel'
                    : 'Cancelar',
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void postImage(String uid, String username, String profImage) async {
    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      // upload to storage and db
      String res = await FireStoreMethods().uploadPost(
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

        await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
            body: jsonEncode(data),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization':
                  'key=AAAAMYZh6jU:APA91bEH8Jv_QKb0PPHIQSlM6RLcgF5oQoEIvW9H0OSh3CVgE5k9Dwfyg2HXPbPdW-aD3JzfkDfAKERTFyK9qk4eByWotAiHUgQx39zNmxIebLxLZBBmlRgFUVIDeAFP6Wr1skB1raVg'
            }).then((value) {
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
          showSnackBar(
            context,
            'Posted!',
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PostPage(index: 0),
            ),
          );
          Navigator.popUntil(context, (route) => route.isFirst);
        }
        clearImage();
      } else {
        if (mounted) {
          showSnackBar(context, res);
        }
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserData?>(context, listen: false);

    return _file == null
        ? Scaffold(
            appBar: AppBar(
              title: Text(
                _languageProvider.currentLanguage == Language.English
                    ? 'Create a Post'
                    : 'Crear una Publicación',
              ),
              backgroundColor: notWhite,
              elevation: 0,
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        _languageProvider.currentLanguage == Language.English
                            ? 'Create a Post'
                            : 'Crear una Publicación',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                    Center(
                      child: IconButton(
                        icon: const Icon(
                          Icons.upload,
                        ),
                        onPressed: () => _selectImage(context),
                      ),
                    ),
                  ],
                ),
                Text(
                  _languageProvider.currentLanguage == Language.English
                      ? 'Click the upload icon to create a post'
                      : 'Haga clic en el icono de carga para crear una publicación',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: notWhite,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: clearImage,
              ),
              title: Text(
                _languageProvider.currentLanguage == Language.English
                    ? 'Post to'
                    : 'Publicar en',
              ),
              centerTitle: false,
              actions: <Widget>[
                TextButton(
                  onPressed: () => postImage(
                    userProvider!.uid ?? "",
                    userProvider.displayName ?? "",
                    userProvider.photoUrl ?? "",
                  ),
                  child: Text(
                    _languageProvider.currentLanguage == Language.English
                        ? 'Post'
                        : 'Publicar',
                    style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  ),
                )
              ],
            ),
            // POST FORM
            body: Column(
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
                      backgroundImage: NetworkImage(
                        userProvider!.photoUrl ?? "",
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                            hintText: "Write a caption...",
                            border: InputBorder.none),
                        maxLines: 8,
                      ),
                    ),
                    SizedBox(
                      height: 45.0,
                      width: 45.0,
                      child: AspectRatio(
                        aspectRatio: 487 / 451,
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            fit: BoxFit.fill,
                            alignment: FractionalOffset.topCenter,
                            image: MemoryImage(_file!),
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
              ],
            ),
          );
  }
}
