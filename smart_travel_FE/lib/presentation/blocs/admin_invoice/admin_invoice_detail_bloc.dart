import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/admin_invoice_detail.dart';
import '../../../domain/usecases/invoice/get_admin_invoice_detail_usecase.dart';

abstract class AdminInvoiceDetailEvent {}

class LoadAdminInvoiceDetail extends AdminInvoiceDetailEvent {
  final int bookingId;

  LoadAdminInvoiceDetail(this.bookingId);
}

abstract class AdminInvoiceDetailState {}

class AdminInvoiceDetailInitial extends AdminInvoiceDetailState {}

class AdminInvoiceDetailLoading extends AdminInvoiceDetailState {}

class AdminInvoiceDetailLoaded extends AdminInvoiceDetailState {
  final AdminInvoiceDetail detail;
  AdminInvoiceDetailLoaded(this.detail);
}

class AdminInvoiceDetailError extends AdminInvoiceDetailState {
  final String message;
  AdminInvoiceDetailError(this.message);
}

class AdminInvoiceDetailBloc extends Bloc<AdminInvoiceDetailEvent, AdminInvoiceDetailState> {
  final GetAdminInvoiceDetailUseCase getDetailUseCase;

  AdminInvoiceDetailBloc(this.getDetailUseCase) : super(AdminInvoiceDetailInitial()) {
    on<LoadAdminInvoiceDetail>((event, emit) async {
      emit(AdminInvoiceDetailLoading());
      try {
        final detail = await getDetailUseCase(bookingId: event.bookingId);
        emit(AdminInvoiceDetailLoaded(detail));
      } catch (e) {
        String errorMsg = "Không tải được chi tiết đơn hàng";

        // Xử lý lỗi từ API cụ thể
        if (e.toString().contains("code") || e.toString().contains("msg")) {
          errorMsg = "Đơn hàng này không thuộc quyền quản lý của bạn";
        } else if (e.toString().contains("404") || e.toString().contains("not found")) {
          errorMsg = "Không tìm thấy đơn hàng";
        } else {
          errorMsg = e.toString().replaceAll("Exception: ", "");
        }

        emit(AdminInvoiceDetailError(errorMsg));
      }
    });
  }
}