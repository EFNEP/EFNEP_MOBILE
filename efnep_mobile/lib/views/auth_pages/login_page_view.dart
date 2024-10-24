import 'package:flutter/material.dart';
import 'package:efnep_mobile/provider/language_provider.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../controllers/AuthController.dart';
import '../utilities/show_error_view.dart';
import '../widgets/authbutton_widget_view.dart';
import '../widgets/input_with_icon.dart';
import '../widgets/outlined_button_with_image.dart';

class LoginPageView extends StatefulWidget {
  const LoginPageView({Key? key}) : super(key: key);

  @override
  State<LoginPageView> createState() => _LoginPageViewState();
}

class _LoginPageViewState extends State<LoginPageView> {
  // Declaring Necessary Variables
  int _pageState = 0;
 late LanguageProvider _languageProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageProvider = Provider.of<LanguageProvider>(context); // Get the LanguageProvider instance
  }




  final loginFormKey = GlobalKey<FormState>();
  final signUpFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPassController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  Color _backgroundColor = white;
  Color _headingColor = primaryColor;
  Color _arrowColor = white;

  double _headingTop = 120;
  double _loginYOffset = 0;
  double _registerYOffset = 0;

  double windowWidth = 0;
  double windowHeight = 0;

  
//  @override
//   void initState() {
//     super.initState();
//     _isEnglish = true; // Set default language to English
//   }
  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    confirmPassController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     //String currentLanguage = _languageProvider.currentLanguage.toString();

    // Size of the Screen
    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width;

    switch (_pageState) {
      case 0:
        _backgroundColor = white;
        _headingColor = primaryColor;
        _loginYOffset = windowHeight;
        _registerYOffset = windowHeight;
        _headingTop = 55;
        _arrowColor = white;
        break;
      case 1:
        _backgroundColor = primaryColor;
        _headingColor = white;
        _loginYOffset = windowHeight * 0.268;
        _registerYOffset = windowHeight;
        _headingTop = 30;
        _arrowColor = white;
        break;
      case 2:
        _backgroundColor = white;
        _headingColor = primaryColor;
        _loginYOffset = windowHeight * 0.3;
        _registerYOffset = 0;
        _headingTop = 30;
        _arrowColor = Colors.white;
        break;
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Stack(
          children: [
            AnimatedContainer(
              curve: Curves.fastLinearToSlowEaseIn,
              duration: const Duration(milliseconds: 1000),
              color: _backgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      GestureDetector(
                        child: SafeArea(
                          child: Container(
                            alignment: Alignment.topLeft,
                            margin: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: _arrowColor,
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            if (_pageState == 2) {
                              _pageState = 1;
                            } else {
                              _pageState = 0;
                            }
                          });
                        },
                      ),
                      AnimatedContainer(
                        curve: Curves.fastLinearToSlowEaseIn,
                        duration: const Duration(milliseconds: 1000),
                        margin: EdgeInsets.only(top: _headingTop),
                        child: Text(
                          appName,
                          style: TextStyle(
                            color: _headingColor,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          introTagline,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _headingColor,
                            fontSize: 16,
                          ),
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 40, horizontal: 32),
                          child: AuthButtonWidget(
                            key: widget.key,
                            btnTxt: introNextButton,
                            backgroundColor: primaryColor,
                            onPress: () {
                              setState(() {
                                if (_pageState != 0) {
                                  _pageState = 0;
                                } else {
                                  _pageState = 1;
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Login Section
            Form(
              key: loginFormKey,
              child: SafeArea(
                child: AnimatedContainer(
                  padding: const EdgeInsets.all(32),
                  curve: Curves.fastLinearToSlowEaseIn,
                  duration: const Duration(milliseconds: 1000),
                  transform: Matrix4.translationValues(0, _loginYOffset, 1),
                  decoration: const BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    children: [
                      Column(
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            child:  Text(
                              _languageProvider.currentLanguage == Language.English
                                  ? loginPageHeading
                                  : loginPageHeadingSpanish,
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InputWithIcon(
                            btnIcon: Icons.email_outlined,
                            hintText: _languageProvider.currentLanguage == Language.English
                                ? emailHintText
                                : emailHintTextSpanish,
                            myController: emailController,
                            validateFunc: (value) {
                              if (value!.isEmpty) {
                                return emailFieldEmpty;
                              } else if (!value.contains(RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"
                                ))) {
                                return invalidEmailFormat;
                              }
                              return null;
                            },
                            obscure: false,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                           InputWithIcon(
                            btnIcon: Icons.vpn_key,
                            hintText: _languageProvider.currentLanguage == Language.English
                                ? passwordHintText
                                : passwordHintTextSpanish,
                            myController: passwordController,
                            obscure: true,
                            validateFunc: (value) {
                              if (value!.isEmpty) {
                                return passwordFieldEmpty;
                              } else if (value.length < 6) {
                                return passwordLengthWarning;
                              }
                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pushNamed(context, "/forgotPassword");
                            },
                            child: Text(
                              forgotPasswordText,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          AuthButtonWidget(
                            btnTxt: _languageProvider.currentLanguage == Language.English
                            ?loginButtonText:
                            loginButtonTextSpanish,
                            onPress: () async {
                              // Act only after the form fields are validated
                              if (loginFormKey.currentState!.validate()) {
                                // Trigger Login functionality
                                var userResult =
                                    await AuthController().loginWithEmailPassword(
                                      emailController.text.trim(),
                                      passwordController.text.trim(),
                                    );
                                debugPrint("Hii:");

                                // Show error messages if any
                                if (mounted) {

                                  debugPrint(userResult.toString());
                                  if (userResult!.authStatusMessage != null) {
                                    showBottomNotificationMessage(
                                      context,
                                      userResult.authStatusMessage!,
                                    );
                                  }
                                  // Navigate to the home screen after successful login
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, "/", (route) => false);
                                }
                              }
                            },
                          ),

                          const SizedBox(
                            height: 20,
                          ),
                          CustomOutlineButton(
                            buttonText: _languageProvider.currentLanguage == Language.English
                            ?googleLoginButtonText:googleLoginButtonTextSpanish,
                            imageUrl: "assets/google_logo.png",
                            onPressed: () async {
                              // Trigger Google Sign in
                              await AuthController().loginWithGoogle();
                              if (mounted) {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, "/", (route) => false);
                              }
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          CustomOutlineButton(
                            buttonText: _languageProvider.currentLanguage == Language.English
                            ?signUpRedirectText:signUpButtonTextSpanish,
                            onPressed: () {
                              setState(
                                    () {
                                  _pageState = 2;
                                  emailController.clear();
                                  passwordController.clear();
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // SignUp Section
            Form(
              key: signUpFormKey,
              child: Center(
                child: SafeArea(
                  child: AnimatedContainer(
                    padding: const EdgeInsets.all(32),
                    curve: Curves.fastLinearToSlowEaseIn,
                    duration: const Duration(milliseconds: 1000),
                    transform: Matrix4.translationValues(0, _registerYOffset, 1),
                    decoration: const BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 10),
                              child: Text(
                               _languageProvider.currentLanguage == Language.English? signUpPageHeading:signUpPageHeadingSpanish,
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            )
                          ],
                        ),
                        InputWithIcon(
                          obscure: false,
                          btnIcon: Icons.account_circle_rounded,
                          hintText: _languageProvider.currentLanguage == Language.English
                          ?nameHintText:nameHintTextSpanish,
                          myController: nameController,
                          keyboardType: TextInputType.emailAddress,
                          validateFunc: (val) {
                            val = val?.trim();
                            String pattern = r'^[a-zA-Z]+[\s]+[a-zA-Z]+$';
                            RegExp regExp = RegExp(pattern);
                            if (val!.isEmpty) {
                              return nameEmptyWarning;
                            } else if (!regExp.hasMatch(val)) {
                              return invalidNameWarning;
                            }
                            return null;
                          },
                        ),
                        InputWithIcon(
                          btnIcon: Icons.phone,
                          hintText:_languageProvider.currentLanguage == Language.English
                          ? phoneHintText:phoneHintTextSpanish,
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
                        InputWithIcon(
                          btnIcon: Icons.email_outlined,
                          hintText: _languageProvider.currentLanguage == Language.English
                          ?emailHintText:emailHintTextSpanish,
                          myController: emailController,
                          validateFunc: (value) {
                            if (value!.isEmpty) {
                              return emailFieldEmpty;
                            } else if (!value.contains(RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"))) {
                              return invalidEmailFormat;
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                          obscure: false,
                        ),
                        InputWithIcon(
                          btnIcon: Icons.vpn_key,
                          hintText: _languageProvider.currentLanguage == Language.English
                          ?passwordHintText:passwordHintText,
                          obscure: true,
                          myController: passwordController,
                          keyboardType: TextInputType.emailAddress,
                          validateFunc: (value) {
                            if (value!.isEmpty) {
                              return passwordFieldEmpty;
                            } else if (value.length < 6) {
                              return passwordLengthWarning;
                            }
                            return null;
                          },
                        ),
                        InputWithIcon(
                          btnIcon: Icons.vpn_key,
                          hintText: _languageProvider.currentLanguage == Language.English
                          ?confirmPasswordHintText:confirmPasswordHintTextSpanish,
                          obscure: true,
                          myController: confirmPassController,
                          validateFunc: (val) {
                            if (val!.isEmpty) {
                              return confirmPasswordFieldEmpty;
                            }
                            if (val != passwordController.text) {
                              return confirmPasswordNotMatchingText;
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        AuthButtonWidget(
                          btnTxt: _languageProvider.currentLanguage == Language.English
                          ?signUpButtonText:signUpButtonTextSpanish,
                          onPress: () async {
                            // Act only after the form fields are validated
                            if (signUpFormKey.currentState!.validate()) {
                              // Trigger SingUp functionality
                              var userResult =
                                  await AuthController().registerWithEmailPassword(
                                emailController.text.trim(),
                                confirmPassController.text.trim(),
                                nameController.text.trim(),
                                phoneController.text.trim(),
                              );
                              // Show error messages if any
                              if (mounted) {

                                debugPrint(userResult.toString());
                                if (userResult?.authStatusMessage != null) {
                                  showBottomNotificationMessage(
                                    context,
                                    userResult!.authStatusMessage!,
                                  );
                                }
                                Navigator.pushNamedAndRemoveUntil(
                                    context, "/setProfileImage", (route) => false);
                              }
                            }
                          },
                        ),
                        CustomOutlineButton(
                          buttonText: _languageProvider.currentLanguage == Language.English
                          ?loginRedirectText:loginRedirectTextSpanish,
                          onPressed: () {
                            setState(
                                  () {
                                _pageState = 1;
                                emailController.clear();
                                passwordController.clear();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        Positioned(
      top: 40,
      right: 20,
      child: DropdownButton<Language>(
        value: _languageProvider.currentLanguage,
        onChanged: (Language? newValue) {
          if (newValue != null) {
            _languageProvider.changeLanguage(newValue);
          }
        },
        items: Language.values.map((language) {
          return DropdownMenuItem<Language>(
            value: language,
            child: Text(language == Language.English ? 'English' : 'Spanish'),
          );
        }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
        