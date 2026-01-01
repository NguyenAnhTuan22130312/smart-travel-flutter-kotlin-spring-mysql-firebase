import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SuccessReviewEmptyWidget extends StatelessWidget {
  const SuccessReviewEmptyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon check vòng tròn xanh - biểu tượng hoàn thành
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.15), // Nền xanh nhạt
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 100,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 32),

          const Text(
            "Tất cả yêu cầu đánh giá đã được hoàn thành",
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
              "Cảm ơn bạn đã dành thời gian đánh giá! Ý kiến của bạn giúp chúng tôi cải thiện dịch vụ tốt hơn mỗi ngày.",
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
    );
  }
}