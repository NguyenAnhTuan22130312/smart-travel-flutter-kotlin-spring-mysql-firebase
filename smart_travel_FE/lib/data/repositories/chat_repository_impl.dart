import 'package:dio/dio.dart';

class ChatRepository {
  final Dio _dio;

  ChatRepository(this._dio);

  Future<String> sendMessage(String message) async {
    try {
      final response = await _dio.post(
        '/api/v1/chat', // Đảm bảo đúng endpoint

        // --- SỬA ĐOẠN NÀY ---
        // SAI: data: message (Sẽ gửi text/plain)
        // ĐÚNG: data: {"message": message} (Sẽ gửi application/json)
        data: {
          "message": message
        },
        // --------------------

        options: Options(
          headers: {
            'Content-Type': 'application/json', // Ép buộc gửi JSON
            'Accept': 'application/json',
          },
        ),
      );

      // Backend trả về: {"reply": "..."}
      return response.data['reply'];
    } catch (e) {
      throw Exception("Lỗi kết nối AI: $e");
    }
  }
}