import 'package:flutter/material.dart';

class ConsultationWidget extends StatelessWidget {
  // Add properties to make the widget dynamic
  final String profileImageUrl;
  final String name;
  final String icNumber;
  final String location;
  final String email;
  final String recordStatus;
  final String consultationStatus;
  final VoidCallback onStartConsultation;

  const ConsultationWidget({
    Key? key,
    required this.profileImageUrl,
    required this.name,
    required this.icNumber,
    required this.location,
    required this.email,
    required this.recordStatus,
    required this.consultationStatus,
    required this.onStartConsultation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Top Row with image and details
          Row(
            children: [
              // Profile Image
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(color: Colors.black, width: 1),
                  image: DecorationImage(
                    image: NetworkImage(profileImageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 16),
              // User Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('IC: '),
                    Text('Location: '),
                    Text('Email: '),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // New User or Record Status
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Text(
              recordStatus,
              style: TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(height: 16),
          // Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Start Consultation Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  side: BorderSide(color: Colors.black, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: onStartConsultation,
                child: Text('Start Consultation'),
              ),
              // Status Container
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  consultationStatus,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

