import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_detail.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../data_sources/remote/invoice_remote_data_source.dart';
import '../models/invoice/invoice_model.dart';


class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceRemoteDataSource remoteDataSource;

  InvoiceRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Invoice>> getActiveInvoices() async {
    final List<InvoiceModel> models = await remoteDataSource.getActiveInvoices();
    return models.map((model) => model.toEntity()).toList();
  }
  @override
  Future<List<Invoice>> getTransactionHistory({String? type, String? status}) async {
    final models = await remoteDataSource.getTransactionHistory(type: type, status: status);
    return models.map((m) => m.toEntity()).toList();
  }
  @override
  Future<List<Invoice>> getRefundedInvoices() async {
    final models = await remoteDataSource.getRefundedInvoices();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Invoice>> getReviewableInvoices() async {
    final models = await remoteDataSource.getReviewableInvoices();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Invoice>> searchActiveInvoices({required String keyword}) async {
    final models = await remoteDataSource.searchActiveInvoices(keyword: keyword);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> cancelBooking({required int bookingId, required String reason}) async {
    await remoteDataSource.cancelBooking(bookingId: bookingId, reason: reason);
  }

  @override
  Future<InvoiceDetail> getInvoiceDetail({required int bookingId}) async {
    final model = await remoteDataSource.getInvoiceDetail(bookingId: bookingId);
    return model.toEntity();
  }
}