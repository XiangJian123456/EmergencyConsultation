import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergencyconsultation/pages/rescue/ambulance_record_detail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AmbulanceRecord extends StatelessWidget {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
   // Replace with actual ID
  
  @override
 Widget build(BuildContext context) {
   return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(Icons.local_hospital, color: Colors.red),
            SizedBox(width: 8),
            Text(
              "Ambulance Records",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('RescueReport')
            .where('ambulance_id', isEqualTo: currentUserId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          print(currentUserId);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No records available'));
          }
          // Document data is available here
          return buildAmbulanceRecordList(snapshot.data!.docs);
        },
      ),
    );
  }

  Widget buildAmbulanceRecordList(List<QueryDocumentSnapshot> docs) {
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        var data = docs[index].data() as Map<String, dynamic>;
        print(data);
        return buildAmbulanceRecordUI(data, context);
      },
    );
  }

  Widget buildAmbulanceRecordUI(Map<String, dynamic> data, BuildContext context) {
    Timestamp t = data['createdAt'] as Timestamp ;
    DateTime date = t.toDate();
    return Container(
      margin: EdgeInsets.all(8.0), // Margin around the container
      padding: EdgeInsets.all(16.0), // Padding inside the container
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: InkWell(
      child:
    ListTile(
        title: Text(data['rescue_location_name'] ?? 'Unknown Patient'),
        subtitle: Text(DateFormat('MMMM d, y').format(date)),
        leading: Icon(Icons.local_hospital, color: Colors.red),
       onTap: () { // Removed BuildContext parameter
        Navigator.push(context, MaterialPageRoute(builder: (context) => (AmbulanceRecordDetail (
          rescue_location_name: data['rescue_location_name'],
          ambulance_id: data['ambulance_id'],
          createdAt: data['createdAt'],
          ambulance_request_id: data['ambulance_request_id'],
          user_id: data['user_id'],
          rescue_location_latitude: data['rescue_location_latitude'],
          rescue_location_longitude: data['rescue_location_longitude'],
        ))));
        },
      ),
      ),
    );
  }
}

