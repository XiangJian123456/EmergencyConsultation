import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:emergencyconsultation/widget/chatbox/consultation_room.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../notification/notification_service.dart';
class ChatHistoryPage extends StatelessWidget {
  final String chatRoomId;

  const ChatHistoryPage({Key? key, required this.chatRoomId}) : super(key: key);



  IconData _getFileIcon(String filePath) {
    String extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf; // PDF icon
      case 'doc':
      case 'docx':
        return Icons.description; // Word document icon
      case 'xls':
      case 'xlsx':
        return Icons.table_chart; // Excel document icon
      case 'txt':
        return Icons.text_fields; // Text file icon
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image; // Image icon
      default:
        return Icons.insert_drive_file; // Default file icon
    }
  }
  Future<void> downloadFile(String fileUrl) async {
    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        print("Storage permission denied");
        return;
      }

      // Reference to the file in Firebase Storage
      final storageRef = FirebaseStorage.instance.refFromURL(fileUrl);

      // Get the Downloads directory path
      final Directory downloadsDir = Directory('/storage/emulated/0/Download');
      if (!downloadsDir.existsSync()) {
        downloadsDir.createSync();
      }

      final filePath = "${downloadsDir.path}/${fileUrl.split('/').last}";
      final file = File(filePath);

      // Start the download task
      final downloadTask = storageRef.writeToFile(file);

      // Listen to snapshot events
      downloadTask.snapshotEvents.listen((taskSnapshot) {
        switch (taskSnapshot.state) {
          case TaskState.running:
            double progress = (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes) * 100;
            print("Download is $progress% complete.");
            break;
          case TaskState.success:
            print("Download completed successfully!");
            NotificationService.instance.showDownloadCompleteNotification(file.path);
            _openDownloadedFile(file);
            break;
          case TaskState.error:
            print("Error occurred during download.");
            break;
          default:
            break;
        }
      });

      // Wait for the task to complete
      await downloadTask;
      print("File downloaded to: $filePath");
    } catch (e) {
      print("Error downloading file: $e");
    }
  }
  void _openDownloadedFile(File file) async {
    if (await file.exists()) {
      // Use the open_file package to open the file
      OpenFile.open(file.path);
    } else {
      print("File does not exist.");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat History'),
      ),
      body: _buildMessageList(),
    );
  }

  Widget _buildMessageList() {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          reverse: true,
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var messageData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            bool isUser = messageData['senderId'] == _auth.currentUser?.uid;

            return Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(
                  bottom: 12,
                  left: isUser ? 50 : 0,
                  right: isUser ? 0 : 50,
                ),
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isUser ? Colors.red : Colors.white,
                  borderRadius: BorderRadius.circular(20).copyWith(
                    bottomRight: isUser ? Radius.circular(0) : Radius.circular(20),
                    bottomLeft: isUser ? Radius.circular(20) : Radius.circular(0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      messageData['message'] ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                    if (messageData['imageUrl'] != null && messageData['imageUrl'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Image.network(
                          messageData['imageUrl'],
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    if (messageData['fileUrl'] != null && messageData['fileUrl'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: GestureDetector(
                          onTap: () async {
                            final String fileUrl = messageData['fileUrl'];
                            try {
                              await downloadFile(fileUrl);
                              print("Download initiated for file: ${messageData['fileUrl']}");
                            } catch (e) {
                              print("Error initiating download: $e");
                            }
                            // Implement your download logic here
                            print("Download file: $fileUrl");
                          },
                          child: Row(
                            children: [
                              Icon(
                                _getFileIcon(messageData['fileUrl']),
                                color: Colors.blue,
                              ),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  messageData['fileName'] ?? messageData['fileUrl'].split('/').last,
                                  style: TextStyle(color: Colors.blue, fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}