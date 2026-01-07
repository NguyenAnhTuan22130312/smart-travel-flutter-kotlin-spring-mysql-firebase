import 'package:flutter/material.dart';
import '../../screens/invoice/cancel_booking_screen.dart';
import '../../screens/invoice/invoice_detail_screen.dart';
import '../../screens/invoice/qr_display_screen.dart';
import '../../theme/app_colors.dart';

class InvoiceStatusCard extends StatelessWidget {
  final int bookingId;
  final String invoiceNumber;
  final String itemName;
  final String startDate;
  final String endDate;
  final int nights;
  final String status;
  final bool reviewed;

  const InvoiceStatusCard({
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

  // Map trạng thái + màu + text
  ({String text, Color backgroundColor, Color textColor}) getStatusInfo() {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return (
        text: "Đang hoạt động",
        backgroundColor: AppColors.primary.withOpacity(0.15),
        textColor: AppColors.primary,
        );
      case 'CHECKED':
        return (
        text: "Đã nhận đơn",
        backgroundColor: Colors.green.withOpacity(0.15),
        textColor: Colors.green[700]!,
        );
      case 'COMPLETED':
        return (
        text: "Đã hoàn thành",
        backgroundColor: Colors.green.withOpacity(0.15),
        textColor: Colors.green[700]!,
        );
      case 'CANCELED':
        return (
        text: "Đã hủy",
        backgroundColor: Colors.red.withOpacity(0.15),
        textColor: Colors.red[700]!,
        );
      case 'PENDING_REFUND':
        return (
        text: "Đang chờ hoàn tiền",
        backgroundColor: Colors.orange.withOpacity(0.15),
        textColor: Colors.orange[700]!,
        );
      case 'REFUNDED':
        return (
        text: "Đã hoàn tiền",
        backgroundColor: Colors.purple.withOpacity(0.15),
        textColor: Colors.purple[700]!,
        );
      default:
        return (
        text: "Không xác định",
        backgroundColor: Colors.grey.withOpacity(0.15),
        textColor: Colors.grey[700]!,
        );
    }
  }

  void _onMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'cancel':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CancelBookingScreen(
              bookingData: {
                "bookingId": bookingId,
                "invoiceNumber": invoiceNumber,
                "itemName": itemName,
                "startDate": startDate,
                "endDate": endDate,
                "nights": nights,
                "status": status,
                "reviewed": reviewed,
              },
            ),
          ),
        );
        break;
      case 'export':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QRDisplayScreen(
              invoiceNumber: invoiceNumber,
              bookingId: bookingId,
              itemName: itemName,
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isHotel = nights > 0;
    final statusInfo = getStatusInfo();
    final bool canCancel = status.toUpperCase() == 'ACTIVE'; // Chỉ ACTIVE mới được hủy

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InvoiceDetailScreen(
                bookingId: bookingId,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Mã đặt chỗ + Tùy chọn (menu động)
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    offset: const Offset(0, 36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: Colors.white,
                    elevation: 6,
                    itemBuilder: (context) => [
                      if (canCancel)
                        const PopupMenuItem(
                          value: 'cancel',
                          child: Text("Hủy đặt chỗ"),
                        ),
                      const PopupMenuItem(
                        value: 'export',
                        child: Text("Xuất phiếu thanh toán"),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Tên tour/khách sạn
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
              const SizedBox(height: 6),

              // Ngày + số đêm
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600),
                        children: [
                          TextSpan(text: "${_formatDate(startDate)} - ${_formatDate(endDate)}"),
                          if (isHotel) ...[
                            const TextSpan(text: " · "),
                            TextSpan(
                              text: "$nights đêm",
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Trạng thái động
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusInfo.backgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusInfo.text,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusInfo.textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}