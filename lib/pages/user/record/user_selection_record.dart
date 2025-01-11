import 'package:emergencyconsultation/pages/user/record/user_ambulance_records.dart';
import 'package:emergencyconsultation/pages/user/record/user_healthrecord.dart';
import 'package:flutter/material.dart';

class UserSelectionRecord extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Record Category'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Fixed the missing brackets for the children list
          _buildServiceCard(
            'Medical Consultation',
            'assets/doctor-consultation.png',
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => HealthRecordScreen())),
          ),
          const SizedBox(height: 20),
          _buildServiceCard(
            'Emergency SOS',
            'assets/ambulance.png',
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserAmbulanceRecord())),
            isEmergency: true,
          ),
        ],
      ),
    );
  }
}

Widget _buildServiceCard(String title, String imagePath, VoidCallback onTap, {bool isEmergency = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 110,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: isEmergency ? Colors.red.shade200 : Colors.grey.shade200,
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isEmergency ? Colors.red : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
