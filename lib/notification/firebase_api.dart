import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  
Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print('fCMToken: $fCMToken');
    
  // Show a notification or update UI
}
  Future<void> storeUserFCMToken() async {
  String? currentUserId = _currentUserId; // Get the current user ID
  String? token = await _firebaseMessaging.getToken();
  if (token != null && currentUserId != null) {// Fetch the current user's document to determine their role
    await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
    await FirebaseFirestore.instance.collection('users').doc(currentUserId).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
  }else{
     print('The FCM updated error.... or the invalid document found');
  }
  }
  Future<void> storeAmbulanceFCMToken() async {
  String? currentUserId = _currentUserId; // Get the current user ID
  String? token = await _firebaseMessaging.getToken();
  if (token != null && currentUserId != null) {// Fetch the current user's document to determine their role
    await FirebaseFirestore.instance.collection('ambulance').doc(currentUserId).get();
    await FirebaseFirestore.instance.collection('ambulance').doc(currentUserId).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
   } else{
    print('The FCM updated error.... or the invalid document found');
  }
  }
  Future<void> storeDoctorFCMToken() async {
  String? currentUserId = _currentUserId; // Get the current user ID
  String? token = await _firebaseMessaging.getToken();

  if (token != null && currentUserId != null) {// Fetch the current user's document to determine their role
    await FirebaseFirestore.instance.collection('doctors').doc(currentUserId).get();
    await FirebaseFirestore.instance.collection('doctors').doc(currentUserId).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
   } else{
    print('The FCM updated error.... or the invalid document found');
  }
    
}
}