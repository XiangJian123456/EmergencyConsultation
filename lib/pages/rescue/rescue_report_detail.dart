import 'package:flutter/material.dart';

class RescueReportDetailPage extends StatelessWidget {
  // User Parameters
  final String user_lastName; 
  final String user_firstName ; 
  final String user_Id ; 
  final String user_profilePicture ; 
  final String user_email ;
  final String user_gender;
  final String user_address;
  final String user_icNumber ; 
  final String user_phone; 
  final double user_latitude ; 
  final double user_longitude ;
  // Ambulance Parameters
  final String ambulanceId ; 
  final String ambulanceRequestID ;  
  final String ambulanceName ; 
  final String ambulancePhone ; 
  final String ambulanceAddress ; 
  final String ambulanceImage ;
  
  final String rescueReportId ;
  RescueReportDetailPage({
    Key? key,
    required this.user_lastName,
    required this.user_firstName,
    required this.user_Id,
    required this.user_profilePicture,
    required this.user_email,
    required this.user_gender,
    required this.user_address,
    required this.user_icNumber,
    required this.user_phone,
    required this.user_latitude,
    required this.user_longitude,
    required this.ambulanceId,
    required this.ambulanceRequestID,
    required this.ambulanceName,
    required this.ambulancePhone,
    required this.ambulanceAddress,
    required this.ambulanceImage,
    required this.rescueReportId,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Record'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Information Header
            Row(
              children: [
                ClipOval(
                  child: Image.network(
                    user_profilePicture,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name: $user_firstName $user_lastName',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text('IC Number: $user_icNumber'),
                      Text('Email: $user_email'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Patient Medical Information Section
            Text(
              'Patient Medical Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              height: 200, // Adjust height as needed
              child: Center(
                child: Text('No medical information available.'),
                
              ),
            ),
          ],
        ),
      ),
    );
  }
}