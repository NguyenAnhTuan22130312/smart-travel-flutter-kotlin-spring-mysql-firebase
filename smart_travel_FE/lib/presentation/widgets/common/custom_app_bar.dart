import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CustomAppBar extends StatelessWidget {
  final String titleKey; // Key để lấy text từ localization
  final VoidCallback? onBackPressed; // Optional back action
  final List<Widget>? actions; // Optional actions bên phải (nếu cần)
  final bool centerTitle;

  const CustomAppBar({
    Key? key,
    required this.titleKey,
    this.onBackPressed,
    this.actions,
    this.centerTitle = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, String> titleMap = {
      'my_invoices': 'Đặt chỗ của tôi',
      'transaction_list': 'Danh sách giao dịch',
      'refund_management': 'Quản lý hoàn tiền',
      'review_management': 'Đánh giá trải nghiệm gần đây của bạn',
      'invoice_detail': 'Chi tiết đơn hàng',
      // Thêm các key khác khi cần
    };

    // Tiếng Anh (sau này sẽ thay bằng localization thật)
    final Map<String, String> titleMapEn = {
      'my_invoices': 'My Bookings',
      'transaction_list': 'Transaction List',
      'refund_management': 'Refund Management',
      'review_management': 'Review Your Recent Experiences',
      'invoice_detail': 'Booking Details',
    };

    // TODO: Khi có localization thật, thay bằng: AppLocalizations.of(context)!.myInvoices
    final String title = titleMap[titleKey] ?? titleKey;

    return Container(

      decoration: BoxDecoration(
        gradient: AppColors.mainGradient,
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 10,
        16,
        16,
      ),

      child: centerTitle
          ? _buildCenterTitle(context, title)
          : _buildLeadingTitle(context, title),
    );
  }
  Widget _buildCenterTitle(BuildContext context, String title) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: _backButton(context),
        ),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _titleStyle,
        ),
        if (actions != null)
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: actions!,
            ),
          ),
      ],
    );
  }
  Widget _buildLeadingTitle(BuildContext context, String title) {
    return Row(
      children: [
        _backButton(context),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: _titleStyle,
          ),
        ),
        if (actions != null) ...actions!,
      ],
    );
  }
  Widget _backButton(BuildContext context) {
    return GestureDetector(
      onTap: onBackPressed ?? () => Navigator.pop(context),
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
    );
  }

  static const _titleStyle = TextStyle(
    color: Colors.white,
    fontSize: 21,
    fontWeight: FontWeight.w600,
  );

}