import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/injection_container.dart' as di;
import 'package:smart_travel/presentation/blocs/invoice/review_bloc.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';
import 'package:smart_travel/presentation/widgets/invoice/invoice_review_card.dart';
import 'package:smart_travel/presentation/widgets/invoice/succes_request_review.dart';

import '../../blocs/invoice/refund_bloc.dart';
import '../../blocs/invoice/refund_event.dart';
import '../../blocs/invoice/review_event.dart';
import '../../blocs/invoice/review_state.dart';

class ReviewManagementScreen extends StatelessWidget {
  const ReviewManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Column(
          children: [
            // HEADER XANH
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.mainGradient,
              ),
              padding: EdgeInsets.fromLTRB(
                10,
                MediaQuery.of(context).padding.top + 5,
                10,
                10,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Đánh giá trải nghiệm gần đây của bạn",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // NỘI DUNG + PULL TO REFRESH
            Expanded(
              child: BlocProvider(
                create: (_) => di.sl<ReviewBloc>()..add( LoadReviewableInvoices()),
                child: BlocBuilder<ReviewBloc, ReviewState>(
                  builder: (context, state) {
                    Widget body;

                    if (state is ReviewLoading) {
                      body = const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    } else if (state is ReviewError) {
                      body = Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 60, color: Colors.red),
                            const SizedBox(height: 16),
                            const Text("Đã có lỗi xảy ra", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(state.message),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.read<ReviewBloc>().add( LoadReviewableInvoices()),
                              child: const Text("Thử lại"),
                            ),
                          ],
                        ),
                      );
                    } else if (state is ReviewLoaded) {
                      final invoices = state.invoices;

                      if (invoices.isEmpty) {
                        body = const SuccessReviewEmptyWidget(); // ← Widget empty bạn đã có
                      } else {
                        body = ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          itemCount: invoices.length,
                          itemBuilder: (context, index) {
                            final invoice = invoices[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InvoiceReviewCard(
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
                        );
                      }
                    } else {
                      body = const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<RefundBloc>().add(LoadRefundedInvoices());
                      },
                      color: AppColors.primary,
                      child: body is ListView
                          ? body // Nếu là ListView → dùng trực tiếp (đã scrollable)
                          : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height - 200,
                          ),
                          child: Center(child: body),
                        ),
                      ),
                    );
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