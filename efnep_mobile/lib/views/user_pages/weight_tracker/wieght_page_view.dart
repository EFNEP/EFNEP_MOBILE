// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:efnep_mobile/services/analytics.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'weight_entry_page_view.dart';

class WeightPageView extends StatefulWidget {
  const WeightPageView({Key? key}) : super(key: key);

  @override
  _WeightPageViewState createState() => _WeightPageViewState();
}

class _WeightPageViewState extends State<WeightPageView> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _weightEntries = [];

  @override
  void initState() {
    super.initState();
    analytics('Weight', 'WeightPageView');
    _updateWeightEntries();
    // Set up a timer to periodically update the graph (e.g., every 30 seconds)
    Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateWeightEntries();
    });
  }

  void _updateWeightEntries() async {
    List<Map<String, dynamic>> entries =
        await _databaseHelper.getWeightEntries();
    setState(() {
      _weightEntries = entries;
    });
  }

  List<FlSpot> _generateData() {
    List<FlSpot> spots = [];

    for (int i = _weightEntries.length - 1; i >= 0; i--) {
      double weight = _weightEntries[i]['weight'];
      spots.add(FlSpot((_weightEntries.length - 1 - i).toDouble(), weight));
    }

    return spots;
  }

  String _formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('MMM d, y H:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Weight Tracker',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Graph Section
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateData(),
                      isCurved: true,
                      color: Colors.blue,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: true),
                    ),
                  ],
                  titlesData: const FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                            // showTitles: true,
                            // getTextStyles: (value) => const TextStyle(
                            //   color: Colors.black,
                            //   fontWeight: FontWeight.bold,
                            //   fontSize: 14,
                            // ),
                            // getTitles: (value) {
                            //   // Customize your y-axis titles here based on the 'value'
                            //   return value.toString();
                            // },
                            ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                            // showTitles: true,
                            //   getTextStyles: (value) => const TextStyle(
                            //     color: Colors.black,
                            //     fontWeight: FontWeight.bold,
                            //     fontSize: 14,
                            //   ),
                            //   getTitles: (value) {
                            //     // Customize your x-axis titles here based on the 'value'
                            //     return value.toString();
                            //   },
                            ),
                      )),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
          ),
          // Weight Entries Section
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weight Entries',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _weightEntries.length,
                      itemBuilder: (context, index) {
                        String formattedDateTime =
                            _formatDateTime(_weightEntries[index]['date']);
                        return ListTile(
                          title: Text(
                            'Weight: ${_weightEntries[index]['weight']} kg',
                          ),
                          subtitle: Text(
                            'Date: $formattedDateTime',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WeightEntryPage()),
          ).then((value) {
            // Refresh the weight entries when returning from the WeightEntryPage
            _updateWeightEntries();
          });
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
