import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../injection_container.dart' as di;
import '../../blocs/invoice/refund_bloc.dart';
import '../../blocs/invoice/refund_event.dart';
import '../../blocs/invoice/refund_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/invoice/empty_order_widget.dart';
import '../../widgets/invoice/invoice_status_card.dart';

class RefundManagementScreen extends StatelessWidget {
  const RefundManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Column(
          children: [
            // HEADER XANH - Nút back tròn trắng + Tiêu đề
            CustomAppBar(titleKey: 'refund_management'),


            Expanded(
              child: BlocProvider(
                create: (_) => di.sl<RefundBloc>()..add(LoadRefundedInvoices()),
                child: BlocBuilder<RefundBloc, RefundState>(
                  builder: (context, state) {

                    Future<void> _onRefresh() async {
                      context.read<RefundBloc>().add(LoadRefundedInvoices());
                    }

                    // ===== LOADING =====
                    if (state is RefundLoading) {
                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: AppColors.primary,
                        child: const SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: 500,
                            child: Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          ),
                        ),
                      );
                    }

                    // ===== ERROR =====
                    if (state is RefundError) {
                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: AppColors.primary,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: 500,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "Đã có lỗi xảy ra",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(state.message),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => _onRefresh(),
                                    child: const Text("Thử lại"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    // ===== LOADED =====
                    if (state is RefundLoaded) {
                      final invoices = state.invoices;

                      // --- RỖNG ---
                      if (invoices.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: _onRefresh,
                          color: AppColors.primary,
                          child: const SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: 500,
                              child: EmptyInvoiceWidget(
                                title: 'Bạn không có bất kỳ yêu cầu hoàn tiền nào',
                                description: 'Các yêu cầu hoàn tiền sẽ được hiển thị tại đây khi bạn thực hiện hủy đặt chỗ hợp lệ.',
                              ),
                            ),
                          ),
                        );
                      }

                      // --- CÓ DATA ---
                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          itemCount: invoices.length,
                          itemBuilder: (context, index) {
                            final invoice = invoices[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InvoiceStatusCard(
                                bookingId: invoice.bookingId,
                                invoiceNumber: invoice.invoiceNumber,
                                itemName: invoice.itemName,
                                startDate: invoice.startDate,
                                endDate: invoice.endDate,
                                nights: invoice.nights,
                                status: invoice.status,
                                reviewed: invoice.reviewed,
                              ),
                            );
                          },
                        ),
                      );
                    }

                    // ===== FALLBACK =====
                    return const SizedBox();
                  },
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}