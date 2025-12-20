import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_travel/presentation/widgets/invoice/invoice_review_card.dart';
import '../../theme/app_colors.dart';
import '../../widgets/invoice/succes_request_review.dart';

class ReviewManagementScreen extends StatelessWidget {
  const ReviewManagementScreen({Key? key}) : super(key: key);

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

            // PHẦN LIST ĐƠN HÀNG - TEST GIẢ LẬP VỚI InvoiceStatusCard
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                children: [
                  // ==== DỮ LIỆU GIẢ LẬP - COPY ĐOẠN NÀY SANG CÁC TRANG KHÁC NẾU CẦN ====
                  InvoiceReviewCard(
                    bookingId: 1,
                    invoiceNumber: "INV20251026-000",
                    itemName: "Mercure Ba Na Hills French Village",
                    startDate: "2025-10-26",
                    endDate: "2025-10-27",
                    nights: 1,
                    status: "ACTIVE", // → Hiển thị "Đang hoạt động" màu xanh
                    reviewed: false,
                  ),
                  const SizedBox(height: 12),

                  InvoiceReviewCard(
                    bookingId: 2,
                    invoiceNumber: "INV20251209-001",
                    itemName: "Tour Bà Nà Hills 1 Ngày",
                    startDate: "2025-12-09",
                    endDate: "2025-12-10",
                    nights: 0,
                    status: "COMPLETED", // → "Đã hoàn thành" màu xanh lá
                    reviewed: true,
                  ),
                  const SizedBox(height: 12),

                  InvoiceReviewCard(
                    bookingId: 3,
                    invoiceNumber: "INV20251225-002",
                    itemName: "Tour Bà Nà Hills - Hội An 2N1Đ",
                    startDate: "2025-12-25",
                    endDate: "2025-12-26",
                    nights: 1,
                    status: "CANCELED", // → "Đã hủy" màu đỏ
                    reviewed: false,
                  ),
                  const SizedBox(height: 12),

                  InvoiceReviewCard(
                    bookingId: 4,
                    invoiceNumber: "INV20250115-003",
                    itemName: "Vinpearl Resort & Spa Hội An",
                    startDate: "2025-01-15",
                    endDate: "2025-01-18",
                    nights: 3,
                    status: "PENDING_REFUND", // → "Đang chờ hoàn tiền" màu cam
                    reviewed: false,
                  ),
                  const SizedBox(height: 12),

                  InvoiceReviewCard(
                    bookingId: 5,
                    invoiceNumber: "INV20250220-004",
                    itemName: "Tour Phú Quốc 3N2Đ",
                    startDate: "2025-02-20",
                    endDate: "2025-02-23",
                    nights: 2,
                    status: "REFUNDED", // → "Đã hoàn tiền" màu tím/xám
                    reviewed: true,
                  ),
                  // ==== KẾT THÚC ĐOẠN TEST GIẢ LẬP ====

                  const SizedBox(height: 20),
                  SuccessReviewEmptyWidget()
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}