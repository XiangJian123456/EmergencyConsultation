import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RescueMap extends StatefulWidget {
  @override
  _RescueMapState createState() => _RescueMapState();
}

class _RescueMapState extends State<RescueMap> {

  
  final Location locationController = Location();
  static const LatLng entryPoint = LatLng(1.533713518444325, 103.68187281981561);
  LatLng? currentPosition;
  bool _isLoading = false;
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
    super.dispose();
  }
  Future<void> updateAmbulanceLocation(String ambulanceId, String longitude, String latitude) async {
  // Reference to the Firestore collection where ambulance data is stored
  CollectionReference ambulanceCollection = FirebaseFirestore.instance.collection('ambulance');
  String ambulanceId = FirebaseAuth.instance.currentUser!.uid;
  try {
    // Update the ambulance's location using the ambulanceId
    await ambulanceCollection.doc(ambulanceId).update({
      'longitude': currentPosition!.longitude,
      'latitude': currentPosition!.latitude,
      'lastUpdated': FieldValue.serverTimestamp(), // Optional: Store the last updated timestamp
    });

    print('Ambulance location updated successfully.');
  } catch (e) {
    print('Error updating ambulance location: $e');
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
            child: 
          Container(
            alignment: Alignment.bottomCenter,
            child: _isLoading ? CircularProgressIndicator() :
          ElevatedButton(
                onPressed: () async{
                  setState(() {
                    _isLoading = true;
                  });
               try {
                  await updateAmbulanceLocation(
                 FirebaseAuth.instance.currentUser!.uid,
                 currentPosition!.longitude.toString(),
                currentPosition!.latitude.toString(),
                  );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Hospital Location Updated Successfully")),
                   );
                 } catch (e) {
                          // Handle the error and show a failure message
                 ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to update location: $e")),
                );
                } finally {
                 setState(() {
                  _isLoading = false; // Reset loading state
                  });
                }
              },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 50),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(fontSize: 18 , color: Colors.white),
                ),
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
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
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
