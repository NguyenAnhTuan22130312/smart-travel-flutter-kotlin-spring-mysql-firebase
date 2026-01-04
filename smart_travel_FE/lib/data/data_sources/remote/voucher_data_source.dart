import 'package:dio/dio.dart';
import 'package:smart_travel/core/constants/api_constants.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/core/network/dio_client.dart';
import 'package:smart_travel/data/models/voucher/voucher_create_request.dart';
import 'package:smart_travel/data/models/voucher/voucher_response_model.dart';
import 'package:smart_travel/data/models/voucher/voucher_update_request.dart';

abstract class VoucherDataSource {
  Future<List<VoucherResponseModel>> getAllVoucher();
  Future<VoucherResponseModel> createVoucher(VoucherCreateRequest request);
  Future<VoucherResponseModel> updateVoucher(VoucherUpdateRequest request);
  Future<void> deleteVoucher(int id);
}

class VoucherDataSourceImpl extends VoucherDataSource {
  final DioClient dioClient;

  VoucherDataSourceImpl({required this.dioClient});

  @override
  Future<List<VoucherResponseModel>> getAllVoucher() async {
    try {
      final response = await dioClient.get(ApiConstants.getAllVoucher);

      // Backend trả về List<Voucher> -> JSON Array [...]
      // Ta ép kiểu trực tiếp sang List và map từng phần tử
      final listData = response.data as List;

      return listData
          .map((e) => VoucherResponseModel.fromJson(e as Map<String, dynamic>))
          .toList();

    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error as ServerException;
      throw ServerException(e.message ?? 'Lỗi kết nối khi lấy danh sách Voucher');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<VoucherResponseModel> createVoucher(VoucherCreateRequest request) async {
    try {
      final response = await dioClient.post(
        ApiConstants.createVoucher,
        data: request.toJson(),
      );

      // Backend trả về Voucher object -> JSON Object {...}
      // Map trực tiếp response.data vào Model
      return VoucherResponseModel.fromJson(response.data as Map<String, dynamic>);

    } on DioException catch (e) {
      // Nếu Backend có trả về message lỗi (VD: Mã đã tồn tại), nó thường nằm trong e.response
      if (e.response != null && e.response!.data != null) {
        // Tùy cấu trúc lỗi Backend trả về mà handle, ví dụ:
        // throw ServerException(e.response!.data['message']);
      }
      throw ServerException('Lỗi khi tạo Voucher: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<VoucherResponseModel> updateVoucher(VoucherUpdateRequest request) async {
    try {
      final response = await dioClient.put(
        '${ApiConstants.updateVoucher}${request.id}',
        data: request.toJson(),
      );

      // Tương tự create, Backend trả về Object {...}
      return VoucherResponseModel.fromJson(response.data as Map<String, dynamic>);

    } on DioException catch (e) {
      throw ServerException('Lỗi khi cập nhật Voucher: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteVoucher(int id) async {
    try {
      // Hàm delete trả về void, chỉ cần await
      await dioClient.delete('${ApiConstants.deleteVoucher}$id');
    } on DioException catch (e) {
      throw ServerException('Lỗi khi xóa Voucher: ${e.message}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}