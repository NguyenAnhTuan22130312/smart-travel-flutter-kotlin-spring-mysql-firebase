import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'cancel_form_screen.dart';

class CancelTermsScreen extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const CancelTermsScreen({Key? key, required this.bookingData}) : super(key: key);
  String _formatDate(String date) {
    List<String> parts = date.split('-');
    return "${parts[2]}/${parts[1]}/${parts[0]}";
  }

  @override
  Widget build(BuildContext context) {
    final String itemName = bookingData['itemName'];
    final String startDate = bookingData['startDate'];
    final int nights = bookingData['nights'];
    final String invoiceNumber = bookingData['invoiceNumber'];
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // HEADER - BACK + TIÊU ĐỀ
          Container(
            color: AppColors.primary,
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 10,
              16,
              16,
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
                const SizedBox(width: 20),
                const Text(
                  "Điều khoản & Điều kiện",
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
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // KHUNG THÔNG TIN ĐƠN HÀNG
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
                      Text(
                        itemName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "${_formatDate(startDate)} · $nights đêm",
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.receipt, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Mã đặt chỗ: $invoiceNumber",
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ĐIỀU KHOẢN DÀI LẰNG NHẰNG GIỐNG TRAVELOKA
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Tiêu đề nền xám
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: const Text(
                          "Điều khoản & Điều kiện hủy đặt chỗ",
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Nội dung nền trắng
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                        ),
                        child: const Text(
                          "1. Chính sách hủy phòng\n"
                              "Bạn có thể hủy đặt phòng miễn phí trước 23:59 ngày 25/10/2025 (giờ địa phương của khách sạn). "
                              "Nếu hủy sau thời điểm này, bạn sẽ bị tính phí hủy như sau:\n\n"
                              "• Hủy từ 00:00 ngày 26/10/2025 đến trước ngày nhận phòng: Phạt 50% tổng tiền đặt phòng.\n"
                              "• Hủy trong vòng 24 giờ trước ngày nhận phòng hoặc không đến (no-show): Phạt 100% tổng tiền đặt phòng.\n\n"
                              "2. Hoàn tiền\n"
                              "Số tiền hoàn lại (nếu có) sẽ được chuyển về phương thức thanh toán gốc trong vòng 7-14 ngày làm việc, "
                              "tùy thuộc vào ngân hàng hoặc nhà cung cấp thẻ.\n\n"
                              "3. Thay đổi đặt phòng\n"
                              "Một số đặt phòng không hỗ trợ thay đổi ngày hoặc loại phòng sau khi xác nhận. "
                              "Nếu muốn thay đổi, bạn cần hủy đặt phòng hiện tại và đặt lại (có thể áp dụng phí hủy).\n\n"
                              "4. Lưu ý đặc biệt\n"
                              "• Chính sách hủy có thể khác nhau tùy theo loại phòng (non-refundable, flexible, etc.).\n"
                              "• Trong trường hợp bất khả kháng (thiên tai, dịch bệnh, chính sách chính phủ), chúng tôi sẽ hỗ trợ theo quy định hiện hành.\n"
                              "• Phiếu xác nhận đặt phòng đã xuất sẽ mất hiệu lực sau khi hủy thành công.\n\n"
                              "Bằng việc tiếp tục, bạn xác nhận đã đọc và đồng ý với các điều khoản trên.",
                          style: TextStyle(fontSize: 15, height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Nút tiếp tục
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CancelFormScreen(bookingData: bookingData),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "Tôi đồng ý và tiếp tục hủy",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}