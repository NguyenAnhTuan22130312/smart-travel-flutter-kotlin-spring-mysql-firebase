import 'package:flutter/material.dart';
import 'package:smart_travel/presentation/screens/invoice/refund_management_screen.dart';
import 'package:smart_travel/presentation/screens/invoice/review_management_screen.dart';
import 'package:smart_travel/presentation/screens/invoice/transaction_list_screen.dart';
import '../../theme/app_colors.dart';
import 'package:flutter/services.dart';

import '../../widgets/invoice/invoice_card.dart';

class MyInvoicesScreen extends StatelessWidget {
  const MyInvoicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: false, // ← Thêm dòng này (kéo body lên phía sau status bar)
        backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Column(
          children: [
            Container(
              color: AppColors.primary,
              padding: EdgeInsets.fromLTRB(
                10,
                MediaQuery.of(context).padding.top + 10, // ← Quan trọng: tự thêm khoảng cách status bar
                16,
                20,
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(23),
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
                ],
              ),
            ),


            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16,0,16,16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Center(
                    //   child: Column(
                    //     children: [
                    //       Stack(
                    //         alignment: Alignment.topRight,
                    //         children: [
                    //           Icon(
                    //             Icons.folder_outlined,
                    //             size: 140,
                    //             color: const Color(0xFF8CC9E8),
                    //           ),
                    //           Positioned(
                    //             right: 20,
                    //             top: 20,
                    //             child: Container(
                    //               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    //               decoration: const BoxDecoration(
                    //                 color: Color(0xFFFFE082),
                    //                 borderRadius: BorderRadius.all(Radius.circular(30)),
                    //               ),
                    //               child: const Text(
                    //                 "Zzz",
                    //                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //
                    //       const SizedBox(height: 32),
                    //
                    //       const Text(
                    //         "Bạn hiện không có bất kỳ yêu cầu đặt chỗ nào",
                    //         style: TextStyle(
                    //           fontSize: 18,
                    //           fontWeight: FontWeight.w600,
                    //           color: Colors.black87,
                    //         ),
                    //         textAlign: TextAlign.center,
                    //       ),
                    //       const SizedBox(height: 16),
                    //       Padding(
                    //         padding: const EdgeInsets.symmetric(horizontal: 20),
                    //         child: Text(
                    //           "Khám phá cuộc phiêu lưu mới với những ý tưởng truyền cảm hứng của chúng tôi dưới đây! Nếu bạn không thể tìm thấy đặt chỗ trước đó của mình, hãy thử đăng nhập bằng email mà bạn đã sử dụng khi đặt chỗ.",
                    //           style: TextStyle(
                    //             fontSize: 14,
                    //             color: Colors.grey[700],
                    //             height: 1.5,
                    //           ),
                    //           textAlign: TextAlign.center,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    // ===== SECTION COLLAPSIBLE: ĐƠN ĐẶT CHỖ ĐANG HOẠT ĐỘNG =====
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero, // ← XÓA HOÀN TOÀN PADDING TRÁI/PHẢI CỦA TIÊU ĐỀ
                      childrenPadding: EdgeInsets.zero, // ← XÓA PADDING TRONG KHU VỰC CHILDREN
                      backgroundColor: Colors.transparent,
                      collapsedBackgroundColor: Colors.transparent,
                      maintainState: true,
                      trailing: const SizedBox.shrink(), // ẨN MŨI TÊN THỪA
                      title: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0), // ← TỰ THÊM PADDING ĐẸP CHO TIÊU ĐỀ
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Đơn đặt chỗ đang hoạt động........",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.primary,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                      initiallyExpanded: true, // Mở sẵn
                      children: [
                        // XÓA ĐƯỜNG KẺ NGANG TRÊN/DƯỚI BẰNG CÁCH KHÔNG DÙNG DIVIDER
                        Column(
                          children: const [
                            InvoiceCard(
                              bookingId: 1,
                              invoiceNumber: "INV20251026-000",
                              itemName: "Mercure Ba Na Hills French Village",
                              startDate: "2025-10-26",
                              endDate: "2025-10-27",
                              nights: 1,
                              status: "ACTIVE",
                              reviewed: false,
                            ),
                            SizedBox(height: 12),
                            InvoiceCard(
                              bookingId: 2,
                              invoiceNumber: "INV20251209-001",
                              itemName: "Tour Bà Nà Hills 1 Ngày",
                              startDate: "2025-12-09",
                              endDate: "2025-12-10",
                              nights: 0,
                              status: "ACTIVE",
                              reviewed: true,
                            ),
                            SizedBox(height: 12),
                            InvoiceCard(
                              bookingId: 3,
                              invoiceNumber: "INV20251225-002",
                              itemName: "Tour Bà Nà Hills - Hội An 2N1Đ",
                              startDate: "2025-12-25",
                              endDate: "2025-12-26",
                              nights: 1,
                              status: "ACTIVE",
                              reviewed: false,
                            ),
                            SizedBox(height: 16), // Khoảng cách dưới cùng trước phần bên dưới
                          ],
                        ),
                      ],
                    ),



                    const SizedBox(height: 40),

                    const Text(
                      "Tất cả các hoạt động mua hàng và hoàn vé",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Button 1: Danh sách mua hàng
                    _buildMenuButton(
                      icon: Icons.receipt_long_outlined,
                      title: "Danh sách mua hàng của bạn",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TransactionListScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Button 2: Kiểm tra hoàn tiền
                    _buildMenuButton(
                      icon: Icons.refresh_outlined,
                      title: "Kiểm tra các khoản hoàn tiền trước đây",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RefundManagementScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Button 3: Đánh giá
                    _buildMenuButton(
                      icon: Icons.sentiment_satisfied_outlined,
                      title: "Đánh giá trải nghiệm gần đây của bạn",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ReviewManagementScreen()),
                        );
                      },
                    ),

                  ],
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
      borderRadius: BorderRadius.circular(16), // Bo tròn hơn một chút (từ 12 → 16)
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), // Tăng padding cho rộng rãi
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1), // Viền nhẹ
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15), // Đổ bóng mềm
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4), // Đổ bóng xuống dưới
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
              size: 32, // Tăng icon lên chút cho nổi bật
              color: AppColors.primary,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w600, // Đậm hơn chút
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