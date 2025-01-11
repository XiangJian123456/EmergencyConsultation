import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorReport extends StatefulWidget {
  const DoctorReport({super.key});

  @override
  State<DoctorReport> createState() => _DoctorReportState();
}

class _DoctorReportState extends State<DoctorReport> {
  int consultationsThisMonth = 0; // To hold fetched data
  double earningsThisMonth = 0.0; // To hold fetched data

  @override
  void initState() {
    super.initState();
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    // Fetch data from Firestore
    final snapshot = await FirebaseFirestore.instance.collection('consultationRecords').get();
    setState(() {
      consultationsThisMonth = snapshot.docs.length; // Count of consultations 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Consultation Statistics',
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
            'Consultations This Month: $consultationsThisMonth',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}