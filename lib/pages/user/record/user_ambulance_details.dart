import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserAmbulanceDetail extends StatefulWidget {

  final String ambulance_id;
  final Timestamp createdAt;
  final String ambulance_request_id;
  final String user_id;
  final String rescueReport_id;
  final double rescue_location_latitude;
  final double rescue_location_longitude;

  UserAmbulanceDetail({
    required this.ambulance_id,
    required this.createdAt,
    required this.rescueReport_id,
    required this.ambulance_request_id,
    required this.user_id,
    required this.rescue_location_latitude,
    required this.rescue_location_longitude
  });

  @override
  _UserAmbulanceDetailState createState() => _UserAmbulanceDetailState();
}

class _UserAmbulanceDetailState extends State<UserAmbulanceDetail> {
  Map<String, dynamic>? data; // Store the user data here
  DateTime? date;
  // Fetch user data using patientId
  Future<void> fetchUserData() async {
    final DocumentReference ambulanceRef =
        FirebaseFirestore.instance.collection('RescueReport').doc(widget.ambulance_id);

    try {
      final DocumentSnapshot snapshot = await ambulanceRef.get();
      if (snapshot.exists) {
        setState(() {
          data = snapshot.data() as Map<String, dynamic>;
        });
      } else {
        print('User not found');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data when the page is loaded
  }

  @override
Widget build(BuildContext context) {
  Timestamp t = widget.createdAt; // Use the Timestamp directly
  DateTime date = t.toDate();
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        'Ambulance Record',
        style: TextStyle(color: Colors.black),
      ),
      centerTitle: true,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20), // Add space at the top
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            height: 500.0, // Increased height for the content area
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Record ID: ${widget.ambulance_request_id}',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text('Ambulance Name: ${widget.ambulance_id}'),
                SizedBox(height: 8.0),
                Text(
                  'Date: ${DateFormat('MMMM d, y').format(date)}',
                  style: TextStyle(fontSize: 16.0, color: Colors.grey.shade600),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Ambulance Detail',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Expanded( // Allow the content area to expand
                  child: Container(
                    width: 300,
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        'Final Rescue Location: ${widget.rescue_location_latitude}, ${widget.rescue_location_longitude}', // Add your content here
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}