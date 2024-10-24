import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:efnep_mobile/constants/colors.dart';
import 'package:efnep_mobile/services/analytics.dart';
import 'package:intl/intl.dart';
import 'package:efnep_mobile/provider/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GBPurchasesPage extends StatefulWidget {
  @override
  _GBPurchasesPageState createState() => _GBPurchasesPageState();
}

class _GBPurchasesPageState extends State<GBPurchasesPage> {
  late LanguageProvider _languageProvider;
  List<Map<String, dynamic>> purchases = [];
  int overallTotal = 0;  // Variable to store the overall total of purchases

  @override
  void initState() {
     analytics('Purchases', 'GBPurchasesPage');
    super.initState();
     analytics('Purchases', 'GBPurchasesPage');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPurchasesFromFirestore();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageProvider = Provider.of<LanguageProvider>(context);
  }

 

  void _fetchPurchasesFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance.collection('GB_Purchases').doc(user.uid);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        var data = docSnapshot.data();
        setState(() {
          purchases = (data!['purchases'] as List).map((item) {
            return {
              'date': item['date'],
              'times': List<String>.from(item['times']),
              'total': item['total']
            };
          }).toList();
          overallTotal = purchases.fold(0, (int sum, item) => sum + (item['total'] as int));  // Ensure the sum is treated as int
        });
      }
    }
  }

  void _storePurchaseToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(now);
      final formattedTime = DateFormat('HH:mm:ss').format(now);

      final docRef = FirebaseFirestore.instance.collection('GB_Purchases').doc(user.uid);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        bool dateExists = false;
        List<Map<String, dynamic>> updatedPurchases = snapshot.exists ? (snapshot.data()!['purchases'] as List).map((item) {
          return {
            'date': item['date'],
            'times': List<String>.from(item['times']),
            'total': item['total']
          };
        }).toList() : [];

        for (var purchase in updatedPurchases) {
          if (purchase['date'] == formattedDate) {
            purchase['times'].add(formattedTime);
            purchase['total'] += 1;
            dateExists = true;
            break;
          }
        }

        if (!dateExists) {
          updatedPurchases.add({
            'date': formattedDate,
            'times': [formattedTime],
            'total': 1,
          });
        }

        transaction.set(docRef, {'purchases': updatedPurchases});
        setState(() {
          purchases = updatedPurchases;
          overallTotal = purchases.fold(0, (int sum, item) => sum + (item['total'] as int));  // Recalculate the overall total as int
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_languageProvider.currentLanguage == Language.English ? 'Good Bowl Purchases' : "Compras en Good Bowl"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                _languageProvider.currentLanguage == Language.English
                    ? 'If you purchased a good bowl today, tap +.'
                    : 'Si compraste un buen tazón hoy, toca el botón más.',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              onPressed: _storePurchaseToFirestore,
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: purchases.length,
                itemBuilder: (context, index) {
                  final purchase = purchases[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        purchase['date'],
                        style: const TextStyle(color: Colors.black, fontSize: 18),
                      ),
                      subtitle: Text('Total: ${purchase['total']}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PurchaseHistoryPage(
                              purchaseDate: purchase['date'],
                              times: purchase['times'],
                              total: overallTotal,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class PurchaseHistoryPage extends StatelessWidget {
  final String purchaseDate;
  final List<String> times;
  final int total;

  const PurchaseHistoryPage({
    Key? key,
    required this.purchaseDate,
    required this.times,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const  Text('History'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: times.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Container(
                    width: 30,
                    height: 30,
                    decoration:const  BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style:const  TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    'Time: ${times[index]}',
                    style: const TextStyle(color: Colors.black, fontSize: 18),
                  ),
                );
              },
            ),
          ),
          Container(
            
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.center,
            child: Text(
              'Overall Total Purchases: $total',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
