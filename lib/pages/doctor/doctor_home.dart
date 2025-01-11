import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergencyconsultation/widget/chatbox/consultation_room.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

final firestore = FirebaseFirestore.instance.collection('users');
User? user = FirebaseAuth.instance.currentUser;
Future<bool> showConfirmationDialog(BuildContext context, bool newValue) async {
  return await showDialog<bool>(
      context: context,
      builder: (context){
        return AlertDialog(
          title: Text('Change Status'),
          content: Text('Do you want switch ${newValue ? 'Online':'Offline'} ?'),
          actions: [
            TextButton(
              onPressed:()=> Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Confirm'))
          ],
        );
      }
  )?? false;
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  bool switchValue = false;
  bool tempValue = false;
  double xPosition = 100.0;
  double yPosition = 100.0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateDoctorStatus(bool isOnline) async {
    try {
      await _firestore.collection('doctors').doc(user?.uid).update({
        'isOnline': isOnline,
      });
    } catch (e) {
      print('Error updating doctor status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('doctors').doc(user?.uid).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text('Loading...');
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Text('New User');
                        }
                        String firstName = snapshot.data!['firstName'] ?? 'User1';
                        String lastName = snapshot.data!['lastName'] ?? 'Unknown';
                        return Text(
                          '$firstName $lastName',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              Container(
                width: 180,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance.collection('doctors').doc(user?.uid).snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text('Loading...');
                            }
                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return const Text('New User');
                            }
                            
                            // Get the isOnline status from the snapshot
                            bool isOnline = snapshot.data!['isOnline'] ?? false;
                            
                            return Switch(
                              value: isOnline, // Set the switch value based on isOnline
                              activeColor: Colors.green,
                              onChanged: (newValue) async {
                                final confirm = await showConfirmationDialog(context, newValue);
                                if (confirm) {
                                  setState(() {
                                    switchValue = newValue;
                                    tempValue = newValue;
                                  });
                                  await updateDoctorStatus(newValue);
                                } else {
                                  setState(() {
                                    tempValue  = switchValue;
                                  });
                                }
                              },
                            );
                          },
                        ),
                        Row(
                          children: [
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance.collection('doctors').doc(user?.uid).snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Text('Loading...');
                                }
                                if (!snapshot.hasData || !snapshot.data!.exists) {
                                  return const Text('New User');
                                }
                                bool isOnline = snapshot.data!['isOnline'] ?? false;
                                return Text(
                                  isOnline ? 'Online' : 'Offline',
                                  style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: switchValue ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              const Text(
                'Patient List',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.grey,
        ),
      ],
    ),
    child: StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('consultations')
          .where('doctorId', isEqualTo: user?.uid)
          .where('status', isEqualTo: 'pending')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var consultation = snapshot.data!.docs[index].data() as Map<String, dynamic>;

            return Card(
              margin: EdgeInsets.all(8),
              child: ListTile(
                title: Text('${consultation['patientName'] ?? 'Unknown Patient'}'),
                subtitle: Text(consultation['status'] ?? 'pending'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () async {
                        try {
                          await _firestore
                              .collection('consultations')
                              .doc(snapshot.data!.docs[index].id)
                              .update({
                            'status': 'accepted',
                            'doctorId': user?.uid,
                          });

                          QuerySnapshot chatRoomSnapshot = await _firestore
                              .collection('chatRooms')
                              .where('consultationId', isEqualTo: snapshot.data!.docs[index].id)
                              .get();

                          String chatRoomId;

                          if (chatRoomSnapshot.docs.isNotEmpty) {
                            chatRoomId = chatRoomSnapshot.docs.first.id;
                          } else {
                            DocumentReference chatRoomRef = await _firestore.collection('chatRooms').add({
                              'consultationId': snapshot.data!.docs[index].id,
                              'participants': [user?.uid, consultation['patientId']],
                              'createdAt': FieldValue.serverTimestamp(),
                            });
                            chatRoomId = chatRoomRef.id;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatRoom(
                                chatRoomId: chatRoomId,
                                consultationId: snapshot.data!.docs[index].id,
                                participants: consultation,
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')),
                          );
                        }
                      },
                      child: Text('Accept'),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green,
                        disabledBackgroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        await _firestore
                            .collection('consultations')
                            .doc(snapshot.data!.docs[index].id)
                            .update({'status': 'rejected'});
                      },
                      child: Text('Reject'),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
                        disabledBackgroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
  ),
),
            ],
          ),
        ),
      ),
    );
  }
}
