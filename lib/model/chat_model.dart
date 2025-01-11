class ChatMessage {
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final String senderName;
  final String messageType; // 'text', 'image', etc.

  ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    required this.senderName,
    this.messageType = 'text',
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'senderName': senderName,
      'messageType': messageType,
    };
  }
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      message: map['message'],
      timestamp: DateTime.parse(map['timestamp']),
      senderName: map['senderName'],
      messageType: map['messageType'],
    );
  }
}