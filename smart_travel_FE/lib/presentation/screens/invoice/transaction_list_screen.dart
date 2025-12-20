import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../widgets/invoice/empty_order_widget.dart';
import '../../widgets/invoice/invoice_status_card.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({Key? key}) : super(key: key);

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String selectedType = "Tất cả";
  String selectedStatus = "Đang hoạt động";

  final List<String> typeOptions = ["Tất cả", "Khách sạn", "Tour"];
  final List<String> statusOptions = [
    "Đang hoạt động",
    "Đã hoàn thành",
    "Đã hủy",
    "Đã hoàn tiền",
    "Chờ hoàn tiền"
  ];

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
                  // Nút back tròn trắng
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
                    "Danh sách giao dịch",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // DÒNG FILTER - 2 PopupMenu đẹp với animation mượt
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Filter loại giao dịch
                  Expanded(
                    child: _buildCustomDropdown(
                      value: selectedType,
                      items: typeOptions,
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Filter trạng thái
                  Expanded(
                    child: _buildCustomDropdown(
                      value: selectedStatus,
                      items: statusOptions,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),


            // PHẦN NỘI DUNG CHÍNH - HIỂN THỊ ĐỘNG: EMPTY HOẶC LIST CARD
            Expanded(
              child: Builder(
                builder: (context) {
                  // === GIẢ LẬP DỮ LIỆU ĐỂ TEST ===
                  // Đổi thành false để test empty state
                   bool hasTransactions = true;

                  if (!hasTransactions) {
                    return const EmptyInvoiceWidget(
                      title: 'Bạn hiện không có bất kỳ giao dịch nào',
                      description:
                      'Khi bạn đặt tour hoặc khách sạn, các giao dịch sẽ hiện ra tại đây.',
                    );
                  }

                  // === CÓ DỮ LIỆU → HIỂN THỊ LIST CARD ===
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    children: [
                      // ==== DỮ LIỆU GIẢ LẬP - DÙNG InvoiceStatusCard ====
                      InvoiceStatusCard(
                        bookingId: 1,
                        invoiceNumber: "INV20251026-000",
                        itemName: "Mercure Ba Na Hills French Village",
                        startDate: "2025-10-26",
                        endDate: "2025-10-27",
                        nights: 1,
                        status: "ACTIVE",
                        reviewed: false,
                      ),
                      const SizedBox(height: 12),

                      InvoiceStatusCard(
                        bookingId: 2,
                        invoiceNumber: "INV20251209-001",
                        itemName: "Tour Bà Nà Hills 1 Ngày",
                        startDate: "2025-12-09",
                        endDate: "2025-12-10",
                        nights: 0,
                        status: "COMPLETED",
                        reviewed: true,
                      ),
                      const SizedBox(height: 12),

                      InvoiceStatusCard(
                        bookingId: 3,
                        invoiceNumber: "INV20251225-002",
                        itemName: "Tour Bà Nà Hills - Hội An 2N1Đ",
                        startDate: "2025-12-25",
                        endDate: "2025-12-26",
                        nights: 1,
                        status: "CANCELED",
                        reviewed: false,
                      ),
                      const SizedBox(height: 12),

                      InvoiceStatusCard(
                        bookingId: 4,
                        invoiceNumber: "INV20250115-003",
                        itemName: "Vinpearl Resort & Spa Hội An",
                        startDate: "2025-01-15",
                        endDate: "2025-01-18",
                        nights: 3,
                        status: "PENDING_REFUND",
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
                        status: "REFUNDED",
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

  // Widget dropdown đẹp với animation mượt, shadow, bo tròn
  Widget _buildCustomDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.15),
      itemBuilder: (context) {
        return items.map((String item) {
          return PopupMenuItem<String>(
            value: item,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Text(
                item,
                style: TextStyle(
                  color: item == value ? AppColors.primary : Colors.black87,
                  fontWeight: item == value ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}