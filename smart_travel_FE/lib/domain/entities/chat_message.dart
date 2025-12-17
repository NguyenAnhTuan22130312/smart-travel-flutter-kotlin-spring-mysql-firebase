class ChatMessage {
  final String text;
  final bool isUser; // true: người dùng, false: AI
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}