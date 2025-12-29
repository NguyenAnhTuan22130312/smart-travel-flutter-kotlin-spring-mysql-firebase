import 'package:dio/dio.dart';
import 'package:smart_travel/core/constants/api_constants.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/core/network/dio_client.dart';
import 'package:smart_travel/data/models/api_response_model.dart';
import 'package:smart_travel/data/models/banner/banner_create_request.dart';
import 'package:smart_travel/data/models/banner/banner_response_model.dart';
import 'package:smart_travel/data/models/banner/banner_update_request.dart';

abstract class BannerDataSource {
  ///Load all banner
  Future<List<BannerResponseModel>> getAllBanner();
  // Thêm mới banner
  Future<BannerResponseModel> addBanner(BannerCreateRequest params);

  // Cập nhật banner
  Future<BannerResponseModel> updateBanner(BannerUpdateRequest params);

  // Xóa banner
  Future<void> deleteBanner(int id);
}
class BannerDataSourceImpl extends BannerDataSource{
  final DioClient dioClient;

  BannerDataSourceImpl({required this.dioClient});

  @override
  Future<List<BannerResponseModel>> getAllBanner() async{
    try {
      final response = await dioClient.get(ApiConstants.getAllBanner);
      final apiResponse = ApiResponseModel<List<BannerResponseModel>>.fromJson(
          response.data,
              (data) =>
              (data as List)
                  .map((e) => BannerResponseModel.fromJson(e))
                  .toList()
      );

      return apiResponse.data!;
    }on DioException catch(e){
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(e.message ?? 'Lỗi khi lấy danh sách banner');
    }catch (e){
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Lỗi không mong muốn: ${e.toString()}');
    }
  }

  @override
  Future<BannerResponseModel> addBanner(BannerCreateRequest params) async {
    try {
      final response = await dioClient.post(
        ApiConstants.createBanner,
        data: params.toJson(),
      );

      final apiResponse = ApiResponseModel<BannerResponseModel>.fromJson(
        response.data,
            (data) => BannerResponseModel.fromJson(data as Map<String, dynamic>),
      );

      return apiResponse.data!;
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error as ServerException;
      throw ServerException(e.message ?? 'Lỗi khi thêm banner');
    } catch (e) {
      throw ServerException('Lỗi không mong muốn: ${e.toString()}');
    }
  }

  @override
  Future<BannerResponseModel> updateBanner(BannerUpdateRequest params) async {
    try {
      final response = await dioClient.put(
        '${ApiConstants.updateBanner}/${params.id}',
        data: params.toJson(),
      );

      final apiResponse = ApiResponseModel<BannerResponseModel>.fromJson(
        response.data,
            (data) => BannerResponseModel.fromJson(data as Map<String, dynamic>),
      );

      return apiResponse.data!;
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error as ServerException;
      throw ServerException(e.message ?? 'Lỗi khi cập nhật banner');
    } catch (e) {
      throw ServerException('Lỗi không mong muốn: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteBanner(int id) async {
    try {
      await dioClient.delete(
        '${ApiConstants.deleteBanner}$id',
      );
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error as ServerException;
      throw ServerException(e.message ?? 'Lỗi khi xóa banner');
    } catch (e) {
      throw ServerException('Lỗi không mong muốn: ${e.toString()}');
    }
  }


}