import 'package:flutter/cupertino.dart' show StatelessWidget;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_travel/presentation/blocs/payment/payment_bloc.dart';
import 'package:smart_travel/presentation/blocs/payment/payment_event.dart';
import 'package:smart_travel/presentation/blocs/payment/payment_state.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';
import 'package:smart_travel/presentation/widgets/common/custom_button.dart'; // File PrimaryButton
import 'package:webview_flutter/webview_flutter.dart'; // THÊM package này

class PaymentScreen extends StatelessWidget {
  final String bookingId;
  final double amount;

  const PaymentScreen({
    Key? key,
    required this.bookingId,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format số tiền cho đẹp
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');
    final String formattedAmount = currencyFormatter.format(amount);

    return BlocProvider(
      create: (context) => PaymentBloc(), // TODO: Sau này sẽ inject UseCase
      child: Scaffold(
        appBar: AppBar(
          title: Text('Thanh toán'),
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textGray,
          elevation: 0,
        ),
        backgroundColor: AppColors.background,
        body: BlocConsumer<PaymentBloc, PaymentState>(
          listener: (context, state) {
            if (state is PaymentSuccess) {
              // KHI THÀNH CÔNG: Mở WebView để thanh toán
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VnPayWebView(url: state.paymentUrl),
                ),
              );
            } else if (state is PaymentFailure) {
              // KHI THẤT BẠI: Hiển thị lỗi
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng số tiền cần thanh toán:',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textGray,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        formattedAmount,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 32),
                      Text(
                        'Chọn phương thức thanh toán:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textGray,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Nút thanh toán VNPay
                      _buildPaymentMethodTile(
                        context: context,
                        logoAsset: 'assets/images/vnpay_logo.png', // BẠN CẦN THÊM ẢNH NÀY
                        title: 'Thanh toán qua VNPay',
                        onTap: () {
                          // Gửi event cho PaymentBloc
                          context.read<PaymentBloc>().add(
                            ProcessPaymentSubmitted(
                              bookingId: bookingId,
                              amount: amount,
                              paymentMethod: 'VNPAY',
                            ),
                          );
                        },
                      ),
                      // TODO: Thêm các phương thức khác như Momo, Thẻ...
                    ],
                  ),
                ),
                // Hiển thị loading đè lên
                if (state is PaymentLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Widget riêng cho nút chọn phương thức thanh toán
  Widget _buildPaymentMethodTile({
    required BuildContext context,
    required String logoAsset,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Image.asset(
              logoAsset,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.payment, size: 40, color: AppColors.primary),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGray,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey.shade600, size: 16),
          ],
        ),
      ),
    );
  }
}

// --- TẠO MÀN HÌNH WEBVIEW RIÊNG ---
// (Bạn có thể tạo file riêng cho file này)
class VnPayWebView extends StatefulWidget {
  final String url;
  const VnPayWebView({Key? key, required this.url}) : super(key: key);

  @override
  State<VnPayWebView> createState() => _VnPayWebViewState();
}

class _VnPayWebViewState extends State<VnPayWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() { _isLoading = true; });
          },
          onPageFinished: (String url) {
            setState(() { _isLoading = false; });
          },
          // TODO: Lắng nghe URL trả về (vnp_ReturnUrl)
          onNavigationRequest: (NavigationRequest request) {
            // Đây là URL bạn cấu hình trong VnPayConfig.java
            if (request.url.startsWith('http://localhost:8080/api/v1/payment/vnpay-return')) {
              print('Thanh toán thành công (hoặc thất bại), trở về app');
              // TODO: Xử lý kết quả thanh toán
              Navigator.popUntil(context, (route) => route.isFirst); // Đóng WebView
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cổng thanh toán')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ],
      ),
    );
  }
}