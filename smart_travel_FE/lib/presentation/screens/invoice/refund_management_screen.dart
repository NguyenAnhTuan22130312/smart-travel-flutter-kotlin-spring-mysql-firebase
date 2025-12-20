import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
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
            Container(
              color: AppColors.primary,
              padding: EdgeInsets.fromLTRB(
                10,
                MediaQuery.of(context).padding.top + 5,
                10,
                10,
              ),
              child: Row(
                children: [
                  // Nút back tròn trắng, mũi tên xanh
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
                  // Tiêu đề
                  const Text(
                    "Quản lý hoàn tiền",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),


            Expanded(
              child: Builder(
                builder: (context) {
                  // === GIẢ LẬP DỮ LIỆU CHO TRANG HOÀN TIỀN ===
                  // Đổi thành false để test empty state
                  final bool hasRefundRequests = true;

                  if (!hasRefundRequests) {
                    return const EmptyInvoiceWidget(
                      title: 'Bạn không có bất kỳ yêu cầu hoàn tiền nào',
                      description: 'Các yêu cầu hoàn tiền sẽ được hiển thị tại đây khi bạn thực hiện hủy đặt chỗ hợp lệ.',
                    );
                  }

                  // === CÓ YÊU CẦU HOÀN TIỀN → HIỂN THỊ LIST CARD ===
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    children: [
                      // ==== DỮ LIỆU GIẢ LẬP CHỈ LIÊN QUAN ĐẾN HOÀN TIỀN ====
                      InvoiceStatusCard(
                        bookingId: 4,
                        invoiceNumber: "INV20250115-003",
                        itemName: "Vinpearl Resort & Spa Hội An",
                        startDate: "2025-01-15",
                        endDate: "2025-01-18",
                        nights: 3,
                        status: "PENDING_REFUND", // Đang chờ hoàn tiền
                        reviewed: false,
                      ),
                      const SizedBox(height: 12),

                      InvoiceStatusCard(
                        bookingId: 5,
                        invoiceNumber: "INV20250220-004",
                        itemName: "Tour Phú Quốc 3N2Đ",
                        startDate: "2025-02-20",
                        endDate: "2025-02-23",
                        nights: 2,
                        status: "REFUNDED", // Đã hoàn tiền
                        reviewed: true,
                      ),

                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}