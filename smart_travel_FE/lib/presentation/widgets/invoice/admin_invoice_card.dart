import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AdminInvoiceCard extends StatelessWidget {
  final int bookingId;
  final String invoiceNumber;
  final String itemName;
  final String startDate;
  final String endDate;
  final String status;
  final VoidCallback? onViewDetail; // Callback khi nhấn xem chi tiết

  const AdminInvoiceCard({
    Key? key,
    required this.bookingId,
    required this.invoiceNumber,
    required this.itemName,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.onViewDetail,
  }) : super(key: key);

  String _formatDate(String date) {
    if (date.isEmpty || date == "Không rõ") return "Không rõ";
    try {
      List<String> parts = date.split('-');
      return "${parts[2]}/${parts[1]}/${parts[0]}";
    } catch (e) {
      return date;
    }
  }

  Color _getStatusColor() {
    switch (status.toUpperCase()) {
      case 'ACTIVE': return Colors.green;
      case 'CHECKED': return Colors.blue;
      case 'COMPLETED': return Colors.teal;
      case 'PENDING_REFUND': return Colors.orange;
      case 'CANCELED': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (status.toUpperCase()) {
      case 'ACTIVE': return "Đang hoạt động";
      case 'CHECKED': return "Đã check-in";
      case 'COMPLETED': return "Đã hoàn thành";
      case 'PENDING_REFUND': return "Chờ hoàn tiền";
      case 'CANCELED': return "Đã hủy";
      default: return status.isEmpty ? "N/A" : status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onViewDetail, // ← Bấm toàn card → mở chi tiết
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần Header (Mã đơn & Nút 3 chấm)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 4, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Mã đơn: ${invoiceNumber.isEmpty ? 'N/A' : invoiceNumber}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.black87),
                    onSelected: (value) {
                      if (value == 'detail' && onViewDetail != null) {
                        onViewDetail!(); // Vẫn giữ nút 3 chấm hoạt động
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'detail',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 20, color: Colors.blue),
                            SizedBox(width: 10),
                            Text('Xem chi tiết', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Phần nội dung chính (Tên dịch vụ)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                itemName.isEmpty ? "Không có tên dịch vụ" : itemName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Phần ngày tháng
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, size: 20, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  Text(
                    "${_formatDate(startDate)} - ${_formatDate(endDate)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Phần Footer (Trạng thái đơn hàng)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Trạng thái đơn hàng:",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}