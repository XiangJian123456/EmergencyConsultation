import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergencyconsultation/pages/rescue/ambulance_profile.dart';
import 'package:emergencyconsultation/pages/rescue/ambulance_security.dart';
import 'package:emergencyconsultation/pages/rescue/rescue_map.dart';
import 'package:flutter/material.dart';
import 'package:emergencyconsultation/pages/user/settings/user_network_test.dart';
import 'package:emergencyconsultation/pages/user/settings/user_language.dart';
import 'package:emergencyconsultation/pages/user/settings/user_faq.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:emergencyconsultation/pages/login.dart';
import 'package:emergencyconsultation/auth/auth_service.dart';
class Ambulance_Setting extends StatefulWidget {
  const Ambulance_Setting({super.key});

  @override
  State<Ambulance_Setting> createState() => _Ambulance_SettingState();
}
Future<void> _showLogoutDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap button to dismiss
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: const Text('Confirm'),
            onPressed: () async {
              await AuthService().sign_out(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                    (route) => false,
              );
            },
          ),
        ],
      );
    },
  );
}
final firestore = FirebaseFirestore.instance.collection('ambulance');
User? user = FirebaseAuth.instance.currentUser;

Future<Map<String, dynamic>?> fetchUserData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('ambulance')
          .doc(user?.uid)
          .get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return null; // Return null if there's an error or no data
  }
  
class _Ambulance_SettingState extends State<Ambulance_Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[50], // Light background color
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // Profile Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                   Hero(
                    tag: 'profile',
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('ambulance')
                          .doc(user?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.exists) {
                          String? imageUrl = snapshot.data!['profilePicture'];
                          return CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.deepOrange.shade800,
                            backgroundImage: imageUrl != null
                                ? NetworkImage(imageUrl)
                                : null,
                            child: imageUrl == null
                                ? Icon(Icons.person, size: 35, color: Colors.white)
                                : null,
                          );
                        }else{
                        return CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.deepOrange.shade800,
                          child: Icon(Icons.person, size: 35, color: Colors.white),
                        );
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('ambulance')
                              .doc(user?.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data!.exists) {
                              String firstName = snapshot.data!['firstName'] ?? 'Unknown';
                              String lastName = snapshot.data!['lastName'] ?? 'Unknown';
                              return Text(
                                '$firstName $lastName',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }
                            return Text('Loading...');
                          },
                        ),
                        SizedBox(height: 8),
                      Column( // Added Column to stack buttons vertically
            children: [
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AmbulanceProfile()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('View Profile'),
              ),
              SizedBox(height: 10), // Space between buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RescueMap()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Change color as needed
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Change Hospital Location',
                  style: TextStyle(color: Colors.white, fontSize: 8),
                ),
              ),
            ],
          ),
                      ],
                    ),
                    
                  ),
                ],
              ),
            ),
          ),

          // Move the buttons outside of the Card

          SizedBox(height: 24),

          // Settings Options
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildSettingsTile(
                  icon: 'assets/emergency_call.png',
                  title: 'Language',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LanguageSelectionScreen()),
                  ),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: 'assets/security.png',
                  title: 'Account Security',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AmbulanceAccountSecurityScreen()),
                  ),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: 'assets/bandwidth.png',
                  title: 'Network Testing',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NetworkTestScreen()),
                  ),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: 'assets/question.png',
                  title: 'FAQ',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FAQPage()),
                  ),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: 'assets/turn-off.png',
                  title: 'Log Out',
                  onTap: () {
                    _showLogoutDialog(context); // Show the logout confirmation dialog
                  },
                  isLogout: true,
                ),
              ],
            ),
          ),
        ],
      )
                  );
              
  }

  Widget _buildSettingsTile({
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLogout ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(
          icon,
          color: isLogout ? Colors.red : Colors.blue,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isLogout ? Colors.red : Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 70,
      endIndent: 20,
    );
  }
}
