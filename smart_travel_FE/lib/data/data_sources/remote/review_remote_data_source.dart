import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';

abstract class ReviewRemoteDataSource {
  Future<void> submitReview({
    required int rating,
    String? comment,
    required String invoiceNumber,
    required List<XFile> images
  });
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final DioClient dioClient;

  ReviewRemoteDataSourceImpl(this.dioClient);

  @override
  Future<void> submitReview({
    required int rating,
    String? comment,
    required String invoiceNumber,
    required List<XFile> images
  }) async {
    final String endpoint = ApiConstants.invoiceReview;

    FormData formData = FormData.fromMap({
      "rating": rating,
      if (comment != null && comment.isNotEmpty) "comment": comment,
      "invoiceNumber": invoiceNumber,
    });

    for (var image in images) {
      formData.files.add(MapEntry(
        "images",
        await MultipartFile.fromFile(image.path, filename: image.name),
      ));
    }

    final response = await dioClient.post(endpoint, data: formData);

    if (response.data['code'] != 1000) {
      throw Exception(response.data['msg'] ?? 'Gửi đánh giá thất bại');
    }
  }

}