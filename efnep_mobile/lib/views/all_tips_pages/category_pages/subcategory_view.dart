// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../constants/strings.dart';
import '../../widgets/backbutton_widget_view.dart';
import 'tip_view.dart';

class SubCategoryView extends StatefulWidget {
  const SubCategoryView({Key? key, required this.category}) : super(key: key);
  final String category;

  @override
  State<SubCategoryView> createState() => _SubCategoryViewState();
}

class _SubCategoryViewState extends State<SubCategoryView> {
  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> _categoryStream = FirebaseFirestore.instance
        .collection('categories')
        .doc(widget.category)
        .snapshots(includeMetadataChanges: true);
    return StreamBuilder<DocumentSnapshot>(
        stream: _categoryStream,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
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

          try {
            return DefaultTabController(
              length: 10,
              child: Scaffold(
                appBar: AppBar(
                  leading: const BackButtonWidget(),
                  elevation: 0,
                  title: Text(
                    widget.category,
                    style: const TextStyle(
                        color: primaryColor,
                        
                        fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: white,
                  bottom: TabBar(
                    isScrollable: true,
                    indicatorColor: primaryColor,
                    indicatorWeight: 4,
                    tabs: List.generate(
                      snapshot.data!['sub_category'].length,
                      (index) => Tab(
                        child: Text(
                          snapshot.data!['sub_category'][index]['text'],
                          style: const TextStyle(
                              color: black,
                              
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ),
                body: TabBarView(
                  children: List.generate(
                    snapshot.data!['sub_category'].length,
                    (index) => TipView(
                      cat: widget.category,
                      subCat: snapshot.data!['sub_category'][index]['text'],
                    ),
                  ),
                ),
              ),
            );
          } catch (e) {
            return const Scaffold(
              body: Center(
                child: Text(
                  "Data not found!",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            );
          }
        });
  }
}
