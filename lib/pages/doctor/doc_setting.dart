import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergencyconsultation/pages/doctor/doc_emergency_contact.dart';
import 'package:emergencyconsultation/pages/doctor/doc_profile.dart';
import 'package:emergencyconsultation/pages/doctor/doc_security.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:emergencyconsultation/pages/user/settings/user_network_test.dart';
import 'package:emergencyconsultation/pages/user/settings/user_language.dart';
import 'package:emergencyconsultation/pages/user/settings/user_faq.dart';
import '../../auth/auth_service.dart';
import '../login.dart';
import 'doc_mainpages_user.dart';


class DoctorSettingPage extends StatefulWidget {
  const DoctorSettingPage({super.key});

  @override
  State<DoctorSettingPage> createState() => _DoctorSettingPageState();
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
            child: const Text('Log Out'),
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
class _DoctorSettingPageState extends State<DoctorSettingPage> {
  final firestore = FirebaseFirestore.instance.collection('doctors');
  User? user = FirebaseAuth.instance.currentUser;
  Future<bool> showConfirmationDialog(BuildContext context, bool newValue) async {
    return await showDialog<bool>(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text('Change Status'),
            content: Text('Do you want switch ${newValue ? 'user':'doctor'} ?'),
            actions: [
              TextButton(
                onPressed:()=> Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                  onPressed: () {
                    if (newValue) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Doc_User_MainPages(),
                        ),
                      );
                    } else {
                      Navigator.pop(context, true);
                    }
                  },
                  child: Text('Confirm'))
            ],
          );
        }
    )?? false;
  }

  bool switchValue = false;
  bool tempValue = false;

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
                          .collection('doctors')
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
                          stream: firestore.doc(user?.uid).snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text('Loading...');
                            }
                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return const Text('No data available');
                            }
                            String firstName = snapshot.data!['firstName'] ?? 'User1';
                            String lastName = snapshot.data!['lastName'] ?? 'Unknown';
                            return Text(
                              '$firstName $lastName',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DoctorProfile()),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text('View Profile'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(5.0),
            margin: EdgeInsets.symmetric(horizontal: 30.0),
            decoration: BoxDecoration(
              color: Color(0xffFFFFFF),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left part: Context text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Switch User Mode',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  // Right part: Switch
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Switch(
                          value: tempValue,
                          onChanged: (newValue) async {
                            final confirm = await showConfirmationDialog(context, newValue);
                            if(confirm){
                              setState(() {
                                switchValue = newValue;
                                tempValue = newValue;
                              });
                            }else{
                              setState(() {
                                tempValue = switchValue;
                              });
                            }
                          },
                        ),
                      ]
                  ),
                ]
            ),
          ),
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
                  icon: 'assets/doctor-consultation.png',
                  title: 'Emergency Contact',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DoctorEmergencyContactScreen()),
                  ),
                ),
                _buildDivider(),
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
                    MaterialPageRoute(builder: (context) => DoctorAccountSecurityScreen()),
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
      ),
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
