import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:efnep_mobile/services/analytics.dart';
import 'package:efnep_mobile/views/widgets/backbutton_widget_view.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../constants/strings.dart';
import '../../../entities/User.dart';
import '../app_theme.dart';

class GoalListView extends StatefulWidget {
  final String goal;
  final String unit;
  final String type;
  const GoalListView(
      {Key? key, required this.goal, required this.unit, required this.type})
      : super(key: key);
  @override
  State<GoalListView> createState() => _GoalListViewState();
}

class _GoalListViewState extends State<GoalListView>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  @override
  void initState() {
    analytics('Goals', 'GoalListView');
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserData?>(context);
    final Stream<QuerySnapshot> goalStream = FirebaseFirestore.instance
        .collection('progress')
        .doc(user!.email ?? "")
        .collection('goals')
        .doc(widget.goal)
        .collection('daily_progress')
        .snapshots(includeMetadataChanges: true);
    return StreamBuilder<QuerySnapshot>(
      stream: goalStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text(
                wentWrong,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            ),
          );
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text(
                noData,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          );
        }
        final reversedDocs =
            snapshot.data!.docs.reversed.toList(); // Reverse the list

        try {
          return Scaffold(
            body: Column(
              children: [
                getAppBarUI(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    children: List.generate(
                      reversedDocs.length,
                      (index) {
                        final docId = reversedDocs[index].reference.id;
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: primaryColor,
                              child: Text(
                                (index + 1).toString(),
                                style: const TextStyle(
                                  color: white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            title: Text(
                              (reversedDocs[index]['progress'] *
                                          int.parse(widget.unit))
                                      .toString() +
                                  widget.type,
                              style: const TextStyle(
                                color: black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              docId,
                              style: const TextStyle(
                                color: black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        } catch (e) {
          return const Scaffold(
            body: Center(
              child: Text(
                wentWrong,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          );
        }
      },
    );
  }

  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32.0),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: AppTheme.grey.withOpacity(0.4),
                  offset: const Offset(1.1, 1.1),
                  blurRadius: 10.0),
            ],
          ),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).padding.top,
              ),
              const Padding(
                padding: EdgeInsets.only(
                    left: 16, right: 16, top: 16 - 8.0, bottom: 12 - 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    BackButtonWidget(),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'History',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontWeight: FontWeight.w700,
                            fontSize: 22 + 6 - 6,
                            letterSpacing: 1.2,
                            color: AppTheme.darkerText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
