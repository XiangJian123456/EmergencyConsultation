import 'package:emergencyconsultation/widget/chatbox/consultation_room.dart';
import 'package:emergencyconsultation/widget/chatbox/review_chat_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FloatingChatBubble extends StatefulWidget {
  @override
  _FloatingChatBubbleState createState() => _FloatingChatBubbleState();
}

class _FloatingChatBubbleState extends State<FloatingChatBubble>
    with SingleTickerProviderStateMixin {
  double _initialPosX = 0;
  double _posX = 0;
  double _posY = 100;
  late double _screenWidth;
  late double _screenHeight;
  final double _bubbleSize = 60.0;
  final double _expandedWidth = 300.0;  // Width when expanded
  final double _expandedHeight = 400.0; // Height when expanded
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _posX = _initialPosX;
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      left: _posX,
      top: _posY,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: _isExpanded ? _expandedWidth : _bubbleSize,
        height: _isExpanded ? _expandedHeight : _bubbleSize,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: _isExpanded ? _buildChatInterface() : _buildBubble(),
      ),
    );
  }

  Widget _buildBubble() {
    return GestureDetector(
      onTap: _toggleChat,
      onPanUpdate: _handleDrag,
      onPanEnd: _handleDragEnd,
      child: Center(
        child: Icon(
          Icons.chat,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildChatInterface() {
  return DefaultTabController(
    length: 2, // Number of tabs
    child: Column(
      children: [
        
        // Chat header with TabBar
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: TabBar(
            tabs: [
              Tab(text: 'Active Rooms'),
              Tab(text: 'Chat Count'),
            ],
          ),
        ),
        // TabBarView to switch between tabs
        Expanded(
          child: TabBarView(
            children: [
              // StreamBuilder for active chat rooms
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chatRooms')
                    .where('participants', arrayContains: userId)
                    .where('status', isNotEqualTo: 'end')
                    .orderBy('createdAt', descending: true)// Listen for chat rooms that are not ended
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator()); // Show loading indicator
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}')); // Handle errors
                  }

                  final chatRooms = snapshot.data?.docs ?? [];

                  return ListView.builder(
                    itemCount: chatRooms.length,
                    itemBuilder: (context, index) {
                      final chatRoom = chatRooms[index];
                      return ListTile(
                        title: Text('Chat Room: ${chatRoom.id}'),
                        onTap: () {
                          // Navigate to the chat room if it's not ended
                          _navigateToChatRoom(chatRoom.id);
                        },
                      );
                    },
                  );
                },
              ),
              // Display the count of active chat rooms
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chatRooms')
                    .where('participants', arrayContains: userId)
                    .where('status', isEqualTo: 'completed') // Listen for chat rooms that are not ended
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator()); // Show loading indicator
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}')); // Handle errors
                  }

                  final chatRooms = snapshot.data?.docs ?? [];
                  final activeCount = chatRooms.length;

                   return ListView.builder(
                    itemCount: chatRooms.length,
                    itemBuilder: (context, index) {
                      final chatRoom = chatRooms[index];
                      return ListTile(
                        title: Text('Chat Room: ${chatRoom.id}'),
                        onTap: () {
                          // Navigate to the chat room if it's not ended
                          _navigateToChatRoom(chatRoom.id);
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        // Chat input
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send, size: 20),
                onPressed: () {
                  // Handle sending message
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  void _toggleChat() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        // Adjust position based on current position
        if (_posX < _screenWidth / 2) {
          // If bubble is on the left side, expand to the right
          _posX = 0; // Keep it at the left edge
        } else {
          // If bubble is on the right side, expand to the left
          _posX = _screenWidth - _expandedWidth; // Align to the right edge
        }
      } else {
        // Close the chat bubble
        _closeChat();
      }
    });
}

// New method to handle closing the chat bubble
void _closeChat() {
    setState(() {
      _isExpanded = false; // Set to collapsed state
      _posX = _initialPosX; // Reset position to initial state
    });
}

  void _handleDrag(DragUpdateDetails details) {
    if (!_isExpanded) {
      setState(() {
        _posX += details.delta.dx;
        _posY += details.delta.dy;

        // Constrain the bubble to stay within screen bounds
        _posX = _posX.clamp(0, _screenWidth - (_isExpanded ? _expandedWidth : _bubbleSize));
        _posY = _posY.clamp(0, _screenHeight - (_isExpanded ? _expandedHeight : _bubbleSize));
      });
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isExpanded) {
      setState(() {
        if (_posX < _screenWidth / 2) {
          _posX = 0;
        } else {
          _posX = _screenWidth - (_isExpanded ? _expandedWidth : _bubbleSize);
        }
      });
    }
  }

  void _navigateToChatRoom(String chatRoomId) async {
  try {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Fetch room info based on chatRoomId and current user ID
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final roomInfoSnapshot = await _firestore.collection('chatRooms')
        .where('participants', arrayContains: currentUserId) // Check if current user is a participant
        .where('status', isNotEqualTo: 'completed')
        .get();

    if (roomInfoSnapshot.docs.isNotEmpty) {
      final roomInfo = roomInfoSnapshot.docs.first.data();

      // Hide loading indicator
      Navigator.pop(context);

      // Navigate to chat room
      final consultationDoc = await _firestore.collection('consultations').doc(roomInfo['consultationId']).get();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatRoom2(
            chatRoomId: roomInfo['chatRoomId']!,
            consultationId: roomInfo['consultationId']!,
            participants: consultationDoc.data() as Map<String, dynamic>,
            
          ),
        ),
      );
    } else {
      // Hide loading indicator
      Navigator.pop(context);
      // Show message if no active chat room found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No active chat room found.')),
      );
    }
  } catch (e) {
    // Hide loading indicator
    Navigator.pop(context);
    
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}