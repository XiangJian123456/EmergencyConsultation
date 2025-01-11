import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:emergencyconsultation/pages/map/rescue_user_map.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class LoadingPage extends StatelessWidget {
  
  
  
  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Waiting for Ambulance Accept'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(), // Waiting circular indicator
            SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('ambulanceRequests')
                    .where('user_userId', isEqualTo: currentUserId)
                    .where('status', isEqualTo: 'pending')
                    .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Waiting for ambulance to accept your request');
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.hasData) {
                var userData = snapshot.data!.docs.first.data() as Map<String, dynamic>?; // Get the fir
                  // Check if userData is not null and status is accepted
                    
                    // Extract necessary fields from userData
                    final String onhold_status = userData?['onhold_status'] ?? '';
                    final String name = userData?['user_name'] ; // Default value if name is null
                    final double userLatitude = userData?['user_latitude'] ; // Default value if latitude is null
                    final double userLongitude = userData?['user_longitude'] ; // Default value if longitude is null
                    final Map<String, dynamic> selectedAmbulance = userData?['selectedAmbulance'] ?? {};
                    final String ambulanceId = selectedAmbulance['uid'];
                    final String ambulanceName = selectedAmbulance['firstName'] + selectedAmbulance['lastName'];
                    final double ambulanceLatitude = selectedAmbulance['latitude'] ;
                    final double ambulanceLongitude = selectedAmbulance['longitude'] ;
                    final String ambulancePhone = selectedAmbulance['phone'];
                    final String ambulanceAddress = selectedAmbulance['address'];
                    final String ambulanceRequestID = userData?['documentId'] ?? '';
                    // Default to empty map if null
                    final String userId = userData?['user_userId'] ?? ''; // Default value if userId is null
                    if (onhold_status == 'accepted') {  
  // Navigate to Rescue_OnUser_Map if status is accepted
                      print('ambulanceRequestID: $ambulanceRequestID');
                      print('ambulanceId: $ambulanceId');
                      print('ambulanceName: $ambulanceName');
                      print('ambulanceLatitude: $ambulanceLatitude');
                      print('ambulanceLongitude: $ambulanceLongitude');
                      print('ambulancePhone: $ambulancePhone');
                      print('ambulanceAddress: $ambulanceAddress');
                      print('name: $name');
                      print('userLatitude: $userLatitude');
                      print('userLongitude: $userLongitude');
                      print('userId: $userId');
                      print('onhold_status: $onhold_status');
                      print('selectedAmbulance: $selectedAmbulance');

                    FirebaseFirestore.instance
                        .collection('ambulanceRequests')
                        .doc(ambulanceRequestID) // Use the document ID to update the specific document
                        .update({'status': 'accepted'}).then((_) {
                          print('Document status updated to accepted');
                        }).catchError((error) {
                          print('Failed to update status: $error');
                        });

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Rescue_OnUser_Map(
                          name: name,
                          user_latitude: userLatitude,
                          user_longitude: userLongitude,
                          selectedAmbulance: selectedAmbulance,
                          userId: userId,
                          ambulanceName: ambulanceName,
                          ambulanceLatitude: ambulanceLatitude,
                          ambulanceLongitude: ambulanceLongitude,
                          ambulancePhone: ambulancePhone,
                          ambulanceAddress: ambulanceAddress,
                          ambulanceId: ambulanceId,
                          ambulanceRequestID: ambulanceRequestID,
                        )),
                      );
                    });
                  }
                }
                return Container(); // Return an empty container if no action is needed
              },
            ),
          ],
        ),
      ),
    );
  }
}