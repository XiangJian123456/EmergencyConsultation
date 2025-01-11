
import 'package:emergencyconsultation/pages/user/user_mainpage.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class UserProfile2 extends StatefulWidget {
  const UserProfile2({super.key});
  
  @override
  
  State<UserProfile2> createState() => _UserProfile2State();
}
final List<String> genderOptions = ["Male", "Female"];
String gender = "Male"; // Change to String to match dropdown options
final TextEditingController firstNameController = TextEditingController();
final TextEditingController lastNameController = TextEditingController();
final TextEditingController icNumberController = TextEditingController();
final TextEditingController addressController = TextEditingController();
final TextEditingController phoneController = TextEditingController();
class _UserProfile2State extends State<UserProfile2> {
  String? profilePictureUrl;
  bool _isLoading = false;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  User? user;

    @override
   void initState() {
     super.initState();
     _fetchUserData(); // Fetch user data when the widget is initialized
   }
  Future<bool> _deleteCurrentImage() async {
  if (profilePictureUrl != null && profilePictureUrl!.isNotEmpty) {
    try {
      // Get the reference to the current image
      final ref = FirebaseStorage.instance.refFromURL(profilePictureUrl!);
      await ref.delete(); // Delete the image
      print('Current image deleted successfully.');
      return true; // Indicate success
    } catch (e) {
      // Log the error with more details
      print('Error deleting current image: $e');
      return false; // Indicate failure
    }
  } else {
    print('No valid profile picture URL to delete.');
    return true; // No image to delete, consider it a success
  }
}
  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        
        // Set the text fields with the current user data
        firstNameController.text = userData['firstName'] ?? '';
        lastNameController.text = userData['lastName'] ?? '';
        icNumberController.text = userData['icNumber'] ?? '';
        addressController.text = userData['address'] ?? '';
        phoneController.text = userData['phone'] ?? '';
        gender = userData['gender'] ?? 'Male';
        profilePictureUrl = userData['profilePicture']; // Get the profile picture URL
        _image = null; // Reset _image since it's for local files
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
}
  Future<void> _pickImage() async {
  try {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Update _image with the new file
      });
    } else {
      print('No image selected.'); // No action taken, existing image remains
    }
  } catch (e) {
    print('Error picking image: $e'); // No action taken, existing image remains
  }
}
Future<void> _updateProfile() async {
  setState(() => _isLoading = true); // Start loading

  try {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;
    String userId = user?.uid ?? '';
  
    // Check if the user document exists
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    // Prepare data to update or create
    Map<String, dynamic> userData = {
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'icNumber': icNumberController.text,
      'gender': gender,
      'address': addressController.text,
      'phone': phoneController.text, // Assuming phone is not being updated
    };

    // Check if the document exists
    if (userDoc.exists) {
      // Document exists, retrieve existing data if needed
      String? profilePictureUrl = (userDoc.data() as Map<String, dynamic>)['profilePicture']; // Get the profile picture URL if it exists
      
      // Attempt to delete the current image
      bool deleteSuccess = await _deleteCurrentImage();
      if (!deleteSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete current image.')),
        );
      }

      // Upload the new image if it exists
      if (_image != null) {
        final newImageUrl = await _uploadImage(_image!); // Upload image to Firebase Storage
        if (newImageUrl != null) {
          userData['profilePicture'] = newImageUrl; // Add image URL to user data
        } else {
          throw Exception('Image upload failed');
        }
      } else if (profilePictureUrl != null) {
        // If no new image is selected, keep the existing profile picture URL
        userData['profilePicture'] = profilePictureUrl;
      }
      
      // Update the user document
      await FirebaseFirestore.instance.collection('users').doc(userId).update(userData);
    } else {
      // Document does not exist, create a new one
      if (_image != null) {
        final newImageUrl = await _uploadImage(_image!); // Upload image to Firebase Storage
        if (newImageUrl != null) {
          userData['profilePicture'] = newImageUrl; // Add image URL to user data
        }
      }
      // Create the user document with the provided data
      await FirebaseFirestore.instance.collection('users').doc(userId).set(userData);
    }

    _showSuccessDialog(); // Show success dialog
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
    );
  } finally {
    setState(() => _isLoading = false); // Stop loading
  }
}
  Future<String?> _uploadImage(File _image) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final imageName = _image.path.split('/').last.replaceAll(RegExp(r'[^\w\.]'), '_');
      final Timestamp = DateTime.now().microsecondsSinceEpoch;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('$userId/uploads/$Timestamp-$imageName');
      print('Uploading to: ${storageRef.fullPath}');
      await storageRef.putFile(_image);
      final downloadUrl = await storageRef.getDownloadURL();
      print('Upload successful! Download URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Failed to upload image: $e');
      return null; // Return null if upload fails, existing image remains
    }
}
  // Show success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.shade50,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 50,
                  ),
                ),
                SizedBox(height: 17),
                Text(
                  'Success!',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 11),
                Text(
                  'Your profile has been updated successfully.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainScreen(selectedIndex: 0) ),
                      (route) => false,
                    );
                  },
                  child: Text('OK'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  

  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(selectedIndex: 0)), // Navigate to RescueMainPages
          )
      ),
      title: Text('Edit Profile'),
      backgroundColor: Colors.blue, // This should work if AppBar is correctly defined
      elevation: 0,
    ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Picture Section
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser?.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator(); // Show loading indicator while fetching
                              }

                              if (snapshot.hasError) {
                                return Icon(Icons.error); // Handle error state
                              }

                              if (snapshot.hasData && snapshot.data!.exists) {
                          String? profilePictureUrl = snapshot.data!['profilePicture'];
                          print(snapshot.data!['profilePicture']);
                          return CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.blue.shade50,
                            backgroundImage: _image != null 
                                ? FileImage(_image!) 
                                : (profilePictureUrl != null 
                                    ? NetworkImage(profilePictureUrl) 
                                    : null),
                            child: _image == null && profilePictureUrl == null
                                ? Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.blue,
                                  )
                                : null,
                          );
                        } else {
                          // If the document does not exist, check if a local image is available
                          return CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.blue.shade50,
                            backgroundImage: _image != null 
                                ? FileImage(_image!) 
                                : null, // Show local image if available
                            child: _image == null
                                ? Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.blue,
                                  )
                                : null,
                          );
                            }
                            }
                          ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Form Fields
                  _buildTextField(
                    controller: firstNameController,
                    label: 'First Name',
                    icon: Icons.person_outline,
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    controller: lastNameController,
                    label: 'Last Name',
                    icon: Icons.person_outline,
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    controller: icNumberController,
                    label: 'IC Number / Passport No',
                    icon: Icons.card_membership,
                  ),
                  SizedBox(height: 15),
                  
                  // Gender Dropdown
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, color: Colors.grey),
                        SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: gender,
                              isExpanded: true,
                              hint: Text('Select Gender'),
                              items: genderOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  gender = newValue!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    controller: addressController,
                    label: 'Address',
                    icon: Icons.location_on_outlined,
                    maxLines: 3,
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    controller: phoneController,
                    label: 'Phone',
                    icon: Icons.phone_android,

                  ),
                  SizedBox(height: 30),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
      onPressed: _isLoading ? null : () async {
        await _updateProfile(); // Call the update profile method
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _isLoading 
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(color: Colors.white),
            )
          : Text('Save Changes'),
    ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }

      Widget _buildTextField({
        required TextEditingController controller,
        required String label,
        required IconData icon,
        int maxLines = 1,
      }) {
        return TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        );
      }
}