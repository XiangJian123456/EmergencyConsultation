import 'package:emergencyconsultation/notification/firebase_api.dart';
import 'package:flutter/material.dart';
import 'package:emergencyconsultation/pages/doctor/doc_patient_record.dart';
import 'package:emergencyconsultation/pages/doctor/doctor_home.dart';
import 'package:emergencyconsultation/pages/doctor/doc_setting.dart';
import 'package:emergencyconsultation/pages/doctor/doc_report.dart';

import '../../widget/navbar/doc_bottom_navbar.dart';


class DoctorMainPages extends StatefulWidget {
  const DoctorMainPages({super.key});

  @override
  State<DoctorMainPages> createState() => _DoctorMainPagesState();
}

class _DoctorMainPagesState extends State<DoctorMainPages> {
  int selectedIndex = 0;

  final List<Widget> _pages = [
    DoctorHomePage(), // Replace with your actual widgets
    PatientRecordScreen(),
    DoctorReport(),
    DoctorSettingPage(),
  ];
  @override
  void initState() {
    FirebaseApi().storeDoctorFCMToken();
    super.initState();
    
  }
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[selectedIndex], // Display the current page
      bottomNavigationBar: DoctorBottomNavigation(
        selectedIndex: selectedIndex, // Pass the current index
        onItemTapped: onItemTapped, // Pass the callback function
      ),
    );
  }
}