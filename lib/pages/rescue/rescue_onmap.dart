import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:emergencyconsultation/widget/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Rescue_On_Map extends StatefulWidget {
  final String name ;
  final String ambulanceName;
  final double user_latitude;
  final double user_longitude;
  final String userId;
  final String ambulanceId;
  final String ambulanceRequestID;
  final double ambulanceLatitude;
  final double ambulanceLongitude;
  Rescue_On_Map({
    required this.ambulanceName,
    required this.ambulanceId,
    required this.name,
    required this.user_latitude,
    required this.user_longitude,
    required this.userId, 
    required this.ambulanceRequestID,
    required this.ambulanceLatitude,
    required this.ambulanceLongitude,
  });
  _Rescue_On_Map_State createState() => _Rescue_On_Map_State();
}

class _Rescue_On_Map_State extends State<Rescue_On_Map> {
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  String googleMapApiKey = 'AIzaSyC1pEb7YkGTfxsjZR2Umui5PjE6xKEhBlc';
  final Location locationController = Location();
  LatLng? currentPosition;
  LatLng? userPosition;


  StreamSubscription<LocationData>? userlocationSubscription;
  StreamSubscription<LocationData>? locationSubscription;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  GoogleMapController? mapController;
  String ambulanceId = FirebaseAuth.instance.currentUser!.uid;
  Polyline? userAmbulancePolyline;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initializeMap();
      userPosition = LatLng(widget.user_latitude, widget.user_longitude);
      // Ensure currentPosition is set before fetching polyline
       _fetchAndDisplayPolyline();
      if (currentPosition != null) {
        await fetchPolyline(); // Fetch polyline after currentPosition is set
      }
    });
  }

  @override
  void dispose() {
    userlocationSubscription?.cancel();
    locationSubscription?.cancel();
    super.dispose();
  }
   Future<void> initializeMap() async {
    await fetchLocationUpdate();
    await fetchUserLocationUpdate();
    // Fetch polyline coordinates
    if (currentPosition != null && userPosition != null) { // Ensure both positions are set
      final coordinates = await fetchPolyline();
      // Generate polyline from fetched coordinates
      generatePolylineFromPoints(coordinates);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SOS Emergency Tracking Location', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
      body:currentPosition == null ? const Center(child: Text('Loading...'),) : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentPosition!,
              zoom: 15,
            ),
            markers: _createMarkers(),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            polylines:Set<Polyline>.of(polylines.values),
          ),
          Positioned(
          bottom: 20, // Position the button at the bottom
          left: 20,
          right: 20,
          child: ElevatedButton(
                    onPressed: () {
                      _markPatientSecured(); // Trigger polyline fetching
                      print('Fetch Polyline button pressed');
                    },
            child: Text('Rescue Completed' ,style: TextStyle(color: Colors.white),),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Button color
              padding: EdgeInsets.symmetric(vertical: 15), // Button padding
            ),
          ),
        ),
        ],
      ),
    );
  }
  Future<void> _fetchAndDisplayPolyline() async {
    if (currentPosition != null && userPosition != null) {
        final coordinates = await fetchPolyline();
        print('Fetched polyline coordinates: $coordinates'); // Debugging print
        if (coordinates.isNotEmpty) {
            generatePolylineFromPoints(coordinates);
            print('The coordinates are: $coordinates');
        } else {
            print('No coordinates returned from fetchPolyline.'); // Debugging print
        }
    } else {
        print('Current position or user position is null.'); // Debugging print
    }
}
  Future<List<LatLng>> fetchPolyline() async {
    final polylinePoints = PolylinePoints();
    final resultPoints = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleMapApiKey,
      request: PolylineRequest(
        origin: PointLatLng(currentPosition!.latitude, currentPosition!.longitude),
        destination: PointLatLng(userPosition!.latitude, userPosition!.longitude),
        mode: TravelMode.driving
      ),
    );
    if (resultPoints.points.isNotEmpty) {
      final polylineId = PolylineId('userAmbulanceRoute');
      print('Polyline points fetched successfully.'); // Debugging print
      return resultPoints.points.map((point) => LatLng(point.latitude, point.longitude)).toList();
    } else {
      debugPrint('Error fetching polyline: ${resultPoints.errorMessage}'); // Debugging print
      return [];
    }
}
  Future<void> generatePolylineFromPoints(List<LatLng> polylineCoordinates) async {
    const polylineId = PolylineId('userAmbulanceRoute');
    final polyline = Polyline(
      polylineId: polylineId,
      points: polylineCoordinates,
      color: Colors.blue,
      width: 5,
    );
    setState(() {
      polylines[polylineId] = polyline;
    });
    print('Polyline generated and added to the map.'); // Debugging print
}

  void _markPatientSecured() {
    FirebaseFirestore.instance
      .collection('ambulanceRequests')
      .doc(widget.ambulanceRequestID)
      .update({'patient_secured': true}).then((_) {
        // Show a confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Patient has been successfully secured!')),
        );

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoadingPage2(
          ambulanceId: widget.ambulanceId,
          ambulanceName: widget.ambulanceName,
          name: widget.name,
          user_latitude: widget.user_latitude,
          user_longitude: widget.user_longitude,
          userId: widget.userId,
          ambulanceRequestID: widget.ambulanceRequestID,
        )));
      }).catchError((error) {
        // Handle any errors
        print('Error updating patient status: $error');
        
      });
  }
  Set<Marker> _createMarkers() {
    return {
      
      if (currentPosition != null)
      // Current Location Marker
        Marker(
          markerId: MarkerId('currentLocation'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: currentPosition!,
        ),
        if (userPosition != null) // Check if userPosition is not null
      // User Location Marker
      Marker(
        markerId: MarkerId('userLocation'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        position: userPosition!,
      ),
      
    };
  }
  
 
  // Current Location Update Method
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
         FirebaseFirestore.instance
        .collection('ambulanceRequests')
        .doc(widget.ambulanceRequestID)
        .update({'current_ambulance_latitude': latitude, 'current_ambulance_longitude': longitude});
        // Only update if the position has changed
        if (currentPosition == null || currentPosition != newPosition) {
          setState(() {
            currentPosition = newPosition;
          });
         _fetchAndDisplayPolyline();
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
      currentPosition = LatLng(currentLocation.latitude!,currentLocation.longitude!);
    });
    // Animate the camera to the current location
    if (mapController != null && currentPosition != null) { // Check if currentPosition is not null
      mapController!.animateCamera(
        CameraUpdate.newLatLng(currentPosition!),
      );
    }
  }
});
  }
  Future<void> fetchUserLocationUpdate() async {
      if (!mounted) return; // Check if the widget is still mounted
      
      FirebaseFirestore.instance
        .collection('ambulanceRequests') // Adjust the collection name as needed
        .doc(widget.ambulanceRequestID) // Use the ambulance ID to get the specific document
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data() as Map<String, dynamic>;
            final double? current_user_latitude = data['current_user_latitude'];
            final double? current_user_longitude = data['current_user_longitude'];

            // Check if latitude and longitude are not null
            if (current_user_latitude != null && current_user_longitude != null) {
              final LatLng newUserPosition = LatLng(current_user_latitude, current_user_longitude);

              // Only update if the position has changed
              if (userPosition != newUserPosition) {
                setState(() {
                  userPosition = newUserPosition ;
                });
                _fetchAndDisplayPolyline();
                
              }
            } else {
              // Handle the case where location data is not available
              print('Location data is not available.');
            }
          }
        });
  }
}
