import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/domain/entities/chat_message.dart';
import '../../../data/models/ai/ai_destination_response.dart';
import '../../../data/repositories/chat_repository_impl.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  List<ChatMessage> _messages = [];

  ChatBloc(this.chatRepository) : super(ChatInitial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<SendImageEvent>(_onSendImage);
  }

  // --- 1. XỬ LÝ GỬI ẢNH (Code bạn đã ổn, chỉ chỉnh lại chút cho gọn) ---
  Future<void> _onSendImage(SendImageEvent event, Emitter<ChatState> emit) async {
    _messages.insert(0, ChatMessage(
      text: "[Đã gửi 1 hình ảnh...]",
      isUser: true,
      timestamp: DateTime.now(),
    ));
    emit(ChatLoaded(messages: List.from(_messages), isTyping: true));

    try {
      final response = await chatRepository.sendImageToAI(event.imageFile);

      if (response['success'] == true) {
        // Parse list
        List<dynamic> rawData = response['data'] ?? [];
        List<AIDestinationResponse> suggestions = rawData
            .map((json) => AIDestinationResponse.fromJson(json))
            .toList();

        String aiType = response['mapped_category'] ?? "Địa điểm";

        _messages.insert(0, ChatMessage(
          text: "AI nhận diện: **$aiType**. Gợi ý cho bạn:",
          isUser: false,
          timestamp: DateTime.now(),
          recommendations: suggestions, // <--- LIST CARD TỪ ẢNH
        ));
      } else {
        _messages.insert(0, ChatMessage(
          text: response['message'] ?? "Không nhận diện được.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      }
      emit(ChatLoaded(messages: List.from(_messages), isTyping: false));
    } catch (e) {
      _handleError(e, emit);
    }
  }

  // --- 2. XỬ LÝ CHAT TEXT (SỬA LẠI HOÀN TOÀN) ---
  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    // UI: Hiện tin nhắn user
    _messages.insert(0, ChatMessage(
      text: event.message,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    emit(ChatLoaded(messages: List.from(_messages), isTyping: true));

    try {
      // Gọi API (Trả về Map chứa message + list)
      final responseData = await chatRepository.sendMessage(event.message);

      String replyText = responseData['message'] ?? "Không có nội dung";
      List<dynamic> rawRecs = responseData['recommendations'] ?? [];

      // Parse List DTO
      List<AIDestinationResponse> suggestions = rawRecs
          .map((json) => AIDestinationResponse.fromJson(json))
          .toList();

      // UI: Hiện tin nhắn AI kèm List Cards (nếu có)
      _messages.insert(0, ChatMessage(
        text: replyText,
        isUser: false,
        timestamp: DateTime.now(),
        recommendations: suggestions, // <--- LIST CARD TỪ TEXT CHAT
      ));

      emit(ChatLoaded(messages: List.from(_messages), isTyping: false));
    } catch (e) {
      _handleError(e, emit);
    }
  }

  void _handleError(dynamic e, Emitter<ChatState> emit) {
    _messages.insert(0, ChatMessage(
      text: "Lỗi kết nối: $e",
      isUser: false,
      timestamp: DateTime.now(),
    ));
    emit(ChatLoaded(messages: List.from(_messages), isTyping: false));
  }
}