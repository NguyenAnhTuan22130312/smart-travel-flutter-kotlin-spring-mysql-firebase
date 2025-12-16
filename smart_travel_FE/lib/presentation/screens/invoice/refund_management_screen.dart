import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';

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

            // KHÔNG CÓ FILTER NỮA → BỎ HOÀN TOÀN PHẦN NÀY

            // PHẦN LIST HOÀN TIỀN - TẠM TRỐNG
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 140,
                          color: const Color(0xFF8CC9E8),
                        ),
                        Positioned(
                          right: 20,
                          top: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFE082),
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                            ),
                            child: const Text(
                              "Zzz",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "Bạn không có bất kì yêu cầu hoàn tiền nào",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Các yêu cầu hoàn tiền sẽ được hiển thị tại đây khi bạn thực hiện hủy đặt chỗ hợp lệ.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
}