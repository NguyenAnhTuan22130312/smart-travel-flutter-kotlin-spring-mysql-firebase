import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/data/repositories/chat_repository_impl.dart'; // Đảm bảo import đúng repo của bạn
import 'package:smart_travel/domain/entities/chat_message.dart';
import '../../../data/models/ai/ai_destination_response.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;

  List<ChatMessage> _messages = [];

  ChatBloc(this.chatRepository) : super(ChatInitial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<SendImageEvent>(_onSendImage);
  }

  Future<void> _onSendImage(SendImageEvent event, Emitter<ChatState> emit) async {
    // 1. Hiển thị tin nhắn user
    _messages.insert(0, ChatMessage(
      text: "[Đã gửi 1 hình ảnh...]",
      isUser: true,
      timestamp: DateTime.now(),
    ));
    emit(ChatLoaded(messages: List.from(_messages), isTyping: true));

    try {
      // 2. Gọi API (Lưu ý: Repository phải trả về Map<String, dynamic>)
      final response = await chatRepository.sendImageToAI(event.imageFile);

      // 3. Xử lý kết quả trả về từ Python
      if (response['success'] == true) {
        // Parse list địa điểm
        List<dynamic> rawData = response['data'] ?? [];
        List<AIDestinationResponse> suggestions = rawData
            .map((json) => AIDestinationResponse.fromJson(json))
            .toList();

        String aiType = response['mapped_category'] ?? "Địa điểm";

        // Thêm tin nhắn AI kèm recommendations
        _messages.insert(0, ChatMessage(
          text: "AI nhận diện đây là: **$aiType**. Dưới đây là một số gợi ý phù hợp:",
          isUser: false,
          timestamp: DateTime.now(),
          recommendations: suggestions, // Gắn list vào đây
        ));
      } else {
        // Trường hợp AI không tìm thấy gì
        _messages.insert(0, ChatMessage(
          text: response['message'] ?? "AI không nhận diện được ảnh này.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      }

      emit(ChatLoaded(messages: List.from(_messages), isTyping: false));
    } catch (e) {
      _messages.insert(0, ChatMessage(
        text: "Lỗi kết nối: $e",
        isUser: false,
        timestamp: DateTime.now(),
      ));
      emit(ChatLoaded(messages: List.from(_messages), isTyping: false));
    }
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    _messages.insert(0, ChatMessage(
      text: event.message,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    emit(ChatLoaded(messages: List.from(_messages), isTyping: true));

    try {
      // Giả sử sendMessage vẫn trả về String
      final reply = await chatRepository.sendMessage(event.message);
      _messages.insert(0, ChatMessage(
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      emit(ChatLoaded(messages: List.from(_messages), isTyping: false));
    } catch (e) {
      _messages.insert(0, ChatMessage(
        text: "Xin lỗi, tôi đang gặp sự cố kết nối.",
        isUser: false,
        timestamp: DateTime.now(),
      ));
      emit(ChatLoaded(messages: List.from(_messages), isTyping: false));
    }
  }
}