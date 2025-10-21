import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_travel/presentation/blocs/payment/payment_bloc.dart';
import 'package:smart_travel/presentation/blocs/payment/payment_event.dart';
import 'package:smart_travel/presentation/blocs/payment/payment_state.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';
import 'package:smart_travel/presentation/widgets/common/custom_button.dart'; // File PrimaryButton
import 'package:webview_flutter/webview_flutter.dart';

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
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');
    final String formattedAmount = currencyFormatter.format(amount);

    return BlocProvider(
      create: (context) => PaymentBloc(), // TODO: Sẽ inject UseCase sau
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
              // Mở WebView cho VNPay/MoMo
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentWebView(url: state.paymentUrl),
                ),
              );
            } else if (state is PaymentCashSuccess) {
              // SỬA LỖI: Xử lý khi thanh toán tiền mặt thành công
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đặt chỗ thành công! Bạn sẽ thanh toán sau.'),
                  backgroundColor: Colors.green,
                ),
              );
              // Quay về màn hình Home (đóng cả BookingScreen và PaymentScreen)
              Navigator.popUntil(context, (route) => route.isFirst);
            } else if (state is PaymentFailure) {
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

                      _buildPaymentMethodTile(
                        context: context,
                        logoAsset: 'assets/images/vnpay_logo.png', // CẦN THÊM ẢNH
                        title: 'Thanh toán qua VNPay',
                        onTap: () {
                          context.read<PaymentBloc>().add(
                            ProcessPaymentSubmitted(
                              bookingId: bookingId,
                              amount: amount,
                              paymentMethod: 'VNPAY',
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 12),

                      // THÊM MỚI: Nút MoMo
                      _buildPaymentMethodTile(
                        context: context,
                        logoAsset: 'assets/images/momo_logo.png', // CẦN THÊM ẢNH
                        title: 'Thanh toán qua MoMo',
                        onTap: () {
                          context.read<PaymentBloc>().add(
                            ProcessPaymentSubmitted(
                              bookingId: bookingId,
                              amount: amount,
                              paymentMethod: 'MOMO',
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 12),

                      // THÊM MỚI: Nút Thanh toán trực tiếp
                      _buildPaymentMethodTile(
                        context: context,
                        logoAsset: 'assets/images/cash_logo.png', // CẦN THÊM ẢNH
                        title: 'Thanh toán trực tiếp',
                        onTap: () {
                          context.read<PaymentBloc>().add(
                            ConfirmCashPayment(
                              bookingId: bookingId,
                              amount: amount,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
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

// Màn hình WebView (Không đổi)
class PaymentWebView extends StatefulWidget {
  final String url;
  const PaymentWebView({Key? key, required this.url}) : super(key: key);

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() { _isLoading = true; });
          },
          onPageFinished: (String url) {
            setState(() { _isLoading = false; });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Đây là URL backend của bạn
            if (request.url.startsWith('http://localhost:8080/api/v1/payment/vnpay-return')) {
              print('Thanh toán hoàn tất, quay về app');
              // Quay về màn hình Home
              Navigator.popUntil(context, (route) => route.isFirst);
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