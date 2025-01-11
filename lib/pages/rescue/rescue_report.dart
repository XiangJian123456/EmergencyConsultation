import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RescueReport extends StatefulWidget {
  const RescueReport({super.key});

  @override
  State<RescueReport> createState() => _RescueReportState();
}

class _RescueReportState extends State<RescueReport> {
  int rescueThisMonth = 0; // To hold fetched data


  @override
  void initState() {
    super.initState();
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    // Fetch data from Firestore
    final snapshot = await FirebaseFirestore.instance.collection('RescueReport').get();
    setState(() {
      rescueThisMonth = snapshot.docs.length; // Count of consultations 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RescueReport',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Display consultation statistics
          Text(
            'Rescue Action In This Month: $rescueThisMonth',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}