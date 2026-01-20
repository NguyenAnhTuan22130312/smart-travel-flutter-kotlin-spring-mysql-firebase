import 'dart:io';
import 'package:dio/dio.dart';

class ChatRepository {
  final Dio _dio;

  // Lưu ý: Nếu chạy trên máy ảo Android thì dùng 10.0.2.2
  // Nếu chạy trên máy thật thì phải dùng IP LAN (ví dụ: 192.168.1.x)
  // final String baseUrl = "http://10.0.2.2:8080";
  final String baseUrl = "http://27.68.111.184:8080";

  ChatRepository(this._dio);

  /// Gửi tin nhắn Text thông thường
  Future<String> sendMessage(String message) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/v1/chat',
        data: {
          "message": message
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      // Giả sử API trả về json: { "reply": "Nội dung trả lời..." }
      return response.data['reply'] ?? "Không có phản hồi";
    } catch (e) {
      throw Exception("Lỗi kết nối Chat AI: $e");
    }
  }

  /// Gửi ảnh lên server Python/Java để nhận diện
  /// Trả về Map<String, dynamic> để Bloc parse thành Model
  Future<Map<String, dynamic>> sendImageToAI(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;

      // 1. Tạo FormData (Multipart) chuẩn cho Dio
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      // 2. Gọi API
      final response = await _dio.post(
        '$baseUrl/api/v1/ai/search-image',
        data: formData,
        // Dio tự động set Content-Type là multipart/form-data khi thấy FormData
      );

      // 3. Trả về dữ liệu gốc (JSON Map)
      // Bloc sẽ dùng dữ liệu này để map sang AIDestinationResponse
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("Server trả về lỗi: ${response.statusCode}");
      }

    } catch (e) {
      print("Lỗi upload ảnh: $e");
      // Trả về Map lỗi để UI xử lý nhẹ nhàng hơn là crash app
      return {
        "success": false,
        "message": "Lỗi kết nối đến server AI: $e"
      };
    }
  }
}