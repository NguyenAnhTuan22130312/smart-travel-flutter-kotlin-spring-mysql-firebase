import 'package:smart_travel/core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../models/review/reviewhtd_model.dart';

abstract class ReviewHtdRemoteDataSource {
  Future<List<ReviewHtdModel>> getReviewHtd({
    required String type,
    required int serviceId,
    int? rating,
    bool? hasImage,
  });
}

class ReviewHtdRemoteDataSourceImpl implements ReviewHtdRemoteDataSource {
  final DioClient dioClient;

  ReviewHtdRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<ReviewHtdModel>> getReviewHtd({
    required String type,
    required int serviceId,
    int? rating,
    bool? hasImage,
  }) async {
    // Build URL thủ công – giống hệt InvoiceRemoteDataSourceImpl
    final StringBuffer urlBuffer = StringBuffer(ApiConstants.allReview);

    final List<String> queryParts = [];

    queryParts.add('type=$type');
    queryParts.add('serviceId=$serviceId');

    if (rating != null) {
      queryParts.add('rating=$rating');
    }

    if (hasImage != null) {
      queryParts.add('hasImage=${hasImage.toString().toLowerCase()}');
    }

    if (queryParts.isNotEmpty) {
      urlBuffer.write('?${queryParts.join('&')}');
    }

    final String url = urlBuffer.toString();

    // Gọi API bằng dioClient inject từ constructor
    final response = await dioClient.get(url);

    if (response.data['code'] == 1000) {
      final List<dynamic> list = response.data['data'];
      return list.map((json) => ReviewHtdModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception(response.data['msg'] ?? 'Load review failed');
    }
  }
}