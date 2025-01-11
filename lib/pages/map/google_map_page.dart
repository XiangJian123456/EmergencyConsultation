import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergencyconsultation/widget/chatbox/loading_widget.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';


class GoogleMapPage extends StatefulWidget {
  @override
  _GoogleMapPageState createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  
  final Location locationController = Location();
  static const LatLng entryPoint = LatLng(1.533713518444325, 103.68187281981561);
  LatLng? currentPosition;
  bool _isLoading = false;// Loading state variable
  bool _sosRequestSent = false;
  StreamSubscription<LocationData>? locationSubscription;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchLocationUpdate();
    });
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }


Future<void> sendRequest(double latitude, double longitude, String name, String description,String phone,String icNumber,String userId, String address) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
    final userId = currentUser.uid;
    final phone = userDoc['phone'];
    final icNumber = userDoc['icNumber'];
    final address = userDoc['address'];
    final name = userDoc['firstName'] + ' ' + userDoc['lastName'];
    final url = 'https://us-central1-medical-emergency-38bb9.cloudfunctions.net/requestAmbulance';// Replace with your Firebase function URL
    final response = await http.post(
        Uri.parse(url),
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
            'userId': userId,
            'phone': phone,
            'name': name,
            'address': address,
            'icNumber': icNumber,
            'latitude': latitude,
            'longitude': longitude,
            'description': description,
        }),

       
    );

    if (response.statusCode == 200) {
        // Handle successful response
        print('Request successful: ${response.body}');
    } else {
        // Handle error response
        print('Request failed: ${response.statusCode} - ${response.body}');
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SOS Emergency Tracking Location', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: entryPoint,
              zoom: 15,
            ),
            markers: _createMarkers(),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: 
                Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                       onPressed: _isLoading ? null : () async {

                        setState(() {
                          _isLoading = true; // Set loading state to true
                        });
                        final currentUser = FirebaseAuth.instance.currentUser;

                        if (currentUser != null) {
                          final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();

                          // Directly define the variables
                          final String userId = currentUser.uid;
                          final String phone = userDoc['phone'] ?? ''; // Use null-aware operator
                          final String icNumber = userDoc['icNumber'] ?? ''; // Use null-aware operator
                          final String name = '${userDoc['firstName'] ?? ''} ${userDoc['lastName'] ?? ''}';
                          final String address = userDoc['address'] ?? ''; // Use null-aware operator

                          // Now you can call sendRequest with these variables
                          await sendRequest(
                              currentPosition!.latitude, // Use the current latitude
                              currentPosition!.longitude, // Use the current longitude
                              name, // Description
                              'SOS',
                              phone, // Use the defined phone
                              icNumber, // Use the defined IC number
                              userId,
                              address // Use the defined user ID
                          );

                          setState(() {
                            _isLoading = false;
                            _sosRequestSent = false;// Set loading state back to false
                          });
                          await Future.delayed(Duration(seconds: 2)); // Simulate delay
                          showModalBottomSheet(
                          context: context,
                          builder: (context) {
                              return Container(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text( 'SOS request sent successfully!',
                                      style: TextStyle(fontSize: 18),
                                      textAlign: TextAlign.center,
                                  ),
                              );
                          },
                      );
        // Navigate to the loading page
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => LoadingPage()), // Replace with your loading page widget
                            );
                          // Removed showModalBottomSheet and StreamBuilder
                          print('SOS request sent successfully!');
                        } else {
                          print('User is not logged in.');
                        }
                        await Future.delayed(Duration(seconds: 2)); // Simulate delay
                        setState(() {
                          _isLoading = false; // Set loading state back to false
                        });
                      },
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white) // Show loading indicator
                          : Text('SOS'),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Set<Marker> _createMarkers() {
    return {
      if (currentPosition != null)
        Marker(
          markerId: MarkerId('currentLocation'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: currentPosition!,
        ),
    };
  }

  Future<void> fetchLocationUpdate() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    locationSubscription = locationController.onLocationChanged.listen((currentLocation) {
      if (!mounted) return; // Check if the widget is still mounted

      final double? latitude = currentLocation.latitude;
      final double? longitude = currentLocation.longitude;

      // Check if latitude and longitude are not null
      if (latitude != null && longitude != null) {
        final LatLng newPosition = LatLng(latitude, longitude);

        // Only update if the position has changed
        if (currentPosition == null || currentPosition != newPosition) {
          setState(() {
            currentPosition = newPosition;
          });

          // Animate the camera to the current location
          if (mapController != null) {
            mapController!.animateCamera(
              CameraUpdate.newLatLng(currentPosition!),
            );
          }
        }
      } else {
        // Handle the case where location data is not available
        print('Location data is not available.');
      }
    });

    // Check if location services are enabled
    serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return;
      }
    }

    // Check location permissions
    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print('Location permission denied.');
        return;
      }
    }

    // Get current location and listen for updates
    locationController.onLocationChanged.listen((currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        setState(() {
          currentPosition = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
        });

        // Animate the camera to the current location
        if (mapController != null) {
          mapController!.animateCamera(
            CameraUpdate.newLatLng(currentPosition!),
          );
        }
      }
    });
  }
}