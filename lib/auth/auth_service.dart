import 'package:emergencyconsultation/pages/doctor/doc_mainpages.dart';
import 'package:emergencyconsultation/pages/rescue/rescue_mainpages.dart';
import 'package:emergencyconsultation/pages/user/user_mainpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergencyconsultation/pages/login.dart';

class AuthService {
  String? verificationId;
   Future<void> updatePassword(String newPassword) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await user.updatePassword(newPassword);
        print('Password updated successfully');
      } catch (e) {
        print('Error updating password: $e');
        // Handle error (e.g., show a message to the user)
      }
    } else {
      print('No user is currently signed in.');
    }
  }

  Future<void> sign_out(BuildContext context) async {
     try {
       await FirebaseAuth.instance.signOut(); // Sign out from Firebase
       Navigator.of(context).pushReplacement(
         MaterialPageRoute(builder: (context) => Login()), // Replace with your login screen widget
       );
     } catch (e) {
       // Handle any errors that occur during logout
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("Error logging out: $e")),
       );
     }
   }
  
  Future<void> registerUser({
    required String email,
    required String password,
    required String phone,
    required BuildContext context,
    required String role,
    String? secretCode,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
       
      );

      String collectionName = role == 'doctor' ? 'doctors' : (role == 'ambulance' ? 'ambulance' : 'users');

      await FirebaseFirestore.instance.collection(collectionName).doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'firstName': null,
        'lastName': null,
        'email': email,
        'role': role,
        'profilePicture': null,
        'phone': phone,
        'address': null,
        'icNumber': null,
        'gender': null,
        'specialist': null,
        'isOnline' : false,
        'experience': null,
      });
      
      await Future.delayed(const Duration(seconds: 1));

      if (role == 'doctor') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => DoctorMainPages()),
              (route) => false, // This ensures all previous routes are removed
        );
      } else if (role == 'ambulance') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AmbulanceMainPages()), // Replace with your ambulance main page
              (route) => false, // This ensures all previous routes are removed
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(selectedIndex: 0)), // Default user main page
              (route) => false, // This ensures all previous routes are removed
        );
      }

      
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      } else {
        message = 'An error occurred. Please try again';
      }
      print(message);
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } catch (e) {
      print('Error: $e');
    }
  }
 
  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      
      // Check doctors collection first
      DocumentSnapshot doctorDoc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(userCredential.user!.uid)
          .get();

      if (doctorDoc.exists) {
        // Update status to online
        await FirebaseFirestore.instance
            .collection('doctors')
            .doc(userCredential.user!.uid)
            .update({'status': 'Offline'});
            
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DoctorMainPages()),
        );
        return;
      }
      DocumentSnapshot ambulanceDoc = await FirebaseFirestore.instance
          .collection('ambulance')
          .doc(userCredential.user!.uid)
          .get();

      if (ambulanceDoc.exists) {
        // Navigate to ambulance main page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AmbulanceMainPages()), // Replace with your ambulance main page
        );
        return;
      }
      // If not a doctor, check users collection
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(selectedIndex: 0)),
        );
        return;
      }

      // If neither doctor nor user exists
      Fluttertoast.showToast(
        msg: "Account not found",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );

    } on FirebaseAuthException catch(e) {
      String message = '';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      } else {
        message = 'An error occurred. Please try again';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } catch(e) {
      print("Error during sign in: $e");
      Fluttertoast.showToast(
        msg: "An unexpected error occurred",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

}


