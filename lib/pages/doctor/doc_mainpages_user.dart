import 'package:emergencyconsultation/notification/firebase_api.dart';
import 'package:flutter/material.dart';
import '../../widget/navbar/doc_bottom_user_nav.dart';
import '../../widget/floatingbubble.dart';
import '../map/google_map_page.dart';
import '../user/doctor_selection.dart';
import '../user/home.dart';
import '../user/wallet/wallet_interface.dart';
import 'doc_home_user_pages.dart';
import 'doc_setting2.dart';
import 'doctor_home.dart';
class Doc_User_MainPages extends StatefulWidget {
  const Doc_User_MainPages({super.key});

  @override
  State<Doc_User_MainPages> createState() => _Doc_User_MainPagesState();
}

class _Doc_User_MainPagesState extends State<Doc_User_MainPages> {
  int selectedIndex = 0;

  final List<Widget> _pages = [
    DoctorUserHomePage(),
    WalletInterface(),
    DoctorSettingUserPage2(),
  ];
@override
  void initState() {
    super.initState();
    FirebaseApi().storeDoctorFCMToken();
  }
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Stack(
        children: [
          _pages[selectedIndex],
          FloatingChatBubble(), // Add the floating chat bubble here
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GoogleMapPage()),
          );
        },
        child: const Icon(Icons.warning, color: Colors.white),
        backgroundColor: Colors.red,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Doc_User_CustomBottomNavigation(
        selectedIndex: selectedIndex,
        onItemTapped: onItemTapped,
      ),
    );
  }
}