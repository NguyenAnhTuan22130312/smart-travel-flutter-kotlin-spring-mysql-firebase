import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> invoiceData;

  const InvoiceDetailScreen({Key? key, required this.invoiceData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = invoiceData['data'];

    final String bookingType = data['bookingType'];
    final String status = data['status'];
    final int nights = data['nights'] ?? 0;
    final bool isHotel = bookingType == "HOTEL";
    final bool canCancel = status == "ACTIVE";
    final bool canReview = data['reviewed'] == false && (status == "COMPLETED" || status == "REFUNDED");

    // Parse itemDetailsJson
    List<Map<String, dynamic>> roomDetails = [];
    try {
      final List<dynamic> jsonList = List.from(jsonDecode(data['itemDetailsJson']));
      roomDetails = jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      // Fallback nếu parse lỗi
      roomDetails = [];
    }

    String formatDate(String date) {
      List<String> parts = date.split('-');
      return "${parts[2]}/${parts[1]}/${parts[2].substring(0, 4)}";
    }

    String formatPrice(double price) {
      return price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.') + ' ₫';
    }

    // Màu trạng thái
    Color getStatusColor() {
      switch (status) {
        case 'ACTIVE':
          return AppColors.primary;
        case 'COMPLETED':
          return Colors.green;
        case 'CANCELED':
          return Colors.red;
        case 'PENDING_REFUND':
          return Colors.orange;
        case 'REFUNDED':
          return Colors.purple;
        default:
          return Colors.grey;
      }
    }

    String getStatusText() {
      switch (status) {
        case 'ACTIVE':
          return "Đang hoạt động";
        case 'COMPLETED':
          return "Đã hoàn thành";
        case 'CANCELED':
          return "Đã hủy";
        case 'PENDING_REFUND':
          return "Đang chờ hoàn tiền";
        case 'REFUNDED':
          return "Đã hoàn tiền";
        default:
          return status;
      }
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey[50],
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Column(
          children: [
            // HEADER XANH + ẢNH THUMBNAIL
            Container(
              height: 320,
              color: AppColors.primary,
              child: Stack(
                children: [
                  // Ảnh thumbnail
                  Positioned.fill(
                    child: Image.network(
                      data['thumbnailUrl'],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(color: Colors.grey[800]);
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: Icon(isHotel ? Icons.hotel : Icons.tour, size: 80, color: Colors.white70),
                        );
                      },
                    ),
                  ),
                  // Nút back
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 18),
                      ),
                    ),
                  ),
                  // Trạng thái đơn hàng
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Mã đặt chỗ: ${data['invoiceNumber']}",
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  getStatusText(),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: getStatusColor(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.check_circle, color: getStatusColor(), size: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // NỘI DUNG CHI TIẾT
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Tên + tiện ích
                  Text(
                    data['itemName'],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data['amenitiesSummary'] ?? "Không có tiện ích nổi bật",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 20),

                  // Ngày + số đêm + số người
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Text(
                              "${formatDate(data['startDate'])} - ${formatDate(data['endDate'])}",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.nights_stay, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Text("$nights đêm · ${data['numberOfPeople']} người"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Chi tiết phòng
                  if (roomDetails.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Chi tiết phòng", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ...roomDetails.map((room) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "${room['name']} x ${room['rooms']} phòng · ${room['nights']} đêm",
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                Text(
                                  formatPrice(room['subtotal']),
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          )).toList(),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Thông tin khách hàng
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Thông tin khách hàng", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text("Tên: ${data['customerName']}"),
                        Text("SĐT: ${data['customerPhone']}"),
                        Text("Email: ${data['customerEmail']}"),
                        if (data['specialRequests'] != null && data['specialRequests'].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text("Yêu cầu đặc biệt: ${data['specialRequests']}"),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Chi tiết thanh toán
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        const Text("Chi tiết thanh toán", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Tổng tiền"),
                            Text(formatPrice(data['totalPrice'])),
                          ],
                        ),
                        if (data['discountAmount'] > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Giảm giá"),
                              Text("- ${formatPrice(data['discountAmount'])}", style: const TextStyle(color: Colors.green)),
                            ],
                          ),
                        ],
                        if (data['taxAmount'] > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Thuế"),
                              Text(formatPrice(data['taxAmount'])),
                            ],
                          ),
                        ],
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Thành tiền", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(formatPrice(data['finalPrice']), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // NÚT HÀNH ĐỘNG
                  Row(
                    children: [
                      if (canCancel)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Hủy đặt chỗ
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.red),
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text("Hủy đặt chỗ", style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      if (canCancel) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Xuất phiếu
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text("Xuất phiếu thanh toán", style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                  if (canReview) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Mở đánh giá
                        },
                        icon: const Icon(Icons.star_border),
                        label: const Text("Đánh giá trải nghiệm của bạn", style: TextStyle(fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}