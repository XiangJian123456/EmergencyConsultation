import 'dart:convert';
import 'package:emergencyconsultation/widget/chatbox/consultation_room.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:http/http.dart' as http;
// Add this function in _DoctorSelectionState class
class ConsultationController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  Future<void> sendNotification(String token, String title, String body , Map<String, dynamic> doctorData) async {
  final url = 'https://us-central1-medical-emergency-38bb9.cloudfunctions.net/sendNotification';
  final docRef = await FirebaseFirestore.instance.collection('doctors').doc(doctorData['uid']).get();
  final token = docRef.data()?['fcmToken'];
  String title = 'New Consultation Request';
  String body = 'A new consultation has been request. Dr.${doctorData['firstName']} ${doctorData['lastName']} Pls Check Out.';
  print('Token: $token');
  print('Doctor Data: $doctorData');
  print('Title: $title');
  print('Body: $body');

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'token': token, // The FCM token of the device you want to send the notification to
      'title': title, // The title of the notification
      'body': body,   // The body of the notification
      'doctorData': doctorData, // The data of the doctor
    }),
  );

  if (response.statusCode == 200) {
    print('Notification sent successfully');
  } else {
    print('Failed to send notification: ${response.body}');
  }
}
  Future<void> sendConsultationRequest(Map<String, dynamic> doctorData, BuildContext context) async {
 try {
   DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser?.uid).get();
   String patientName = 'Patient';
    if (userDoc.exists) {
     Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
     patientName = '${userData['firstName']} ${userData['lastName']}';

   }
   // Create a new consultation
   DocumentReference consultationRef = await _firestore.collection('consultations').add({
     'doctorId': doctorData['uid'],
     'doctorName': 'Dr. ${doctorData['firstName']} ${doctorData['lastName']}',
     'patientId': currentUser?.uid,
     'patientName': patientName,
     'status': 'pending',
     'patientIcnumber': userDoc['icNumber'],
     'timestamp': FieldValue.serverTimestamp(),
     'message': 'New consultation request',
     'user_chat_status': 'pending',
   });
   sendNotification(doctorData['fcmToken'], 'New Consultation Request', 'A new consultation has been request. Dr.${doctorData['firstName']} ${doctorData['lastName']} Pls Check Out.', doctorData);
  
   DocumentReference chatRoomRef = await _firestore.collection('chatRooms').add({
  'consultationId': consultationRef.id,
  'participants': [currentUser?.uid, doctorData['uid']],
  'status': 'pending',
  'participantName': [patientName, 'Dr. ${doctorData['firstName']} ${doctorData['lastName']}'],
  'createdAt': FieldValue.serverTimestamp(),
  });
  await _firestore.collection('chatRooms').doc(chatRoomRef.id).update({
    'chatRoomId': chatRoomRef.id,
  });
   
  
// Step 2: Use the generated ID as the chatRoomId
   consultationRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        if (data['status'] == 'accepted') {
          // Close the loading dialog
          Navigator.of(context).pop();
          // Navigate to the chat room
        WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) { // Ensure context is still valid
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatRoom(
                    chatRoomId: chatRoomRef.id,
                    consultationId: consultationRef.id,
                    participants: data,

                  ),
                ),
              );
            }
          });
        }
        if (data['status'] == 'rejected') {
          // Close the loading dialog (if any)
          Navigator.of(context).pop();

          // Show a dialog informing the user
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Request Rejected'),
                content: Text('The doctor has rejected your consultation request.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    });
    // Notify user of successful request
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text('Consultation request sent')),
   );
 } catch (e) {
   print('Error creating consultation and chat room: $e');
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text('Failed to send consultation request')),
   );
 }
// Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text('Waiting for doctor to accept your request...')),
            ],
          ),
        );
      },
    );
    // Set up a listener for the consultation status
  }
}
  /*void sendConsultationRequest(Map<String, dynamic> doctorData, BuildContext context) 
  async {
  try {
    // Get current user
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Create a new booking document and get its reference
    DocumentReference consultationRef = await _firestore.collection('consultations').add({
      'doctorId': doctorData['uid'],
      'doctorName': 'Dr. ${doctorData['firstName']} ${doctorData['lastName']}',
      'patientId': currentUser.uid,
      'patientName': currentUser.displayName ?? 'Patient',
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
      'message': 'New consultation request',
    });
     final chatRoomRef = await _firestore.collection('chatRooms').add({
        'consultationId': snapshot.data!.docs[index].id,
        'participants': [user?.uid, consultation['patientId']],
        'createdAt': FieldValue.serverTimestamp(),
      });
  
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text('Waiting for doctor to accept your request...')),
            ],
          ),
        );
      },
    );
    

    // Set up a listener for the consultation status
    consultationRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        if (data['status'] == 'accepted') {
          // Close the loading dialog
          Navigator.of(context).pop();
          // Navigate to the chat room
        WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) { // Ensure context is still valid
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatRoom(
                    chatRoomId: chatRoomRef.id,
                    consultationId: consultationRef.id,
                    doctorId: doctorData['uid'],
                    patientId: currentUser.uid,
                    consultation: data,

                  ),
                ),
              );
            }
          });
        }
      }
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking request sent successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    // Close the loading dialog if an error occurs
    Navigator.of(context).pop();

    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error sending booking request: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
*/
