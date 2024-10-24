// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:efnep_mobile/views/auth_pages/forgot_password_page_view.dart';
import 'package:efnep_mobile/views/user_pages/gb_purchases.dart';
import 'package:efnep_mobile/views/user_pages/weight_tracker/wieght_page_view.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/profile_list_items.dart';
import '../../constants/strings.dart';
import '../../entities/User.dart';
import '../../models/authentication/FirebaseAuthServiceModel.dart';
import '../widgets/custom_dialog_widget_view.dart';
import 'edit_profile_view.dart';
import 'package:efnep_mobile/provider/language_provider.dart';
//import '../user_pages/good_bowls_counter_view.dart';

class ProfileListItems extends StatefulWidget {
  const ProfileListItems({Key? key}) : super(key: key);

  @override
  State<ProfileListItems> createState() => _ProfileListItemsState();
}

class _ProfileListItemsState extends State<ProfileListItems> {
  late LanguageProvider _languageProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageProvider = Provider.of<LanguageProvider>(
        context); // Get the LanguageProvider instance
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserData?>(context);

    final Stream<DocumentSnapshot<Map>> _userStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.email)
        .snapshots(includeMetadataChanges: true);
    return StreamBuilder<DocumentSnapshot<Map>>(
        stream: _userStream,
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map>> snapshot) {
          if (snapshot.hasError) {
            return const Text(wentWrong);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }

          return Expanded(
            child: ListView(
              children: <Widget>[
                ProfileListItem(
                  icon: LineAwesomeIcons.edit_1,
                  text: _languageProvider.currentLanguage == Language.English
                      ? editProfile
                      : editProfileSpanish,
                  onTapFunction: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditProfileView(
                                  data: snapshot.data,
                                )));
                  },
                ),
                ProfileListItem(
                  icon: LineAwesomeIcons.history,
                  text: _languageProvider.currentLanguage == Language.English
                      ? forgotPassword
                      : forgotPasswordSpanish,
                  onTapFunction: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgotPasswordView()));
                  },
                ),
                ProfileListItem(
                  icon: LineAwesomeIcons.plus_circle,
                  text: _languageProvider.currentLanguage == Language.English
                      ? goodBowlsCounter
                      :  goodBowlsCounterSpanish,
                  onTapFunction: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>  GBPurchasesPage()));
                  },
                ),
                ProfileListItem(
                  icon: LineAwesomeIcons.history,
                  text: _languageProvider.currentLanguage == Language.English
                      ? trackWeight
                      : trackWeightSpanish,
                  onTapFunction: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WeightPageView()));
                  },
                ),
                // const ProfileListItem(
                //   icon: LineAwesomeIcons.cog,
                //   text: 'Settings',
                // ),
                // const ProfileListItem(
                //   icon: LineAwesomeIcons.user_plus,
                //   text: 'Invite a Friend',
                // ),
                ProfileListItem(
                  icon: LineAwesomeIcons.alternate_sign_out,
                  text: _languageProvider.currentLanguage == Language.English
                      ? logout
                      : logoutSpanish,
                  onTapFunction: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: CustomConfirmDialog(
                          title: _languageProvider.currentLanguage ==
                                  Language.English
                              ? logout
                              : logoutSpanish,
                          subtitle: _languageProvider.currentLanguage ==
                                  Language.English
                              ? areYouSure
                              : areYouSureSpanish,
                          icon: const Icon(
                            Icons.logout,
                            color: white,
                            size: 70,
                          ),
                          onYesPressed: () {
                            setState(() async {
                              await Provider.of<FirebaseAuthServiceModel>(
                                      context,
                                      listen: false)
                                  .signOutUser()
                                  .then((value) =>
                                      Navigator.pushNamedAndRemoveUntil(
                                          context, "/", (route) => false));
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        });
  }
}