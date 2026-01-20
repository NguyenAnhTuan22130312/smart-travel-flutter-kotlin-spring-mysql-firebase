import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/presentation/screens/invoice/refund_management_screen.dart';
import 'package:smart_travel/presentation/screens/invoice/review_management_screen.dart';
import 'package:smart_travel/presentation/screens/invoice/transaction_list_screen.dart';
import 'package:smart_travel/presentation/widgets/common/custom_app_bar.dart';
import '../../../injection_container.dart' as di;
import '../../blocs/invoice/invoice_bloc.dart';
import '../../blocs/invoice/invoice_event.dart';
import '../../blocs/invoice/invoice_state.dart';
import '../../blocs/invoice/search_bloc.dart';
import '../../blocs/invoice/transaction_bloc.dart';
import '../../theme/app_colors.dart';
import 'package:flutter/services.dart';

import '../../widgets/invoice/empty_order_widget.dart';
import '../../widgets/invoice/invoice_card.dart';
import 'invoice_search_screen.dart';

class MyInvoicesScreen extends StatelessWidget {
  const MyInvoicesScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: false, // ← Thêm dòng này (kéo body lên phía sau status bar)
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Column(
          children: [
            CustomAppBar(titleKey: 'my_invoices', ),

            // THANH SEARCH CÓ ĐỔ BÓNG ĐẸP
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(

                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) {
                              return BlocProvider(
                                create: (_) => di.sl<SearchBloc>(),
                                child: const InvoiceSearchScreen(),
                              );
                            },
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(0.0, 1.0); // Từ dưới lên
                              const end = Offset.zero;
                              const curve = Curves.ease;

                              final tween =
                              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              final offsetAnimation = animation.drive(tween);

                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 350),
                            reverseTransitionDuration: const Duration(milliseconds: 300),
                          ),
                        );
                      },

                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 12),
                            Text(
                              "Tìm kiếm lịch sử đặt chỗ",
                              style: TextStyle(
                                color: AppColors.textGray,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // ICON MÃ GIẢM GIÁ - CỐ ĐỊNH BÊN PHẢI
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_offer_outlined,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // NỘI DUNG CHÍNH
            Expanded(
              child: BlocProvider(
                create: (_) => di.sl<InvoiceBloc>()..add(const LoadActiveInvoices()),
                child: BlocBuilder<InvoiceBloc, InvoiceState>(
                  builder: (context, state) {
                    Widget body;

                    if (state is InvoiceLoading) {
                      body = const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    } else if (state is InvoiceError) {
                      body = Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 60, color: Colors.red),
                            const SizedBox(height: 16),
                            const Text(
                              "Đã có lỗi xảy ra",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.read<InvoiceBloc>().add(const LoadActiveInvoices()),
                              child: const Text("Thử lại"),
                            ),
                          ],
                        ),
                      );
                    } else if (state is InvoiceLoaded) {
                      final invoices = state.invoices;

                      body = SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ExpansionTile(
                              shape: const RoundedRectangleBorder(side: BorderSide.none),
                              tilePadding: EdgeInsets.zero,
                              childrenPadding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                              collapsedBackgroundColor: Colors.transparent,
                              maintainState: true,
                              trailing: const SizedBox.shrink(),
                              title: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Đơn đặt chỗ đang hoạt động (${invoices.length})",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary, size: 30),
                                  ],
                                ),
                              ),
                              initiallyExpanded: true,
                              children: [
                                if (invoices.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 40),
                                    child: EmptyInvoiceWidget(
                                      title: 'Bạn hiện không có bất kỳ yêu cầu đặt chỗ nào',
                                      description: 'Khám phá cuộc phiêu lưu mới với những ý tưởng truyền cảm hứng của chúng tôi dưới đây! '
                                          'Nếu bạn không thể tìm thấy đặt chỗ trước đó của mình, '
                                          'hãy thử đăng nhập bằng email mà bạn đã sử dụng khi đặt chỗ.',
                                    ),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                                    child: Column(
                                      children: invoices.map((invoice) {
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: InvoiceCard(
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
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 10),
                            const Text(
                              "Tất cả các hoạt động mua hàng và hoàn vé",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 20),

                            _buildMenuButton(
                              icon: Icons.receipt_long_outlined,
                              title: "Danh sách lịch sử đặt chỗ của bạn",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider(
                                      create: (_) => di.sl<TransactionBloc>(),
                                      child: const TransactionListScreen(),
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 12),
                            _buildMenuButton(
                              icon: Icons.refresh_outlined,
                              title: "Kiểm tra các khoản hoàn tiền trước đây",
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RefundManagementScreen())),
                            ),
                            const SizedBox(height: 12),
                            _buildMenuButton(
                              icon: Icons.sentiment_satisfied_outlined,
                              title: "Đánh giá trải nghiệm gần đây của bạn",
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReviewManagementScreen())),
                            ),
                          ],
                        ),
                      );
                    } else {
                      body = const Center(child: CircularProgressIndicator());
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<InvoiceBloc>().add(const LoadActiveInvoices());
                        await context.read<InvoiceBloc>().stream.firstWhere(
                              (state) => state is InvoiceLoaded || state is InvoiceError,
                        );
                      },
                      color: AppColors.primary,
                      backgroundColor: Colors.white,
                      strokeWidth: 2.5,
                      child: body,
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

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: AppColors.primary,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

}