import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/data/repositories/chat_repository_impl.dart';
import 'package:smart_travel/domain/entities/chat_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;

  // Danh sách tin nhắn lưu tạm trong RAM
  List<ChatMessage> _messages = [];

  ChatBloc(this.chatRepository) : super(ChatInitial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<SendImageEvent>(_onSendImage);
  }

  Future<void> _onSendImage(SendImageEvent event, Emitter<ChatState> emit) async {
    // 1. Hiển thị tin nhắn của User (Giả lập hiển thị ảnh bằng text)
    _messages.insert(0, ChatMessage(
      text: "[Đã gửi 1 hình ảnh...]",
      isUser: true,
      timestamp: DateTime.now(),
    ));
    emit(ChatLoaded(messages: List.from(_messages), isTyping: true));

    try {
      // 2. Gọi API qua Repository
      final reply = await chatRepository.sendImageToAI(event.imageFile);

      // 3. Hiển thị phản hồi từ AI
      _messages.insert(0, ChatMessage(
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      emit(ChatLoaded(messages: List.from(_messages), isTyping: false));
    } catch (e) {
      _messages.insert(0, ChatMessage(
        text: "Lỗi khi gửi ảnh: $e",
        isUser: false,
        timestamp: DateTime.now(),
      ));
      emit(ChatLoaded(messages: List.from(_messages), isTyping: false));
    }
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    // 1. Thêm tin nhắn của User vào list
    _messages.insert(0, ChatMessage(
      text: event.message,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    // 2. Emit trạng thái đang load (AI đang gõ)
    emit(ChatLoaded(messages: List.from(_messages), isTyping: true));

    try {
      // 3. Gọi API Backend
      final reply = await chatRepository.sendMessage(event.message);

      // 4. Thêm tin nhắn của AI vào list
      _messages.insert(0, ChatMessage(
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
      ));

      // 5. Emit trạng thái hoàn tất
      emit(ChatLoaded(messages: List.from(_messages), isTyping: false));
    } catch (e) {
      // Nếu lỗi, thêm tin nhắn báo lỗi
      _messages.insert(0, ChatMessage(
        text: "Xin lỗi, tôi đang gặp sự cố kết nối.",
        isUser: false,
        timestamp: DateTime.now(),
      ));
      emit(ChatLoaded(messages: List.from(_messages), isTyping: false));
    }
  }
}