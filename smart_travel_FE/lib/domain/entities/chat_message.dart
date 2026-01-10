import '../../data/models/ai/ai_destination_response.dart'; // Nhớ import file vừa tạo

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  final List<AIDestinationResponse>? recommendations;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.recommendations,
  });
}