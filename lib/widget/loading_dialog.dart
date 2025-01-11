import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergencyconsultation/pages/rescue/rescue_mainpages.dart';
import 'package:flutter/material.dart';

class LoadingPage2 extends StatefulWidget {
  @override
  _LoadingPage2State createState() => _LoadingPage2State();
  final String name ;
  final String ambulanceName;
  final double user_latitude;
  final double user_longitude;
  final String userId;
  final String ambulanceId;
  final String ambulanceRequestID;
  LoadingPage2({
    required this.ambulanceName, 
    required this.ambulanceId,
    required this.name,
    required this.user_latitude,
    required this.user_longitude,
    required this.userId, 
    required this.ambulanceRequestID,
  });
}

class _LoadingPage2State extends State<LoadingPage2> {
  // You can add any state variables here if needed
  bool isLoading = true; // Example state variable

  @override
  void initState() {
    super.initState();
    // Simulate a loading process
    Future.delayed(Duration(seconds: 3), () async {
      await generateRescueReport();
      setState(() {
        isLoading = false; // Update the loading state after 3 seconds
      });
    });
  }
Future<void> generateRescueReport() async {
   DocumentReference documentReference = FirebaseFirestore.instance.collection('RescueReport').doc();
    
    await documentReference.set({
      'ambulance_id': widget.ambulanceId,
      'user_id': widget.userId,
      'ambulance_request_id': widget.ambulanceRequestID,
      'rescue_location_latitude': widget.user_latitude,
      'rescue_location_longitude': widget.user_longitude,
      'rescue_location_name': widget.name,
      'rescueReport_id': documentReference.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color of the loading page
      body: Center(
        child: isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Color of the loading spinner
                  ),
                  SizedBox(height: 20), // Space between the spinner and the text
                  Text(
                    'Loading, please wait...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Text color
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Generate Report Successfully', // Message after loading is done
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green, // Text color
                    ),
                  ),
                  SizedBox(height: 20), // Space between the message and the button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AmbulanceMainPages())); // Navigate back to the previous page
                    },
                    child: Text('Well Done! Now You Can Back to Home Page'), // Button text
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Button color
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Button padding
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}