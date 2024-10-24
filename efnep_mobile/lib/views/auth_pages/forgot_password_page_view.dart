import 'package:flutter/material.dart';
import '../../views/widgets/backbutton_widget_view.dart';

import 'package:efnep_mobile/provider/language_provider.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../controllers/AuthController.dart';
import '../utilities/show_error_view.dart';
import '../widgets/input_with_icon.dart';
import '../widgets/round_edge_filled_button.dart';


class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}
class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();


   late LanguageProvider _languageProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageProvider = Provider.of<LanguageProvider>(context); // Get the LanguageProvider instance
  }
  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        leading: const BackButtonWidget(),
      ),
      body: Form(
        key: _formKey,
        child: AnimatedContainer(
          padding: const EdgeInsets.all(32),
          curve: Curves.fastLinearToSlowEaseIn,
          duration: const Duration(milliseconds: 1000),
          transform: Matrix4.translationValues(0, 0, 1),
          decoration: const BoxDecoration(
            color: white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
               Text(
  _languageProvider.currentLanguage == Language.English
    ? forgotPasswordText
    : forgotPasswordTextSpanish,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
  _languageProvider.currentLanguage == Language.English
    ? forgotPasswordDescription
    : forgotPasswordDescriptionSpanish,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
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
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"))) {
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
              RoundEdgeFilledButton(
                  buttonText: passwordResetSendEmailButtonText,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        // Trigger Google Sign in
                        await AuthController()
                            .forgotPassword(emailController.text.trim());

                        if (mounted) {
                          showBottomNotificationMessage(
                            context,
                            "Email sent successfully! Use the new password to login.",
                          );
                          Navigator.pushNamedAndRemoveUntil(
                              context, "/", (route) => false);
                        }
                      } catch (e) {
                        debugPrint(e.toString());
                        debugPrint('error sending email');
                        showBottomNotificationMessage(
                          context,
                          "Error resetting your password! Please try again.",
                        );
                      }
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
