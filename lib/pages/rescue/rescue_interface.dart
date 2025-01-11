import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergencyconsultation/pages/rescue/rescue_onmap.dart';

import 'package:firebase_auth/firebase_auth.dart';


import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
 // Adjust the import path

class RescuePage extends StatefulWidget {
  @override
  _RescuePageState createState() => _RescuePageState();
}

class _RescuePageState extends State<RescuePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String? currentUserId;
  final Location locationController = Location();
  LatLng? currentPosition;
  bool hasRequest = false;
  StreamSubscription<LocationData>? locationSubscription;
  GoogleMapController? mapController;
  Map<String, dynamic>? selectedAmbulance;
  


  @override
    void initState() {
      super.initState();
      currentUserId = auth.currentUser?.uid;

      // Fetch the selected ambulance details
      fetchSelectedAmbulance(currentUserId!).then((ambulanceData) {
        setState(() {
          selectedAmbulance = ambulanceData; // Set the fetched data
        });
      });
    }
Future<void> updateRequestStatus(String documentID, String newStatus , double ambulanceLatitude, double ambulanceLongitude ,double userLatitude, double userLongitude, bool patientSecured) async {
  try {
    final user_latitude = userLatitude;
    final user_longitude = userLongitude;
    await firestore
        .collection('ambulanceRequests')
        .doc(documentID) // Use the provided request ID
        .update({
          'onhold_status': newStatus, // Update the status to the new value
          'current_ambulance_latitude': ambulanceLatitude,
          'current_ambulance_longitude': ambulanceLongitude,
          'current_user_latitude': user_latitude,
          'current_user_longitude': user_longitude,
          'patient_secured': false,
        });
        print('Current ambulance latitude: $ambulanceLatitude');
        print('Current ambulance longitude: $ambulanceLongitude');
        print('Current user latitude: $user_latitude');
        print('Current user longitude: $user_longitude');
    print('Request status updated successfully to: $newStatus');
  } catch (e) {
    print('Error updating request status: $e');
  }
}
Future<Map<String, dynamic>?> fetchSelectedAmbulance(String currentUserId) async {
  try {
    DocumentSnapshot doc = await firestore.collection('ambulanceRequests').doc(selectedAmbulance?['uid']).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
  } catch (e) {
    print('Ambulance ID: ${selectedAmbulance?['uid']}');
    print('Error fetching ambulance: $e');
  }
  return null; // Return null if not found or an error occurs
}

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rescue Main Pages"),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('ambulance').doc(currentUserId).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text('Loading...');
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Text('New Hospital');
                        }
                        String firstName = snapshot.data!['firstName'] ?? 'User1';
                        String lastName = snapshot.data!['lastName'] ?? 'Unknown';
                        return Text(
                          '$firstName $lastName',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            
              const SizedBox(height: 32),
              const Text(
                'Rescue List',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  
                  child: StreamBuilder<QuerySnapshot>(  
  stream: firestore.collection('ambulanceRequests').where('ambulanceId', isEqualTo: selectedAmbulance?['uid'])
  .where('status', isNotEqualTo: 'accepted')
  .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) { // Corrected condition
      return Center(child: Text('No data available'));
    }
    return ListView.builder(
      itemCount: snapshot.data!.docs.length,
      itemBuilder: (context, index) {
        var ambulanceRequest = snapshot.data!.docs[index].data() as Map<String, dynamic>;
        
       return Card(
          margin: EdgeInsets.all(8),
          child: ListTile(
            title: Text('${ambulanceRequest['name'] ?? 'Unknown Patient'}'),
            subtitle: Column( // Changed to Column to add more information
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Location of latitude: ${ambulanceRequest['user_latitude'] ?? 'Unknown Patient'}'),
                Text('Location of longitude: ${ambulanceRequest['user_longitude'] ?? 'Unknown Patient'}'),
                Text(ambulanceRequest['status'] ?? 'SOS'),
                if (selectedAmbulance != null) // Check if selectedAmbulance is not null
                  Text('Ambulance ID: ${selectedAmbulance?['uid'] ?? 'Unknown'}'), // Display the uid
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [ 
                TextButton(
                  onPressed: () async {
                    await fetchSelectedAmbulance(currentUserId!);
                    
                    var ambulanceRequest = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    final Map<String, dynamic> selectedAmbulance = ambulanceRequest['selectedAmbulance'] ?? {};
                    print('Selected Ambulance: $selectedAmbulance');
                    print('Navigating to Rescue_On_Map with the following values:');
                    print('Name: ${ambulanceRequest['user_name']}');
                    print('User ID: ${ambulanceRequest['user_userId']?? 'Unknown'}');
                    print('User Latitude: ${ambulanceRequest['user_latitude']?? 'Unknown'}');
                    print('User Longitude: ${ambulanceRequest['user_longitude']?? 'Unknown'}');
                    print('Ambulance ID: ${selectedAmbulance['uid'] ?? 'Unknown'}');
                    print('Ambulance Latitude: ${selectedAmbulance['latitude'] ?? 'Unknown'}');
                    print('Ambulance Longitude: ${selectedAmbulance['longitude'] ?? 'Unknown'}');
                    final ambulanceId = selectedAmbulance['uid'] ?? '';
                    final ambulanceLatitude = selectedAmbulance['latitude'] ?? '';
                    final ambulanceLongitude = selectedAmbulance['longitude'] ?? '';
                    final ambulanceName = '${selectedAmbulance['firstName'] ?? 'Unknown First Name'} ${selectedAmbulance['lastName'] ?? 'Unknown Last Name'}';
                    await updateRequestStatus(
                      ambulanceRequest['documentId'], 
                    'accepted', ambulanceLatitude, 
                    ambulanceLongitude, 
                    ambulanceRequest['user_latitude'], 
                    ambulanceRequest['user_longitude'],
                    false
                    
                    );
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Rescue_On_Map(
                      ambulanceName: ambulanceName,
                      ambulanceId: ambulanceId,
                      name: ambulanceRequest['user_name'],
                      user_latitude: ambulanceRequest['user_latitude'],
                      user_longitude: ambulanceRequest['user_longitude'],
                      userId: ambulanceRequest['user_userId'],
                      ambulanceRequestID: ambulanceRequest['documentId'],
                      ambulanceLatitude: ambulanceLatitude,
                      ambulanceLongitude: ambulanceLongitude,
                    )));
                  },
                  child: Text('Accept'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                    disabledBackgroundColor: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    await firestore
                        .collection('ambulanceRequests')
                        .doc(snapshot.data!.docs[index].id)
                        .update({'status': 'rejected'});
                  },
                  child: Text('Reject'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    disabledBackgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  },
),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}