import 'package:emergencyconsultation/notification/firebase_api.dart';
import 'package:emergencyconsultation/pages/map/google_map_page.dart';
import 'package:emergencyconsultation/pages/user/record/user_selection_record.dart';
import 'package:flutter/material.dart';
import 'package:emergencyconsultation/pages/user/home.dart'; // Import the custom widget
import 'package:emergencyconsultation/pages/user/wallet/wallet_interface.dart';
import 'package:emergencyconsultation/pages/user/settings/user_settings.dart';
import '../../widget/navbar/bottom_navbar.dart';


class MainScreen extends StatefulWidget {
  final int selectedIndex ;
  const MainScreen({super.key, required this.selectedIndex});
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(), // Replace with your actual widgets
    UserSelectionRecord(),
    WalletInterface(),
    SettingPage(),
  ];
  @override
  void initState() {
    super.initState();
    FirebaseApi().storeUserFCMToken();
    selectedIndex = widget.selectedIndex; // Initialize selectedIndex from widget
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
           // Add the floating chat bubble here
        ],
      ),
      floatingActionButton: Padding( // Add Padding to move the button down
        
        padding: const EdgeInsets.only(bottom: 0), // Adjust the bottom padding as needed
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GoogleMapPage()),
            );
          },
          backgroundColor: Colors.red,
          child: Column( // Change to Column to add text
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, color: Colors.white), // Keep the icon
              Text('SOS', style: TextStyle(color: Colors.white, fontSize: 12)), // Add text
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: selectedIndex,
        onItemTapped: onItemTapped,
      ),
    );
  }
}
  

