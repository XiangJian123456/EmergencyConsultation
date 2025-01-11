import 'package:emergencyconsultation/controller/consultation_controller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorSelection extends StatefulWidget {
  const DoctorSelection({super.key});

  @override
  State<DoctorSelection> createState() => _DoctorSelectionState();
}

class _DoctorSelectionState extends State<DoctorSelection> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ConsultationController _consultationController = ConsultationController();
  
  @override
  Widget build(BuildContext context) {
    // Check if user is authenticated
    if (_auth.currentUser == null) {
      return const Center(child: Text('Please login to view doctors'));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Find Your Doctor',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.redAccent,
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('doctors').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No doctors available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doctorData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              bool isOnline = doctorData['isOnline'] ?? false;
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Doctor image
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.purple.shade100,
                              backgroundImage: doctorData['profilePicture'] != null
                                  ? NetworkImage(doctorData['profilePicture'])
                                  : null,
                              child: doctorData['profilePicture'] == null
                                  ? const Icon(Icons.person, size: 40, color: Colors.purple)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            // Doctor info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Dr. ${doctorData['firstName'] ?? ''} ${doctorData['lastName'] ?? ''}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      // Online status indicator
                                      StreamBuilder<DocumentSnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('doctors')
                                            .doc(doctorData['uid'])
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            bool isOnline = doctorData['isOnline'] ?? false;
                                            return Row(
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: isOnline ? Colors.green : Colors.grey,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  isOnline ? 'Online' : 'Offline',
                                                  style: TextStyle(
                                                    color: isOnline ? Colors.green : Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                          return const SizedBox();
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    doctorData['specialist'] ?? 'Specialist not specified',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Add more doctor details if needed
                                  Text(
                                    'Experience: ${doctorData['experience'] ?? 'N/A'} years',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Book Now button
                        SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isOnline ? () {
                            _consultationController.sendConsultationRequest(doctorData, context);
                          } : null, // Disable button if offline
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Consultation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


  

