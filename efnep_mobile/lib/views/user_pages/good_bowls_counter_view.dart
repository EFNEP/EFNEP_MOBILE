// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:good_bowls/constants/colors.dart';
// import 'package:good_bowls/provider/language_provider.dart';
// import 'package:provider/provider.dart';

// class GoodBowlsCounterView extends StatefulWidget {
//   const GoodBowlsCounterView({Key? key}) : super(key: key);

//   @override
//   State<GoodBowlsCounterView> createState() => _GoodBowlsCounterViewState();
// }

// class _GoodBowlsCounterViewState extends State<GoodBowlsCounterView> {
//   late LanguageProvider _languageProvider;
//   List<Map<String, dynamic>> _updates = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchCounterFromFirestore();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _languageProvider = Provider.of<LanguageProvider>(context);
//   }

//   void _fetchCounterFromFirestore() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('GBTracker')
//         .doc('counter')
//         .get();
//     final data = snapshot.data();
//     if (data != null && data.containsKey('updates')) {
//       setState(() {
//         _updates = List<Map<String, dynamic>>.from(data['updates']);
//       });
//     }
//   }

//   void _incrementCounter() {
//     final now = DateTime.now();
//     final formattedDate = '${now.year}-${now.month}-${now.day}';
//     final lastUpdateDate =
//         _updates.isNotEmpty ? _updates.last['date'] : null;
//     if (lastUpdateDate != formattedDate) {
//       // Add a new card if the date has changed
//       final update = {
//         'counter': _updates.length + 1,
//         'date': formattedDate,
//       };
//       setState(() {
//         _updates.add(update);
//       });
//     } else {
//       // Update the last card if the date is the same
//       final lastUpdate = _updates.last;
//       final updatedCounter = lastUpdate['counter'] + 1;
//       final updatedUpdate = {
//         'counter': updatedCounter,
//         'date': formattedDate,
//       };
//       setState(() {
//         _updates[_updates.length - 1] = updatedUpdate;
//       });
//     }

//     // Update counter value in Firestore
//     FirebaseFirestore.instance
//         .collection('GBTracker')
//         .doc('counter')
//         .set({'value': _updates.length, 'updates': _updates});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: Text(
//           _languageProvider.currentLanguage == Language.English
//               ? 'Good bowls tracker'
//               : 'Seguimiento de buenos tazones',
//           style: const TextStyle(
//             color: Colors.white,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Text(
//               _languageProvider.currentLanguage == Language.English
//                   ? 'If you purchased a good bowl today, tap plus.'
//                   : 'Si compraste un buen tazón hoy, toca el botón más.',
//               style: const TextStyle(
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 FloatingActionButton(
//                   onPressed: _incrementCounter,
//                   tooltip: 'Increment',
//                   child: const Icon(Icons.add),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _updates.length,
//                 itemBuilder: (context, index) {
//                   final update = _updates[index];
//                   return Card(
//                     margin: const EdgeInsets.symmetric(vertical: 8),
//                     child: ListTile(
//                       leading: Container(
//                         width: 30,
//                         height: 30,
//                         decoration: const BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: primaryColor,
//                         ),
//                         alignment: Alignment.center,
//                         child: Text(
//                           '${index + 1}',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       title: Text(
//                         'Counter Value: ${update['counter']}\nDate of Purchase: ${update['date']}',
//                         style: const TextStyle(color: black, fontSize: 18),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
