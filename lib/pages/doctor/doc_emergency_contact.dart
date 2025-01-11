import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class EmergencyContact {
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String relation;
  final String address;

  EmergencyContact({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.relation,
    required this.address,
  });

  factory EmergencyContact.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return EmergencyContact(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      relation: data['relation'] ?? '',
      address: data['address'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'relation': relation,
      'address': address,
    };
  }
}
class DoctorEmergencyContactScreen extends StatelessWidget {
  Future<void> _showDeleteConfirmationDialog(BuildContext context, String contactId) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap button to dismiss
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Contact'),
        content: const Text('Are you sure you want to delete this contact?'),
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
              final userId = FirebaseAuth.instance.currentUser?.uid;
              final contactRef = FirebaseFirestore.instance
                  .collection('doctors')
                  .doc(userId)
                  .collection('emergencyContacts')
                  .doc(contactId);
              await contactRef.delete();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Contact deleted successfully'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
              Navigator.of(context).pop(); // Close the dialog after deletion
            },
          ),
        ],
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Emergency Contact',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header with count
           StreamBuilder<QuerySnapshot>(
             stream: FirebaseFirestore.instance
                 .collection('doctors')
                 .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
                 .collection('emergencyContacts')
                 .snapshots(),
             builder: (context, snapshot) {
               int contactCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
               return Container(
                 padding: EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: Colors.red.shade50,
                   borderRadius: BorderRadius.circular(12),
                 ),
                 child: Row(
                   children: [
                     Icon(Icons.contacts, color: Colors.red),
                     SizedBox(width: 8),
                     Text(
                       'Emergency Contacts ($contactCount)',
                       style: TextStyle(
                         fontSize: 16,
                         fontWeight: FontWeight.bold,
                         color: Colors.red,
                       ),
                     ),
                   ],
                 ),
               );
             },
           ),
            SizedBox(height: 16),

            // Contacts List
            Expanded(
              child: buildContactList(FirebaseAuth.instance.currentUser?.uid ?? ''),
            ),

            // Add Button
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditContactScreen(),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Add New Contact',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }

  Widget buildContactList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('doctors')
          .doc(userId)
          .collection('emergencyContacts')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        List<EmergencyContact> contacts = snapshot.data!.docs
            .map((doc) => EmergencyContact.fromFirestore(doc))
            .toList();
        return ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            EmergencyContact contact = contacts[index];
            return ListTile(
              title: Text('${contact.firstName} ${contact.lastName}'),
              subtitle: Text(contact.phoneNumber),
              trailing: Row(
             mainAxisSize: MainAxisSize.min,
             children: [
               IconButton(
                 icon: Icon(Icons.edit),
                 onPressed: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (context) => EditEmergencyContactScreen(
                         contact: contact,
                       ),
                     ),
                   );
                 },
               ),
               IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _showDeleteConfirmationDialog(context, contact.id); // Show the delete confirmation dialog
                },
              ),
             ],
           ),
         );
              
    
          },
          
        );
      },
    );
  }
}
//添加紧急联系人界面
class AddEditContactScreen extends StatelessWidget {
 final EmergencyContact? contact;
  AddEditContactScreen({this.contact});
  final _formKey = GlobalKey<FormState>();
 final _firstNameController = TextEditingController();
 final _lastNameController = TextEditingController();
 final _phoneNumberController = TextEditingController();
 final _relationController = TextEditingController();
 final _addressController = TextEditingController();
  @override
 Widget build(BuildContext context) {
   if (contact != null) {
     _firstNameController.text = contact!.firstName;
     _lastNameController.text = contact!.lastName;
     _phoneNumberController.text = contact!.phoneNumber;
     _relationController.text = contact!.relation;
     _addressController.text = contact!.address;
   }
    return Scaffold(
     appBar: AppBar(
       title: Text(contact == null ? 'Add Contact' : 'Edit Contact'),
       backgroundColor: Colors.red,
     ),
     body: SingleChildScrollView(
       padding: const EdgeInsets.all(16.0),
       child: Form(
         key: _formKey,
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             buildTextField(
               label: 'First Name',
               controller: _firstNameController,
               icon: Icons.person,
               validator: (value) {
                 if (value == null || value.isEmpty) {
                   return 'Please enter a first name';
                 }
                 return null;
               },
             ),
             SizedBox(height: 16),
             buildTextField(
               label: 'Last Name',
               controller: _lastNameController,
               icon: Icons.person,
               validator: (value) {
                 if (value == null || value.isEmpty) {
                   return 'Please enter a last name';
                 }
                 return null;
               },
             ),
             SizedBox(height: 16),
             buildTextField(
               label: 'Phone Number',
               controller: _phoneNumberController,
               icon: Icons.phone,
               keyboardType: TextInputType.phone,
               validator: (value) {
                 if (value == null || value.isEmpty) {
                   return 'Please enter a phone number';
                 }
                 return null;
               },
             ),
             SizedBox(height: 16),
             buildTextField(
               label: 'Relation',
               controller: _relationController,
               icon: Icons.people,
               validator: (value) {
                 if (value == null || value.isEmpty) {
                   return 'Please enter a relation';
                 }
                 return null;
               },
             ),
             SizedBox(height: 16),
             buildTextField(
               label: 'Address',
               controller: _addressController,
               icon: Icons.location_on,
               validator: (value) {
                 if (value == null || value.isEmpty) {
                   return 'Please enter an address';
                 }
                 return null;
               },
             ),
             SizedBox(height: 24),
             SizedBox(
               width: double.infinity,
               child: ElevatedButton(
                 onPressed: () async {
                   if (_formKey.currentState!.validate()) {
                     final userId = FirebaseAuth.instance.currentUser?.uid;
                     final contactRef = FirebaseFirestore.instance
                         .collection('doctors')
                         .doc(userId)
                         .collection('emergencyContacts')
                         .doc(contact?.id ?? FirebaseFirestore.instance.collection('doctors').doc().id);
                      await contactRef.set({
                       'firstName': _firstNameController.text,
                       'lastName': _lastNameController.text,
                       'phoneNumber': _phoneNumberController.text,
                       'relation': _relationController.text,
                       'address': _addressController.text,
                     });
                      Navigator.pop(context);
                   }
                 },
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.red,
                   foregroundColor: Colors.white,
                   padding: EdgeInsets.symmetric(vertical: 16),
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(12),
                   ),
                   elevation: 2,
                 ),
                 child: Text(contact == null ? 'Add Contact' : 'Save Changes'),
               ),
             ),
           ],
         ),
       ),
     ),
   );
 }
  Widget buildTextField({
   required String label,
   required TextEditingController controller,
   required IconData icon,
   TextInputType keyboardType = TextInputType.text,
   String? Function(String?)? validator,
 }) {
   return TextFormField(
     controller: controller,
     decoration: InputDecoration(
       labelText: label,
       prefixIcon: Icon(icon, color: Colors.red),
       filled: true,
       fillColor: Colors.grey.shade50,
       border: OutlineInputBorder(
         borderRadius: BorderRadius.circular(12),
         borderSide: BorderSide(color: Colors.grey.shade300),
       ),
       enabledBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(12),
         borderSide: BorderSide(color: Colors.grey.shade300),
       ),
       focusedBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(12),
         borderSide: BorderSide(color: Colors.red),
       ),
     ),
     keyboardType: keyboardType,
     validator: validator,
   );
 }
}
class EditEmergencyContactScreen extends StatelessWidget {
 final EmergencyContact contact;
  final TextEditingController firstNameController = TextEditingController();
 final TextEditingController lastNameController = TextEditingController();
 final TextEditingController phoneController = TextEditingController();
 final TextEditingController relationController = TextEditingController();
 final TextEditingController addressController = TextEditingController();
  EditEmergencyContactScreen({
   Key? key,
   required this.contact,
 }) : super(key: key) {
   // Initialize controllers with existing contact data
   firstNameController.text = contact.firstName;
   lastNameController.text = contact.lastName;
   phoneController.text = contact.phoneNumber;
   relationController.text = contact.relation;
   addressController.text = contact.address;
 }
  @override
 Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Colors.grey[50],
     appBar: AppBar(
       leading: IconButton(
         icon: Icon(Icons.arrow_back, color: Colors.white),
         onPressed: () => Navigator.pop(context),
       ),
       title: Text(
         'Edit Emergency Contact',
         style: TextStyle(
           color: Colors.white,
           fontSize: 20,
           fontWeight: FontWeight.bold,
         ),
       ),
       backgroundColor: Colors.red,
       elevation: 0,
     ),
     body: SingleChildScrollView(
       child: Padding(
         padding: const EdgeInsets.all(16.0),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Center(
               child: Column(
                 children: [
                   Container(
                     padding: EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: Colors.red.shade50,
                       shape: BoxShape.circle,
                     ),
                     child: Icon(
                       Icons.person,
                       size: 50,
                       color: Colors.red,
                     ),
                   ),
                   SizedBox(height: 8),
                   Text(
                     'Contact Information',
                     style: TextStyle(
                       fontSize: 18,
                       fontWeight: FontWeight.bold,
                       color: Colors.black87,
                     ),
                   ),
                 ],
               ),
             ),
             SizedBox(height: 24),
              Container(
               padding: EdgeInsets.all(20),
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(15),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.grey.withOpacity(0.1),
                     spreadRadius: 1,
                     blurRadius: 10,
                     offset: Offset(0, 3),
                   ),
                 ],
               ),
               child: Column(
                 children: [
                   buildTextField(
                     label: 'First Name',
                     icon: Icons.person_outline,
                     hint: 'Enter first name',
                     controller: firstNameController,
                   ),
                   SizedBox(height: 16),
                   buildTextField(
                     label: 'Last Name',
                     icon: Icons.person_outline,
                     hint: 'Enter last name',
                     controller: lastNameController,
                   ),
                   SizedBox(height: 16),
                   buildTextField(
                     label: 'Phone Number',
                     icon: Icons.phone_outlined,
                     hint: 'Enter phone number',
                     controller: phoneController,
                   ),
                   SizedBox(height: 16),
                   buildTextField(
                     label: 'Relation',
                     icon: Icons.people_outline,
                     hint: 'Enter relation',
                     controller: relationController,
                   ),
                   SizedBox(height: 16),
                   buildTextField(
                     label: 'Address',
                     icon: Icons.location_on_outlined,
                     hint: 'Enter address',
                     controller: addressController,
                   ),
                 ],
               ),
             ),
             SizedBox(height: 24),
              SizedBox(
               width: double.infinity,
               child: ElevatedButton(
                 onPressed: () async {
                   final userId = FirebaseAuth.instance.currentUser?.uid;
                   final contactRef = FirebaseFirestore.instance
                       .collection('doctors')
                       .doc(userId)
                       .collection('emergencyContacts')
                       .doc(contact.id);
                    await contactRef.update({
                     'firstName': firstNameController.text,
                     'lastName': lastNameController.text,
                     'phoneNumber': phoneController.text,
                     'relation': relationController.text,
                     'address': addressController.text,
                   });
                    Navigator.pop(context);
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                       content: Text('Contact updated successfully'),
                       backgroundColor: Colors.green,
                       duration: Duration(seconds: 2),
                     ),
                   );
                 },
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.red,
                   foregroundColor: Colors.white,
                   padding: EdgeInsets.symmetric(vertical: 16),
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(12),
                   ),
                   elevation: 2,
                 ),
                 child: Text(
                   'Save Changes',
                   style: TextStyle(
                     fontSize: 16,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
               ),
             ),
           ],
         ),
       ),
     ),
   );
 }
  Widget buildTextField({
   required String label,
   required IconData icon,
   required String hint,
   required TextEditingController controller,
 }) {
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       Text(
         label,
         style: TextStyle(
           fontSize: 14,
           fontWeight: FontWeight.w500,
           color: Colors.grey.shade700,
         ),
       ),
       SizedBox(height: 8),
       TextField(
         controller: controller,
         decoration: InputDecoration(
           hintText: hint,
           hintStyle: TextStyle(color: Colors.grey.shade400),
           prefixIcon: Icon(icon, color: Colors.red),
           filled: true,
           fillColor: Colors.grey.shade50,
           border: OutlineInputBorder(
             borderRadius: BorderRadius.circular(12),
             borderSide: BorderSide(color: Colors.grey.shade300),
           ),
           enabledBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(12),
             borderSide: BorderSide(color: Colors.grey.shade300),
           ),
           focusedBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(12),
             borderSide: BorderSide(color: Colors.red),
           ),
         ),
       ),
     ],
   );
 }


}
