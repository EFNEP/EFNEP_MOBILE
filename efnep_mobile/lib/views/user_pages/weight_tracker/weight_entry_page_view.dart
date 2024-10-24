// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'database_helper.dart';

class WeightEntryPage extends StatefulWidget {
  const WeightEntryPage({Key? key}) : super(key: key);

  @override
  _WeightEntryPageState createState() => _WeightEntryPageState();
}

class _WeightEntryPageState extends State<WeightEntryPage> {
  TextEditingController weightController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  void _saveWeight() async {
    double weight = double.tryParse(weightController.text) ?? 0.0;

    if (weight > 0) {
      await _databaseHelper.insertWeight(weight, DateTime.now().toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Weight Entry',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter Weight (kg)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _saveWeight();
                Navigator.pop(context);
              },
              child: const Text(
                'Save Weight',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
