import 'package:smart_travel/core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../models/invoice/invoice_detail_model.dart';
import '../../models/invoice/invoice_model.dart';

abstract class InvoiceRemoteDataSource {
  Future<List<InvoiceModel>> getActiveInvoices();
  Future<List<InvoiceModel>> getTransactionHistory({String? type, String? status});
  Future<List<InvoiceModel>> getRefundedInvoices();
  Future<List<InvoiceModel>> getReviewableInvoices();
  Future<List<InvoiceModel>> searchActiveInvoices({required String keyword});
  Future<void> cancelBooking({required int bookingId, required String reason});
  Future<InvoiceDetailModel> getInvoiceDetail({required int bookingId});
}

class InvoiceRemoteDataSourceImpl implements InvoiceRemoteDataSource {
  final DioClient dioClient;

  InvoiceRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<InvoiceModel>> getActiveInvoices() async {
    final response = await dioClient.get(ApiConstants.invoiceActive);

    if (response.data['code'] == 1000) {
      final List<dynamic> dataList = response.data['data'];
      return dataList.map((json) => InvoiceModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception(response.data['msg'] ?? 'Failed to load active invoices');
    }
  }
  @override
  Future<List<InvoiceModel>> getTransactionHistory({String? type, String? status}) async {
    // Xây dựng URL với query string thủ công
    final StringBuffer urlBuffer = StringBuffer(ApiConstants.invoiceHistory);

    final List<String> queryParts = [];

    // Type: luôn có, mặc định 'all'
    final String finalType = (type != null && type.isNotEmpty && type != 'all') ? type : 'all';
    queryParts.add('type=$finalType');

    // Status: chỉ thêm nếu có
    if (status != null && status.isNotEmpty) {
      queryParts.add('status=$status');
    }

    if (queryParts.isNotEmpty) {
      urlBuffer.write('?${queryParts.join('&')}');
    }

    final String url = urlBuffer.toString();
    print('Calling API: $url'); // ← Thêm dòng này trước response
    final response = await dioClient.get(url);

    if (response.data['code'] == 1000) {
      final List<dynamic> dataList = response.data['data'];
      return dataList.map((json) => InvoiceModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception(response.data['msg'] ?? 'Failed to load transaction history');
    }
  }

  @override
  Future<List<InvoiceModel>> getRefundedInvoices() async {
    final response = await dioClient.get(ApiConstants.invoiceRefunded);

    if (response.data['code'] == 1000) {
      final List<dynamic> dataList = response.data['data'];
      return dataList.map((json) => InvoiceModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception(response.data['msg'] ?? 'Failed to load refunded invoices');
    }
  }

  @override
  Future<List<InvoiceModel>> getReviewableInvoices() async {
    final response = await dioClient.get(ApiConstants.invoiceReviewable);

    if (response.data['code'] == 1000) {
      final List<dynamic> dataList = response.data['data'];
      return dataList.map((json) => InvoiceModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception(response.data['msg'] ?? 'Failed to load reviewable invoices');
    }
  }

  @override
  Future<List<InvoiceModel>> searchActiveInvoices({required String keyword}) async {
    final String url = keyword.isEmpty
        ? ApiConstants.invoiceActiveSearch // hoặc dùng cùng endpoint, backend xử lý keyword trống
        : '${ApiConstants.invoiceActiveSearch}?keyword=${Uri.encodeComponent(keyword)}';

    final response = await dioClient.get(url);

    if (response.data['code'] == 1000) {
      final List<dynamic> dataList = response.data['data'];
      return dataList.map((json) => InvoiceModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception(response.data['msg'] ?? 'Failed to search invoices');
    }
  }

  @override
  Future<void> cancelBooking({required int bookingId, required String reason}) async {
    final response = await dioClient.post(
      ApiConstants.invoiceRefund,
      data: {
        "bookingId": bookingId,
        "reason": reason,
      },
    );

    if (response.data['code'] != 1000) {
      throw Exception(response.data['msg'] ?? 'Hủy đặt chỗ thất bại');
    }
  }

  @override
  Future<InvoiceDetailModel> getInvoiceDetail({required int bookingId}) async {
    final response = await dioClient.get('${ApiConstants.invoiceDetail}$bookingId');

    print('API Detail Response: ${response.data}');

    if (response.data['code'] == 1000) {
      return InvoiceDetailModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['msg'] ?? 'Failed to load invoice detail');
    }
  }
}