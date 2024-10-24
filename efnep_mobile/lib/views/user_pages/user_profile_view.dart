  // ignore_for_file: prefer_interpolation_to_compose_strings, deprecated_member_use

  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:flutter/material.dart';
import 'package:efnep_mobile/models/authentication/FirebaseAuthServiceModel.dart';
  import 'package:provider/provider.dart';
  import 'package:url_launcher/url_launcher.dart';
  import '../../constants/colors.dart';
  import '../../constants/constants.dart';
  import '../../constants/strings.dart';
  import '../../entities/User.dart';
  import 'profile_list_items.dart';
  import 'package:efnep_mobile/provider/language_provider.dart';

  class UserProfileView extends StatefulWidget {
    const UserProfileView({Key? key}) : super(key: key);

    @override
    State<UserProfileView> createState() => _UserProfileViewState();
  }

  class _UserProfileViewState extends State<UserProfileView> {

    late LanguageProvider _languageProvider;
    @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      _languageProvider = Provider.of<LanguageProvider>(context); // Get the LanguageProvider instance
    }
    @override
    Widget build(BuildContext context) {
       final authServiceProvider = Provider.of<FirebaseAuthServiceModel>(context);


      return Scaffold(appBar: AppBar(
          backgroundColor: white,
        actions: [
          DropdownButton<Language>(
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
        ],
      ),
        body: StreamBuilder<UserData?>(
                  stream: authServiceProvider.onAuthStateChanged(),
                  builder: (_, AsyncSnapshot<UserData?> snapshot) {
              //       if (snapshot.hasError) {
              //         return const Text(wentWrong);
              //       }
              //       else{
              //         final user1 = snapshot.data;
              //          getAppBarUI(user1);
              // const SizedBox(
              //   height: 10,
              // ),
              //       }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                        ),
                      );
                    }
                    else if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return const Center(child: Text("Something went wrong!"));
        } else {
          final user = snapshot.data;
          // final viv = user!.displayName;
          // getAppBarUI(user);
          //  debugPrint("****** Adi ${user?.displayName} - ${user?.email}");
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // AppBarButton(
                        //   icon: Icons.privacy_tip,

                        // ),
                          IconButton(
                              onPressed: () {
                                //launch Url
                                launch("https://github.com/goodbowlsadmin/privacy-policy/blob/main/privacy-policy.md");
                              },
                              icon: const Icon(Icons.privacy_tip)),
                          // SvgPicture.asset("assets/icons/menu.svg"),
                        ],
                      ),
                    ),
                     (user!.photoUrl != null)
                      ? AvatarImage(
                          image: '${user.photoUrl}',
                          isNetworkImage: true,
                        )
                      : AvatarImage(
                          image: '${user.photoUrl}' ??
                              defaultProfileImageURL,
                          isNetworkImage:
                              user.photoUrl != null ? true : false,
                        ),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                     "${user.displayName}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                     "${user.email}",
                    style: const TextStyle(fontWeight: FontWeight.w300),
                  ),
                Text(
    _languageProvider.currentLanguage == Language.English
        ? participationId
        : participationIdSpanish,
    style: const TextStyle(
      fontWeight: FontWeight.w300, 
      fontSize: 20,
    ),
  ),

                    const SizedBox(height: 10),
                    Text(
                      // snapshot.data!.data()!.containsKey('worksite')
                      //     ? "Worksite :" + snapshot.data!['worksite']:
                      _languageProvider.currentLanguage == Language.English?worksiteId:worksiteIdSpanish,
                      style: const TextStyle(
                          fontWeight: FontWeight.w300, fontSize: 20),
                    ),
                    const ProfileListItems(),
                    const Padding(
                      padding: EdgeInsets.only(top: 60),
                    )
                  ],
                ),
              );
            }}),
      );
    }
  }

  class AppBarButton extends StatelessWidget {
    final IconData? icon;

    const AppBarButton({Key? key, this.icon}) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(shape: BoxShape.circle,
            // color: kAppPrimaryColor,
            boxShadow: [
              BoxShadow(
                color: kLightBlack,
                offset: const Offset(1, 1),
                blurRadius: 10,
              ),
              BoxShadow(
                color: kWhite,
                offset: const Offset(-1, -1),
                blurRadius: 10,
              ),
            ]),
        child: Icon(
          icon,
          color: transparent,
        ),
      );
    }
  }

  class AvatarImage extends StatelessWidget {
    final String image;
    final bool isNetworkImage;
    const AvatarImage(
        {Key? key, required this.image, required this.isNetworkImage})
        : super(key: key);

    @override
    Widget build(BuildContext context) {
      return Container(
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(8),
        decoration: avatarDecoration,
        child: isNetworkImage
            ? Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: NetworkImage(image), fit: BoxFit.cover),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
      );
    }
  }