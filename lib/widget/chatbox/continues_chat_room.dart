
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:emergencyconsultation/main.dart';
import 'package:emergencyconsultation/notification/notification_service.dart';
import 'package:emergencyconsultation/pages/doctor/doc_mainpages.dart';
import 'package:emergencyconsultation/pages/user/user_mainpage.dart';
import 'package:emergencyconsultation/widget/chatbox/camera_preivew.dart';
import 'package:emergencyconsultation/widget/successfull.widget.dart';
import 'package:emergencyconsultation/widget/user_success.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


import '../successfull_user.dart';
import 'doc_prescribe_medicine.dart';

class ChatRooms extends StatefulWidget {
  final String chatRoomId;
  final String consultationId;
  final List<dynamic> participants;
  final List<dynamic> participantName;
  const ChatRooms({
    super.key,
    required this.chatRoomId,
    required this.consultationId,
    required this.participantName,
    required this.participants,
  });

  @override
  _ChatRoomsState createState() => _ChatRoomsState();
}

class _ChatRoomsState extends State<ChatRooms> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isConsultationEnded = false;
  File? _image;
  File? _file;
  final TextEditingController _captionController = TextEditingController();
  List<CameraDescription>? cameras;
  CameraController? _cameraController;
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
  }
  Future<void> showExitConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Exit'),
          content: Text('Are you sure you want to quit the consultation?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Return false
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Return true
              child: Text('Yes'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      // Perform the action to exit
      Navigator.of(context).pop(); // Pop the current page
    }
  }
  // Audio
  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio, // Restrict to audio files only
    );

    if (result != null) {
      // Get the file path
      String? filePath = result.files.single.path;

      if (filePath != null) {
        print("Picked audio file: $filePath");
        // Do something with the picked file
      }
    } else {
      print("No file selected");
    }
  }
  Future<void> downloadFile(String fileUrl) async {
    try {
      // Reference to the file in Firebase Storage
      final storageRef = FirebaseStorage.instance.refFromURL(fileUrl);

      // Define the local file path

      Directory? downloadsDir = await getExternalStorageDirectory();
      String downloadsPath = downloadsDir!.path;
      final file = File("$downloadsPath/${fileUrl.split('/').last}");

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
            // Open the downloaded file
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
      print("File downloaded to: $downloadsPath");
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
  // Image Holder 
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_image == null) return null;

    String fileName = _image!.path.split('/').last; // Get the file name
    Reference storageRef = FirebaseStorage.instance.ref().child('uploads/${widget.consultationId}/${widget.participants[0]}/$fileName');

    try {
      await storageRef.putFile(_image!); // Upload the image
      String downloadUrl = await storageRef.getDownloadURL(); // Get the download URL
      return downloadUrl; // Return the URL
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void _clearImage() {
    setState(() {
      _image = null;
      _captionController.clear();
    });
  }
  void _clearFile(){
    setState(() {
      _file = null;
      _captionController.clear();
    });
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _file = File(result.files.single.path!); // Store the selected file
      });
    }
  }

  Future<String?> _uploadFile() async {
    if (_file == null) return null;

    String fileName = _file!.path.split('/').last; // Get the file name
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('uploads/${widget.consultationId}/${widget.participants[0]}/$fileName');

    try {
      await storageRef.putFile(_file!); // Upload the file
      String downloadUrl = await storageRef.getDownloadURL(); // Get the download URL
      return downloadUrl; // Return the URL
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  // End Consultation
  void endConsultation(String consultationId, BuildContext context) async {
    try {
      setState(() {
        _isConsultationEnded = true;
      });
      // Step 1: Update the consultation status in Firestore
      await _firestore.collection('consultations').doc(consultationId).update({
        'status': 'ended',
        'endedAt': FieldValue.serverTimestamp(),
      });
      await _firestore.collection('consultations').doc(consultationId).update({
        'user_chat_status': 'ended',
      });
      await _firestore.collection('chatRooms').doc(widget.chatRoomId).update({
        'status': 'completed',
      });
      // Step 2: Generate the consultation record
      await _generateConsultationRecord(consultationId);
      // Step 3: Notify the user and navigate
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Consultation has ended.')),
      );
      _navigateToSuccessPage();
    } catch (e) {
      // Step 4: Error handling
      print('Error ending consultation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to end consultation. Please try again.')),
      );
    }
  }

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

  Future<void> _generateConsultationRecord(String consultationId) async {
    try {
      // Implement your logic to generate a consultation record here
      print('Generating consultation record...');

      await _firestore.collection('consultationRecords').add({
        'consultationId': consultationId,
        'doctorId': widget.participants[1],
        'patientId': widget.participants[2],
        'patientName': widget.participantName[0],
        'doctorName': widget.participantName[1],
        'chatRoomId': widget.chatRoomId,
        'consultation_id': widget.consultationId,
        'generatedAt': FieldValue.serverTimestamp(),
        // Add more fields as necessary
      });
      print('Consultation record generated successfully.');
    } catch (e) {
      print('Error generating consultation record: $e');
    }
  }

  void _navigateToSuccessPage() {
    final isUser = widget.participants[0] == _auth.currentUser?.uid;
    final isDoctor = widget.participants[1] == _auth.currentUser?.uid;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ConsultationCompletedWidget(isUser: isUser, isDoctor: isDoctor),
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty && _image == null && _file == null) {
      return; // Do nothing if all are empty
    }

    String? imageUrl;
    String? fileUrl;
    String? fileName;

    try {
      // Upload file and image if available
      if (_file != null) {
        fileUrl = await _uploadFile();
        fileName = _file!.path.split('/').last; 
      }
      if (_image != null) {
        imageUrl = await _uploadImage();
      }

      // Check if chat room exists and the user is a participant
      final chatRoom = await _firestore.collection('chatRooms').doc(widget.chatRoomId).get();
      if (!chatRoom.exists || !(chatRoom['participants'] as List).contains(_auth.currentUser?.uid)) {
        print('You are not a participant in this chat room.');
        return;
      }

      // Prepare message data
      Map<String, dynamic> messageData = {
        'fileName': fileName,
        'fileUrl': fileUrl,
        'chatRoomId': chatRoom.id,
        'senderId': _auth.currentUser?.uid,
        'message': _messageController.text.trim(),
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Save message to Firestore
      await _firestore
          .collection('chatRooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .add(messageData);

      // Update last message in chat room
      await _firestore.collection('chatRooms').doc(widget.chatRoomId).update({
        'lastMessage': _messageController.text.isNotEmpty ? _messageController.text : "File/Photo",
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
      _clearFile();
      _clearImage(); // Clear image and file selection
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chatRooms')
          .doc(widget.chatRoomId)
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
        print('Number of messages: ${snapshot.data!.docs.length}');
        return ListView.builder(
          reverse: true,
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var messageData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            bool isUser = messageData['senderId'] == _auth.currentUser?.uid;
            print('Message from ${messageData['senderId']}: ${messageData['message']}');
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
                child: Column( // Use Column to stack text and image
                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      messageData['message'] ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                    // Check if there's an image URL and display the image
                    if (messageData['imageUrl'] != null && messageData['imageUrl'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Image.network(
                          messageData['imageUrl'],
                          width: 200, // Set a width for the image
                          height: 200, // Set a height for the image
                          fit: BoxFit.cover, // Adjust the image fit
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
                                  messageData['fileName'] ?? messageData['fileUrl'].split('/').last, // Display file name
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 15,
                                  ),
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

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(Icons.insert_drive_file, "Document"),
                  _buildAttachmentOption(Icons.camera_alt, "Camera"),
                  _buildAttachmentOption(Icons.photo, "Gallery"),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(Icons.audiotrack, "Audio"),
                  _buildAttachmentOption(Icons.location_on, "Location"),
                  _buildAttachmentOption(Icons.person, "Contact"),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        if (label == "Document") { // Check if the user selected the Document option
          await _pickFile(); // Call the function to pick and upload the file
        }
        if (label == "Gallery") {
          await _pickImage();
        }
        if (label == "Camera") {
          // Check camera permission
          if (await Permission.camera.request().isGranted) {
            // Get available cameras
            final cameras = await availableCameras();
            // Navigate to the camera screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CameraScreen(camera: cameras[0]),
              ),
            ).then((imagePath) {
              if (imagePath != null) {
                setState(() {
                  _image = File(imagePath); // Set the captured image
                });
              }
            });
          } else {
            print("Camera permission denied");
          }
        }
        if (label == "Audio") {
          await _pickAudio();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.red, size: 25),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of the camera controller when not in use
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? userId = widget.participants[0];
    String? doctorId = widget.participants[1];
    bool isDoctor = _auth.currentUser?.uid == doctorId;
    bool isUser = _auth.currentUser?.uid == userId;
    String doctorName = widget.participantName[1] ?? 'Doctor';
    String userName = widget.participantName[0] ?? 'Patient';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              showExitConfirmationDialog(context);
            },
          ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.red.shade50,
              child: Icon(Icons.person, color: Colors.red),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDoctor ? userName : doctorName,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('consultations').doc(widget.consultationId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          // Check the consultation status
          var consultationData = snapshot.data!.data() as Map<String, dynamic>;
          _isConsultationEnded = consultationData['status'] == 'ended'; // Update the consultation status

          return Column(
            children: [
              // Chat Messages
              Expanded(
                child: _buildMessageList(),
              ),
              if (_image != null || _file != null) // Check if either an image or a file is present
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Display the image if it exists
                      if (_image != null)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white, // Background color of the container
                            borderRadius: BorderRadius.circular(8), // Rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2), // Shadow color
                                spreadRadius: 2, // Spread radius of the shadow
                                blurRadius: 5, // Blur radius of the shadow
                                offset: Offset(0, 3), // Offset of the shadow
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(8), // Padding inside the container
                          child: Stack(
                            children: [
                              Image.file(
                                _image!,
                                width: 200, // Set a width for the image
                                height: 200, // Set a height for the image
                                fit: BoxFit.cover, // Adjust the image fit
                              ),
                              Positioned(
                                right: 8, // Position the button 8 pixels from the right
                                top: 8, // Position the button 8 pixels from the top
                                child: IconButton(
                                  icon: Icon(Icons.close, color: Colors.red), // Close icon
                                  onPressed: () {
                                    setState(() {
                                      _image = null; // Clear the selected image
                                    });
                                  },
                                  tooltip: 'Remove image', // Tooltip for better UX
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Display the file link if it exists
                      if (_file != null) // Check if a file is selected
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                _getFileIcon(_file!.path), // Get the appropriate icon
                                size: 40, // Set the icon size
                                color: Colors.blue, // Set the icon color
                              ),
                              SizedBox(width: 8), // Space between icon and text
                              Expanded(
                                child: Text(
                                  _file!.path.split('/').last, // Display the file name
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red), // Cross icon
                                onPressed: () {
                                  setState(() {
                                    _file = null; // Clear the selected file
                                  });
                                },
                              ),
                              // Optional: Add a download button or link
                              GestureDetector(
                                onTap: () {
                                  downloadFile(_file!.path);
                                },
                                child: Text(
                                  'Open',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 15,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // TextField for message input
                      TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              // Action Buttons
              if (!_isConsultationEnded && isDoctor)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.close),
                          label: Text("End Consultation"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => endConsultation(widget.consultationId, context),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.medical_services),
                          label: Text("Prescribe Medicine"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            print(widget.participantName[0]);
                            print(widget.participants);
                            if (widget.participantName[0] != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PatientMedicalInformationScreen(
                                   userName: widget.participantName[0],
                                   

                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Patient data is not available.')),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              // Consultation Ended Message
              if (_isConsultationEnded)
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.red.shade50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            "Consultation has ended",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>  UserConsultationCompletedWidget() // Replace with your target screen
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red, // Button background color
                        ),
                        child: Text("Okay"),
                      ),
                    ],
                  ),
                ),

              // Message Input
              if (!_isConsultationEnded)
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, -1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.attach_file, color: Colors.grey),
                        onPressed: _showAttachmentOptions,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: "Type a message...",
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.red,
                        child: IconButton(
                          icon: Icon(Icons.send, color: Colors.white, size: 20),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}