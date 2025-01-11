import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergencyconsultation/widget/chatbox/continues_chat_room.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class ReturnedChatButton extends StatelessWidget {
ReturnedChatButton({Key? key}) : super(key: key);

final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  @override
 Widget build(BuildContext context) {
   return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Icon(Icons.chat, color: Colors.red),
            SizedBox(width: 8),
            Text(
              "Pending Chat",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chatRooms')
            .where('participants', arrayContains: currentUserId)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          print('Current User ID: $currentUserId'); // Check the current user ID
          print('Query Results: ${snapshot.data!.docs}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No records available'));
          }
          // Document data is available here
          return buildReturnedChatList(snapshot.data!.docs);
          },
      ),
    );
  }

  Widget buildReturnedChatList(List<QueryDocumentSnapshot> docs) {
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        var data = docs[index].data() as Map<String, dynamic>;
       
        print(data);
        return buildReturnedChatUI(data, context);
      },
    );
  }

  Widget buildReturnedChatUI(Map<String, dynamic> data, BuildContext context) {

    var participantName = data['participantName'] as List<dynamic>;
    Timestamp t = data['createdAt'] as Timestamp ;
    DateTime date = t.toDate();
    return Container(
      margin: EdgeInsets.all(8.0), // Margin around the container
      padding: EdgeInsets.all(16.0), // Padding inside the container
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: InkWell(
      child:
    ListTile(
        title: Text(data['participantName'][1] ?? 'Unknown Patient'),
        subtitle: Text(DateFormat('MMMM d, y').format(date)),
        leading: Icon(Icons.chat, color: Colors.red),
       onTap: () {
          print(data['chatRoomId']);
          print(data['consultationId']);
          print(data['participants']);
          // Removed BuildContext parameter
        Navigator.push(context, MaterialPageRoute(builder: (context) => (ChatRooms(
          chatRoomId: data['chatRoomId'],
          consultationId: data['consultationId'],
          participants: data['participants'],
          participantName: data['participantName'],

        ))));
         
        },
      ),
      ),
    );
  }
}

