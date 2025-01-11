import 'package:emergencyconsultation/notification/firebase_api.dart';
import 'package:flutter/material.dart';
import 'package:emergencyconsultation/pages/rescue/ambulance_record.dart';
import '../../widget/navbar/rescue_btm_navbar.dart';
import 'rescue_interface.dart';
import 'package:emergencyconsultation/pages/rescue/ambulance_setting.dart';
import 'package:emergencyconsultation/pages/rescue/rescue_report.dart';


class AmbulanceMainPages extends StatefulWidget {
  const AmbulanceMainPages({super.key});

  @override
  State<AmbulanceMainPages> createState() => _AmbulanceMainPagesState();
}

class _AmbulanceMainPagesState extends State<AmbulanceMainPages> {
  int selectedIndex = 0;

  final List<Widget> _pages = [
    RescuePage(),
    AmbulanceRecord(),
    RescueReport(),
    Ambulance_Setting(),
  ];
  @override
  void initState(){
    super.initState();
    FirebaseApi().storeAmbulanceFCMToken();
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
      bottomNavigationBar: AmbulanceBottomNavigation(
        selectedIndex: selectedIndex, // Pass the current index
        onItemTapped: onItemTapped, // Pass the callback function
      ),
    );
  }
}