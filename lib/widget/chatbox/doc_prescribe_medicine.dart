import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergencyconsultation/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PatientMedicalInformationScreen extends StatefulWidget {
final String userName;
PatientMedicalInformationScreen({required this.userName});
  @override
  _PatientMedicalInformationScreenState createState() => _PatientMedicalInformationScreenState();
}

class _PatientMedicalInformationScreenState extends State<PatientMedicalInformationScreen> {
  TextEditingController prescriptionController = TextEditingController();
  bool isLoading = false; // Loading state variable
  Map<String, dynamic> patientData = {};
   @override
  void initState() {
    super.initState();
     // Fetch patient data on init
  }
  Future<void> fetchPatientData() async {
    try {
      // Fetch data from Firestore using userName
      var snapshot = await FirebaseFirestore.instance
          .collection('users') // Replace with your collection name
          .where('userName', isEqualTo: widget.userName)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          patientData = snapshot.docs.first.data(); // Assuming you want the first match
        });
      }
    } catch (e) {
      print('Error fetching patient data: $e');
    }
  }
  
  Future<void> generatePrescriptionPdf(BuildContext context, String prescriptionText) async {
    final pdf = pw.Document();
    
    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Center(child: pw.Text(prescriptionText));
    }));

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/prescription.pdf');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF Generated Successfully')),
    );

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'pdf_channel_id', 
      'Prescribe Notification',
      channelDescription: 'Notification for Prescribe Medicine',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'PDF Generated',
      'Your prescription PDF has been successfully created.',
      platformChannelSpecifics,
    );

    print('PDF saved to ${file.path}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Patient Medical Information',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Patient Record Section
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.medical_information, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Patient Record',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name: ${widget.userName}',
                                  style: TextStyle(color: Colors.black),
                                ),
                                Text(
                                  'Age: ${patientData['icNumber'] ?? 'N/A'}',
                                  style: TextStyle(color: Colors.black),
                                ),
                                Text(
                                  'Medical History: ${patientData['phone'] ?? 'N/A'}',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Prescribe Medicine Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.medication, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Prescribe Medicine',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          maxLines: 5,
                          controller: prescriptionController,
                          decoration: InputDecoration(
                            hintText: 'Enter prescription details...',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Generate Button
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (prescriptionController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please enter prescription details.')),
                        );
                        return;
                      }

                      setState(() {
                        isLoading = true; // Set loading state to true
                      });

                      await generatePrescriptionPdf(
                        context,
                        prescriptionController.text,
                      );

                      setState(() {
                        isLoading = false; // Set loading state to false
                      });

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Generate Prescription',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                if (isLoading) // Show CircularProgressIndicator if loading
                  Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}