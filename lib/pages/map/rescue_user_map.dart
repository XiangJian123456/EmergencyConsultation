import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:emergencyconsultation/widget/user_success.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Rescue_OnUser_Map extends StatefulWidget {
  final String name;
  final double user_latitude;
  final double user_longitude;
  final String userId;
  final Map<String, dynamic> selectedAmbulance;
  final String ambulanceName;
  final double ambulanceLatitude;
  final double ambulanceLongitude;
  final String ambulancePhone;
  final String ambulanceAddress;
  final String ambulanceId;
  final String ambulanceRequestID;

  Rescue_OnUser_Map({
    required this.name,
    required this.user_latitude,
    required this.user_longitude,
    required this.userId,
    required this.selectedAmbulance,
    required this.ambulanceName,
    required this.ambulanceLatitude,
    required this.ambulanceLongitude,
    required this.ambulancePhone,
    required this.ambulanceAddress,
    required this.ambulanceId, 
    required this.ambulanceRequestID,
  });

  @override
  _Rescue_OnUser_Map_State createState() => _Rescue_OnUser_Map_State(); // Ensure correct state class name
}

class _Rescue_OnUser_Map_State extends State<Rescue_OnUser_Map> {

  final Location locationController = Location();
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  String googleMapApiKey = 'AIzaSyC1pEb7YkGTfxsjZR2Umui5PjE6xKEhBlc';
  LatLng? currentPosition;
  LatLng? ambulancePosition;

  StreamSubscription<LocationData>? locationSubscription;
  StreamSubscription<DocumentSnapshot>? ambulanceLocationSubscription;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  GoogleMapController? mapController;

    
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ambulancePosition = LatLng(widget.ambulanceLatitude, widget.ambulanceLongitude);
      await fetchLocationUpdate();
      await fetchAmbulanceLocationUpdate();
     
    });
  }
  Future<void> _fetchAndDisplayPolyline() async {
    if (currentPosition != null && ambulancePosition != null) {
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
     
  
    
  @override
  void dispose() {
    ambulanceLocationSubscription?.cancel();
    super.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SOS Emergency Tracking Location', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
      body: currentPosition == null ? const Center(child: Text('Loading...'),) : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.user_latitude, widget.user_longitude),
              zoom: 15,
            ),
            markers: _createMarkers(),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            polylines:Set<Polyline>.of(polylines.values),
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
       if (ambulancePosition != null) // Ensure the ambulance marker is created
      Marker(
        markerId: MarkerId('AmbulanceLocation'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: ambulancePosition!,
      ),
    };
  }
  Future<List<LatLng>> fetchPolyline() async {
    final polylinePoints = PolylinePoints();
    final resultPoints = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleMapApiKey,
      request: PolylineRequest(
        origin: PointLatLng(currentPosition!.latitude, currentPosition!.longitude),
        destination: PointLatLng(ambulancePosition!.latitude, ambulancePosition!.longitude),
        mode: TravelMode.driving
      ),
    );
    if (resultPoints.points.isNotEmpty) {
      final polylineId = PolylineId('ambulanceRoute');
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
        .update({'current_user_latitude': latitude, 'current_user_longitude': longitude});
        // Only update if the position has changed
        if (currentPosition == null || currentPosition != newPosition) {
          setState(() {
            currentPosition = newPosition;
          });
          _fetchAndDisplayPolyline();
          fetchAmbulanceLocationUpdate();
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

  Future<void> fetchAmbulanceLocationUpdate() async {
  if (!mounted) return; // Check if the widget is still mounted

  ambulanceLocationSubscription = FirebaseFirestore.instance
    .collection('ambulanceRequests') // Adjust the collection name as needed
    .doc(widget.ambulanceRequestID) // Use the ambulance ID to get the specific document
    .snapshots()
    .listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final double? ambulance_latitude = data['current_ambulance_latitude'];
        final double? ambulance_longitude = data['current_ambulance_longitude'];
        final bool patientSecured = data['patient_secured'];

        print('Ambulance Latitude: $ambulance_latitude, Longitude: $ambulance_longitude'); // Debugging print

        if (patientSecured == true) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserSuccess()));
        }

        // Check if latitude and longitude are not null
        if (ambulance_latitude != null && ambulance_longitude != null) {
          final LatLng newAmbulancePosition = LatLng(ambulance_latitude, ambulance_longitude);

          // Only update if the position has changed
          if (ambulancePosition != newAmbulancePosition) {
            setState(() {
              ambulancePosition = newAmbulancePosition;
            });
            _fetchAndDisplayPolyline(); // Animate the camera to the current location
            print('Updated ambulance position: $newAmbulancePosition'); // Debugging print
          }
        } else {
          // Handle the case where location data is not available
          print('Location data is not available.');
        }
      } else {
        print('Snapshot does not exist.'); // Debugging print
      }
    }, onError: (error) {
      print('Error fetching ambulance location: $error'); // Error handling
    });
}
}