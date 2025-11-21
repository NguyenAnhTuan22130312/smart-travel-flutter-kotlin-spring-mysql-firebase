import 'dart:io';
import 'package:dio/dio.dart';
import 'package:smart_travel/core/network/dio_client.dart';

class ImageUploadService {
  final DioClient _dioClient;

  ImageUploadService(this._dioClient);

  /// Upload avatar image to Cloudinary via backend
  /// Returns the secure URL of the uploaded image
  Future<String> uploadAvatar(File imageFile) async {
    try {
      // Create form data
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      // Upload to backend
      final response = await _dioClient.post(
        '/upload/avatar',
        data: formData,
      );

      // Return the URL from response
      if (response.data != null && response.data['url'] != null) {
        return response.data['url'] as String;
      } else {
        throw Exception('Invalid response from server');
      }
    } on DioException catch (e) {
      throw Exception('Failed to upload avatar: ${e.message}');
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  /// Delete avatar from Cloudinary
  Future<void> deleteAvatar(String imageUrl) async {
    try {
      await _dioClient.delete(
        '/upload/avatar?url=$imageUrl',
      );
    } on DioException catch (e) {
      throw Exception('Failed to delete avatar: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete avatar: $e');
    }
  }
}
