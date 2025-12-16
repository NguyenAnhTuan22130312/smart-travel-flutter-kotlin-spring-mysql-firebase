import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class InvoiceCard extends StatelessWidget {
  final int bookingId;
  final String invoiceNumber;
  final String itemName;
  final String startDate;
  final String endDate;
  final int nights;
  final String status;
  final bool reviewed;

  const InvoiceCard({
    Key? key,
    required this.bookingId,
    required this.invoiceNumber,
    required this.itemName,
    required this.startDate,
    required this.endDate,
    required this.nights,
    required this.status,
    required this.reviewed,
  }) : super(key: key);

  String _formatDate(String date) {
    List<String> parts = date.split('-');
    return "${parts[2]}/${parts[1]}/${parts[0]}";
  }

  void _onMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'cancel':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mở màn hình hủy đặt chỗ")),
        );
        break;
      case 'export':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Xuất phiếu thanh toán (PDF)")),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isHotel = nights > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),

      // 👉 CHỈNH KHOẢNG CÁCH TỪ NỘI DUNG TỚI MÉP CARD (TRÊN / DƯỚI / TRÁI / PHẢI)
      // Giảm số này nếu thấy card bị cao / giãn
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10, // 👈 GIẢM TỪ 14 → 10 để card gọn hơn
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ================= HEADER =================
          Row(
            children: [
              Expanded(
                child: Text(
                  "Mã đặt chỗ: $invoiceNumber",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              PopupMenuButton<String>(
                onSelected: (value) => _onMenuSelected(context, value),

                child: const Text(
                  "Tùy chọn",

                  // 👉 CHỈNH CỠ CHỮ CỦA NÚT OPTION Ở ĐÂY
                  style: TextStyle(
                    fontSize: 14, // 👈 ĐỔI SIZE CHỮ Ở ĐÂY
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),

                offset: const Offset(0, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                elevation: 6,

                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'cancel',

                    // 👉 CHỈNH CỠ CHỮ OPTION TRONG MENU Ở ĐÂY
                    child: const Text(
                      "Hủy đặt chỗ",
                      style: TextStyle(
                        fontSize: 16, // 👈 SIZE CHỮ OPTION
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'export',
                    child: const Text(
                      "Xuất phiếu thanh toán",
                      style: TextStyle(
                        fontSize: 16, // 👈 SIZE CHỮ OPTION
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 👉 CHỈNH KHOẢNG CÁCH DÒNG DƯỚI HEADER
          const SizedBox(height: 6), // 👈 giảm nếu thấy rộng

          /// ================= TÊN TOUR / KHÁCH SẠN =================
          Row(
            children: [
              Icon(
                isHotel ? Icons.hotel_outlined : Icons.tour_outlined,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  itemName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // 👉 CHỈNH KHOẢNG CÁCH DÒNG
          const SizedBox(height: 6),

          /// ================= NGÀY + SỐ ĐÊM =================
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14, // 👈 CHỈNH CỠ CHỮ NGÀY Ở ĐÂY
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(text: "${_formatDate(startDate)} - ${_formatDate(endDate)}"),
                      if (isHotel) ...[
                        const TextSpan(text: " · "),
                        TextSpan(
                          text: "$nights đêm",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 👉 CHỈNH KHOẢNG CÁCH TỚI TAG TRẠNG THÁI
          const SizedBox(height: 8),

          /// ================= TRẠNG THÁI =================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "ĐÃ PHÁT HÀNH PHIẾU THANH TOÁN",
              style: TextStyle(
                fontSize: 12, // 👈 CHỈNH SIZE TAG Ở ĐÂY
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
