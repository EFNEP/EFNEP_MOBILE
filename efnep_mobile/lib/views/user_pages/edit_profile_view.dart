import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:efnep_mobile/provider/language_provider.dart';
import 'package:efnep_mobile/views/home_page/home_screen.dart';
import 'package:efnep_mobile/views/widgets/backbutton_widget_view.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import '../../constants/constants.dart';
import '../../constants/strings.dart';
import '../../models/authentication/FirebaseAuthServiceModel.dart';
import '../widgets/authbutton_widget_view.dart';
import '../widgets/custom_image_picker_widget_view.dart';
import '../widgets/input_with_icon.dart';
import 'user_profile_view.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({Key? key, required this.data}) : super(key: key);
  final DocumentSnapshot<Map?>? data;

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late LanguageProvider _languageProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageProvider = Provider.of<LanguageProvider>(
        context); // Get the LanguageProvider instance
  }

  // Declaring Necessary Variables

  final _formKey = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  double windowWidth = 0;
  double windowHeight = 0;
  XFile? _imageFile;
  String? profileImg;
  late String _id;
  bool photoUrl = true;
  String? selectedGender;
  List<String> genderOptions = ['Male', 'Female', 'Other'];
  List<String> S_genderOptions = ['Masculino', 'Femenina', 'Otro'];

  var user = FirebaseAuthServiceModel().getUserDetails();
  CollectionReference users = FirebaseFirestore.instance.collection("Users");
  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    phoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    selectedGender = widget.data!.data()!.containsKey('gender')
        ? widget.data!['gender']
        : null;
    phoneController = TextEditingController(
        text: widget.data!.data()!.containsKey('phone')
            ? widget.data!['phone']
            : null);
    ageController = TextEditingController(
        text: widget.data!.data()!.containsKey('age')
            ? widget.data!['age']
            : null);
  }

  void editProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _id = FirebaseAuth.instance.currentUser!.uid;
      if (_imageFile != null) {
        // upload profile pic to firebase storage
        firebase_storage.Reference ref =
            firebase_storage.FirebaseStorage.instance.ref('users/$_id.jpg');
        await ref.putFile(File(_imageFile!.path));
        profileImg = await ref.getDownloadURL();
      }
      users.doc(user!.email).update({
        "phone": phoneController.text.trim(),
        "age": ageController.text.trim(),
        "gender": selectedGender,
        "photoUrl": profileImg ??
            (widget.data!.data()!.containsKey('photoUrl')
                ? widget.data!['photoUrl']
                : ""),
      }).then((value) async {
        Fluttertoast.showToast(msg: "Profile Updated");
        setState(
          (() {
            phoneController.clear();
            _imageFile = null;
            photoUrl = false;
          }),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(
              isRefresh: true,
            ),
          ),
        );
        // Navigator.popUntil(context, (route) => route.isFirst);
      });
    }
  }

  void _pickImageFromCamera() async {
    try {
      final pickImage = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxHeight: 300,
        maxWidth: 300,
        imageQuality: 95,
      );
      setState(() {
        _imageFile = pickImage;
      });
    } catch (e) {
      setState(() {});
    }
  }

  void _pickImageFromGallery() async {
    try {
      final pickImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 300,
        maxWidth: 300,
        imageQuality: 95,
      );
      setState(() {
        _imageFile = pickImage;
      });
    } catch (e) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Size of the Screen
    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width;

    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButtonWidget(),
          backgroundColor: white,
          elevation: 0,
        ),
        backgroundColor: white,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _imageFile == null
                                ? AvatarImage(
                                    image: widget.data!['photoUrl'] ??
                                        defaultProfileImageURL,
                                    isNetworkImage:
                                        widget.data!['photoUrl'] != null
                                            ? true
                                            : false,
                                  )
                                : CircleAvatar(
                                    radius: 60,
                                    backgroundColor: primaryColor,
                                    backgroundImage: FileImage(
                                      File(_imageFile!.path),
                                    ),
                                  ),
                            const SizedBox(
                              width: 30,
                            ),
                            CustomImagePickerWidget(
                              pickCamera: _pickImageFromCamera,
                              pickGallery: _pickImageFromGallery,
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 10),
                          child: Text(
                            _languageProvider.currentLanguage ==
                                    Language.English
                                ? editProfileText
                                : editProfileTextSpanish,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    InputWithIcon(
                      obscure: false,
                      btnIcon: Icons.person_add,
                      hintText: "Enter your age",
                      myController: ageController,
                      keyboardType: TextInputType.number,
                      validateFunc: (val) {
                        if (val!.isEmpty) {
                          return "Age is required";
                        } else if (int.tryParse(val) == null) {
                          return "Age should be a number";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(children: [
                        SizedBox(
                          width: 60,
                          child: Icon(
                            Icons.person,
                            size: 20,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: DropdownButtonFormField<String>(
                              value: selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value;
                                });
                              },
                              items: _languageProvider.currentLanguage ==
                                      Language.English
                                  ? genderOptions.map((gender) {
                                      return DropdownMenuItem<String>(
                                        value: gender,
                                        child: Text(gender),
                                      );
                                    }).toList()
                                  : S_genderOptions.map((gender) {
                                      return DropdownMenuItem<String>(
                                        value: gender,
                                        child: Text(gender),
                                      );
                                    }).toList(),
                              decoration: const InputDecoration(
                                errorStyle: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 10),
                                border: InputBorder.none,
                                hintText: "Select Gender",
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                      ]),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    InputWithIcon(
                      btnIcon: Icons.phone,
                      hintText: phoneHintText,
                      myController: phoneController,
                      keyboardType: TextInputType.phone,
                      validateFunc: (value) {
                        String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
                        RegExp regExp = RegExp(pattern);
                        if (value!.isEmpty) {
                          return phoneEmptyWarning;
                        } else if (!regExp.hasMatch(value)) {
                          return invalidPhoneWarning;
                        }
                        return null;
                      },
                      obscure: false,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    AuthButtonWidget(
                      btnTxt:
                          _languageProvider.currentLanguage == Language.English
                              ? editProfileButtonText
                              : editProfileButtonTextSpanish,
                      onPress: () {
                        editProfile();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}