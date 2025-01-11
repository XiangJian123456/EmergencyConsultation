import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergencyconsultation/pages/map/google_map_page.dart';
import 'package:emergencyconsultation/pages/user/record/user_selection_record.dart';
import 'package:emergencyconsultation/pages/user/user_mainpage.dart';
import 'package:emergencyconsultation/widget/chatbox/consultation_room.dart';
import 'package:emergencyconsultation/widget/chatbox/returned_chat_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'doctor_selection.dart';




class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool hasPendingChat = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Page',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red.shade600,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return Center(child: Text('No data found.'));
                      }

                      // Assuming the document has a field 'name'
                      String firstName = snapshot.data!['firstName'] ?? 'Unknown';
                      String lastName = snapshot.data!['lastName'] ?? 'Unknown';
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                        '$firstName $lastName',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      );
                    },
                  ),
           
                  const SizedBox(height: 20),
                  const Text(
                    'What would you like to do today?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildServiceCard(
              'Medical Consultation',
              'assets/doctor-consultation.png',
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorSelection(),
            ),
              ),
            ),
            const SizedBox(height: 20),
            _buildServiceCard(
              'Emergency SOS',
              'assets/ambulance.png',
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => GoogleMapPage())),
              isEmergency: true,
            ),
            const SizedBox(height: 20),
            _buildServiceCard(
              'Medical History',
              'assets/health-report.png',
              () => Navigator.push(context, MaterialPageRoute(builder: (context) =>  UserSelectionRecord())),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
            onPressed: () {
              // Define your button action here
              print('Button Pressed');
              Navigator.push(context, MaterialPageRoute(builder: (context) => ReturnedChatButton()));
            },
            child: Text('Your Button Text'),
          ),
         
          ]
        )
      )
    ); 
  }
}           
            

  Widget _buildServiceCard(String title, String imagePath, VoidCallback onTap, {bool isEmergency = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 110,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: isEmergency ? Colors.red.shade200 : Colors.grey.shade200,
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isEmergency ? Colors.red : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
