import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:smart_travel/presentation/blocs/chat/chat_bloc.dart';
import 'package:smart_travel/presentation/blocs/chat/chat_event.dart';
import 'package:smart_travel/presentation/blocs/chat/chat_state.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';
import 'package:smart_travel/injection_container.dart' as di;
import 'package:smart_travel/domain/entities/chat_message.dart';

import '../../../data/models/ai/ai_destination_response.dart';


class AIChatScreen extends StatelessWidget {
  const AIChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<ChatBloc>(),
      child: const ChatView(),
    );
  }
}

class ChatView extends StatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    context.read<ChatBloc>().add(SendMessageEvent(_controller.text.trim()));
    _controller.clear();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        context.read<ChatBloc>().add(SendImageEvent(File(image.path)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi chọn ảnh: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Trợ lý ảo Smart Travel", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        elevation: 1,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.mainGradient)),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                List<ChatMessage> messages = [];
                bool isTyping = false;
                if (state is ChatLoaded) {
                  messages = state.messages;
                  isTyping = state.isTyping;
                }
                if (messages.isEmpty && !isTyping) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.mark_chat_unread_outlined, size: 50, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("Hỏi tôi về du lịch hoặc gửi ảnh để tìm kiếm!", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length + (isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (isTyping && index == 0) {
                      return const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    }
                    final msg = messages[isTyping ? index - 1 : index];
                    return _buildMessageBubble(msg);
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, -2))]),
            child: Row(
              children: [
                IconButton(onPressed: _pickImage, icon: const Icon(Icons.image, color: AppColors.primary), tooltip: "Gửi ảnh"),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: "Nhập câu hỏi...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), filled: true, fillColor: Colors.grey[100], contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send, color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    if (msg.recommendations == null || msg.recommendations!.isEmpty) {
      return Align(
        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: msg.isUser ? AppColors.primary : Colors.grey[200],
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(msg.isUser ? 16 : 0),
              bottomRight: Radius.circular(msg.isUser ? 0 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(msg.text, style: TextStyle(color: msg.isUser ? Colors.white : Colors.black87, fontSize: 15)),
              const SizedBox(height: 4),
              Text(DateFormat('HH:mm').format(msg.timestamp), style: TextStyle(color: msg.isUser ? Colors.white70 : Colors.black38, fontSize: 10)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bubble text
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
            child: Text(msg.text, style: const TextStyle(color: Colors.black87, fontSize: 15)),
          ),
        ),
        // List Card
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: msg.recommendations!.length,
            itemBuilder: (context, index) {
              final place = msg.recommendations![index];
              return _buildDestinationCard(place);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationCard(AIDestinationResponse place) {
    return GestureDetector(
      onTap: () {
        // TODO: Điều hướng sang trang chi tiết
        // Navigator.pushNamed(context, '/destination-detail', arguments: place.id);
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12, bottom: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                place.imageUrl ?? "https://via.placeholder.com/150",
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120, color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            ),
            // Thông tin
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: Colors.grey),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          place.provinceName ?? "Việt Nam",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        "${place.averageRating}",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(" (${place.reviewCount})", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}