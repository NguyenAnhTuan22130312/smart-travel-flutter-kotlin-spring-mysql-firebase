import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/injection_container.dart' as di;
import 'package:smart_travel/presentation/blocs/invoice/cancel_bloc.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';

import '../../../router/route_names.dart';
import '../../blocs/invoice/cancel_event.dart';
import '../../blocs/invoice/cancel_state.dart';

class CancelFormScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const CancelFormScreen({Key? key, required this.bookingData}) : super(key: key);

  @override
  State<CancelFormScreen> createState() => _CancelFormScreenState();
}

class _CancelFormScreenState extends State<CancelFormScreen> {
  final TextEditingController _reasonController = TextEditingController();
  bool _agreeTerms = false;

  String _formatDate(String date) {
    List<String> parts = date.split('-');
    return "${parts[2]}/${parts[1]}/${parts[0]}";
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey[50],
      body: BlocProvider(
        create: (_) => di.sl<CancelBloc>(),
        child: Column(
          children: [
            // HEADER
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
                    "Biểu mẫu hủy đặt chỗ",
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
              child: BlocConsumer<CancelBloc, CancelState>(
                listener: (context, state) {
                  if (state is CancelSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Yêu cầu hủy đã được gửi thành công!"),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      RouteNames.myInvoices,
                          (route) => false,
                    );
                  }
                  if (state is CancelError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return ListView(
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
                              widget.bookingData['itemName'],
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "${_formatDate(widget.bookingData['startDate'])} · ${widget.bookingData['nights']} đêm",
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
                                  "Mã đặt chỗ: ${widget.bookingData['invoiceNumber']}",
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        "Vui lòng cho chúng tôi biết lý do hủy đặt chỗ (tùy chọn)",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _reasonController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: "Ví dụ: Thay đổi lịch trình, lý do cá nhân...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // TUYÊN BỐ + CHECKBOX
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: const Text(
                          "Tuyên bố người dùng",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.6),
                                children: [
                                  const TextSpan(text: "Khi nhấp vào \"Xác nhận hủy đặt chỗ\", tôi xác nhận rằng tôi đã đọc và đồng ý với các "),
                                  TextSpan(
                                    text: "Điều khoản & Điều kiện của Chính sách Hủy phòng",
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(text: ". Tôi hiểu rằng phiếu xác nhận đã xuất trước đó cho đặt phòng này sẽ mất hiệu lực."),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _agreeTerms,
                                    onChanged: (value) {
                                      setState(() {
                                        _agreeTerms = value ?? false;
                                      });
                                    },
                                    activeColor: AppColors.primary,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    "Có, tôi đồng ý",
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // NÚT XÁC NHẬN HỦY
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _agreeTerms && state is! CancelLoading
                              ? () {
                            context.read<CancelBloc>().add(
                              SubmitCancelRequest(
                                bookingId: widget.bookingData['bookingId'],
                                reason: _reasonController.text.trim().isEmpty
                                    ? "Không có lý do"
                                    : _reasonController.text.trim(),
                              ),
                            );
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            disabledBackgroundColor: Colors.red[200],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: state is CancelLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                              : const Text(
                            "Xác nhận hủy đặt chỗ",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
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
}