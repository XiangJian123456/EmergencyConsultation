import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ProfileMController {
  Future<void> submitProfile({
    required String firstName,
    required String lastName,
    required String icNumber,
    required String gender,
    required String address,
    required String phone,
    required String profilePicture,
  }) async {
    final firestore = FirebaseFirestore.instance.collection('users');
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Create a map with the user data
        Map<String, dynamic> userData = {
          'firstName': firstName,
          'lastName': lastName,
          'icNumber': icNumber,
          'gender': gender,
          'address': address,
          'profilePicture': profilePicture,
        };

        // Save or update the user data in Firestore
        await firestore.doc(user.uid).set(userData, SetOptions(merge: true));
        print('Profile updated successfully');
      } catch (e) {
        print("Error updating profile: $e");
        throw Exception('Failed to update profile');
      }
    } else {
      throw Exception('No user is logged in');
    }
  }

}


