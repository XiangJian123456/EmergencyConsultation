import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergencyconsultation/pages/user/record/user_chat_history.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserHealthDetail extends StatefulWidget {
  final String consultationId;
  final Timestamp generatedAt;
  final String patientName;
  final String patientId;
  final String chatRoomId;

  UserHealthDetail({
    required this.patientId,
    required this.consultationId,
    required this.generatedAt,
    required this.patientName,
    required this.chatRoomId,
  });

  @override
  _UserHealthDetailState createState() => _UserHealthDetailState();
}

class _UserHealthDetailState extends State<UserHealthDetail> {
  Map<String, dynamic>? data; // Store the user data here
  DateTime? date;
  // Fetch user data using patientId
  Future<void> fetchUserData() async {
    final DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(widget.patientId);

    try {
      final DocumentSnapshot snapshot = await userRef.get();
      if (snapshot.exists) {
        setState(() {
          data = snapshot.data() as Map<String, dynamic>;
        });
      } else {
        print('User not found');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data when the page is loaded
  }

  @override
Widget build(BuildContext context) {
  Timestamp t = widget.generatedAt; // Use the Timestamp directly
  DateTime date = t.toDate();

  if (data == null) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'History / Health Record',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Center(child: CircularProgressIndicator()), // Loading state
    );
  }

  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        'History / Health Record',
        style: TextStyle(color: Colors.black),
      ),
      centerTitle: true,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20), // Add space at the top
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            height: 500.0, // Increased height for the content area
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Record ID: ${widget.consultationId}',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text('Patient Name: ${widget.patientName}'),
                SizedBox(height: 8.0),
                Text(
                  'Date: ${DateFormat('MMMM d, y').format(date)}',
                  style: TextStyle(fontSize: 16.0, color: Colors.grey.shade600),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Content Description',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Expanded( // Allow the content area to expand
                  child: Container(
                    width: 300,
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        'Medicine Information', // Add your content here
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ),
                  ),
                ),
                 ElevatedButton(
                  onPressed: () {
                    // Navigate to the chat room history page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatHistoryPage(chatRoomId: widget.chatRoomId // Pass the chatRoomId
                      ),
                      )
                    );
                  },
                  child: Text('Chat Room History'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}