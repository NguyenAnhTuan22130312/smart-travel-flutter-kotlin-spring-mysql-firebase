import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_travel/injection_container.dart' as di;
import 'package:smart_travel/presentation/blocs/admin_invoice/admin_invoice_detail_bloc.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';

import '../../../../domain/entities/admin_invoice_detail.dart';
import '../../../../domain/usecases/invoice/admin_approve_refund_usecase.dart';
import '../../../../domain/usecases/invoice/admin_cancel_order_usecase.dart';
import '../../../../domain/usecases/invoice/admin_check_in_usecase.dart';
import '../../../../domain/usecases/invoice/admin_check_out_usecase.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';

class AdminInvoiceDetailScreen extends StatelessWidget {
  final int bookingId;

  const AdminInvoiceDetailScreen({Key? key, required this.bookingId}) : super(key: key);

  // --- HELPERS ---

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return "";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatPrice(double? price) {
    if (price == null) return "0 ₫";
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return currencyFormatter.format(price);
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE': return const Color(0xFF00C853);
      case 'CHECKED': return const Color(0xFF2962FF);
      case 'COMPLETED': return const Color(0xFF009688);
      case 'PENDING_REFUND': return const Color(0xFFFF6D00);
      case 'REFUNDED': return const Color(0xFFAA00FF);
      case 'CANCELED': return const Color(0xFFD50000);
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE': return "Đang hoạt động";
      case 'CHECKED': return "Đã check-in";
      case 'COMPLETED': return "Đã hoàn thành";
      case 'PENDING_REFUND': return "Chờ hoàn tiền";
      case 'REFUNDED': return "Đã hoàn tiền";
      case 'CANCELED': return "Đã hủy";
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: BlocProvider(
        create: (_) => di.sl<AdminInvoiceDetailBloc>()..add(LoadAdminInvoiceDetail(bookingId)),
        child: BlocBuilder<AdminInvoiceDetailBloc, AdminInvoiceDetailState>(
          builder: (context, state) {
            if (state is AdminInvoiceDetailLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (state is AdminInvoiceDetailError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
                      const SizedBox(height: 24),
                      Text(
                        state.message,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Vui lòng kiểm tra lại mã QR hoặc liên hệ quản trị viên",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text("Quay lại"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is AdminInvoiceDetailLoaded) {
              final d = state.detail;
              bool isHotel = d.hotelId != null;

              // --- LOGIC HIỂN THỊ LÝ DO HỦY ---
              final showCancellationReason = ["PENDING_REFUND", "REFUNDED", "CANCELLED"].contains(d.status.toUpperCase()) &&
                  d.cancellationReason != null &&
                  d.cancellationReason!.isNotEmpty;

              // --- SỬ DỤNG COLUMN ĐỂ CHIA MÀN HÌNH: TRÊN LÀ LIST, DƯỚI LÀ NÚT ---
              return Column(
                children: [
                  // Phần 1: Nội dung cuộn (Chiếm hết khoảng trống còn lại)
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        // --- HEADER ---
                        SliverAppBar(
                          expandedHeight: 200.0,
                          pinned: true,
                          backgroundColor: AppColors.primary,
                          leading: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                          flexibleSpace: FlexibleSpaceBar(
                            background: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primary,
                                    Color.lerp(AppColors.primary, Colors.black, 0.2)!,
                                  ],
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 40),
                                  Text(
                                    "TỔNG THANH TOÁN",
                                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatPrice(d.finalPrice),
                                    style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _getStatusText(d.status).toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // --- BODY ---
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildInvoiceIdCard(d.invoiceNumber),
                                const SizedBox(height: 16),

                                if (showCancellationReason)
                                  _buildWarningCard(d.cancellationReason!),

                                _buildSectionTitle("DỊCH VỤ"),
                                _buildServiceCard(d, isHotel),
                                const SizedBox(height: 20),

                                _buildSectionTitle("KHÁCH HÀNG"),
                                _buildCustomerCard(d),
                                const SizedBox(height: 20),

                                _buildSectionTitle("CHI TIẾT THANH TOÁN"),
                                _buildPaymentCard(d),
                                const SizedBox(height: 24),

                                Column(
                                  children: [
                                    Text("Tạo lúc: ${_formatDateTime(d.createdAt)}", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text("Cập nhật: ${_formatDateTime(d.updatedAt)}", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 20), // Khoảng cách cuối cùng
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Phần 2: Thanh nút bấm chức năng (Nằm cố định ở đáy)
                  _buildBottomBar(context, d),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  bool _isOverdue(String? endDateStr) {
    if (endDateStr == null) return false;
    try {
      final endDate = DateTime.parse(endDateStr);
      final now = DateTime.now();
      // So sánh: Nếu hiện tại sau ngày kết thúc -> Quá hạn
      return now.isAfter(endDate);
      // Lưu ý: Nếu muốn tính hết ngày mới quá hạn thì dùng: endDate.add(Duration(days: 1))
    } catch (e) {
      return false;
    }
  }



  Widget _buildBottomBar(BuildContext context, AdminInvoiceDetail d) {
    // 1. Lấy role hiện tại từ AuthBloc
    final authState = context.read<AuthBloc>().state;
    String? currentRole;

    if (authState is LoginSuccess) {
      currentRole = authState.response.role;
    } else if (authState is AdminAuthenticated) {
      currentRole = authState.role;
    }

    // Nếu không có role → ẩn hết nút (an toàn)
    if (currentRole == null) {
      return const SizedBox.shrink();
    }

    // Phân quyền
    final bool isRootAdmin = currentRole == "ADMIN";
    final bool isHotelAdmin = currentRole == "ADMINHOTEL";
    final bool isTourAdmin = currentRole == "ADMINTOUR";
    final bool isAuthorizedAdmin = isHotelAdmin || isTourAdmin; // adminhotel hoặc admintour

    // Logic ngày quá hạn
    bool isOverdue = false;
    try {
      final endDate = DateTime.parse(d.endDate);
      final now = DateTime.now();
      if (now.isAfter(endDate)) isOverdue = true;
    } catch (e) {
      isOverdue = false;
    }

    final status = d.status.toUpperCase();

    // Logic hiển thị nút theo trạng thái đơn
    bool baseCheckIn = status == 'ACTIVE';
    bool baseCheckOut = status == 'CHECKED';
    bool baseRefund = status == 'PENDING_REFUND';
    bool baseCancel = status == 'ACTIVE' && isOverdue;

    // Áp dụng phân quyền
    bool showCheckIn = baseCheckIn && isAuthorizedAdmin;
    bool showCheckOut = baseCheckOut && isAuthorizedAdmin;
    bool showRefund = baseRefund && isAuthorizedAdmin;
    bool showCancel = baseCancel && (isRootAdmin || isAuthorizedAdmin); // root admin cũng được hủy

    if (!showCheckIn && !showCheckOut && !showRefund && !showCancel) {
      return const SizedBox.shrink();
    }

    // Helper confirm dialog
    Future<bool> _confirm(String title, String content) async {
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Xác nhận", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      return result ?? false;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // DUYỆT HOÀN TIỀN - chỉ adminhotel/admintour
            if (showRefund)
              Expanded(
                child: _buildActionButton(
                  label: "Duyệt hoàn tiền",
                  icon: Icons.price_check,
                  color: Colors.orange,
                  onPressed: () async {
                    final confirm = await _confirm("Duyệt hoàn tiền", "Bạn chắc chắn muốn duyệt hoàn tiền cho đơn hàng này?");
                    if (!confirm) return;

                    try {
                      await di.sl<AdminApproveRefundUseCase>()(bookingId: d.bookingId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Duyệt hoàn tiền thành công!"), backgroundColor: Colors.green),
                      );
                      context.read<AdminInvoiceDetailBloc>().add(LoadAdminInvoiceDetail(d.bookingId));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
                      );
                    }
                  },
                ),
              ),

            if (showRefund && (showCheckOut || showCheckIn || showCancel)) const SizedBox(width: 12),

            // CHECK-OUT - chỉ adminhotel/admintour
            if (showCheckOut)
              Expanded(
                child: _buildActionButton(
                  label: "Check-out",
                  icon: Icons.logout,
                  color: Colors.teal,
                  onPressed: () async {
                    final confirm = await _confirm("Check-out", "Xác nhận khách đã trả phòng và hoàn tất đơn hàng?");
                    if (!confirm) return;

                    try {
                      await di.sl<AdminCheckOutUseCase>()(bookingId: d.bookingId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Check-out thành công!"), backgroundColor: Colors.green),
                      );
                      context.read<AdminInvoiceDetailBloc>().add(LoadAdminInvoiceDetail(d.bookingId));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
                      );
                    }
                  },
                ),
              ),

            if (showCheckOut && (showCheckIn || showCancel)) const SizedBox(width: 12),

            // CHECK-IN - chỉ adminhotel/admintour
            if (showCheckIn)
              Expanded(
                child: _buildActionButton(
                  label: "Check-in",
                  icon: Icons.login,
                  color: Colors.blue,
                  onPressed: () async {
                    // Phân biệt Hotel hay Tour
                    final isHotel = d.hotelId != null;

                    if (isHotel) {
                      // Hotel: nhập số phòng bằng TextField
                      final roomsCtrl = TextEditingController();
                      final selectedRoomsStr = await showDialog<String>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Check-in: Nhập số phòng"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Số phòng khách đã nhận:"),
                              const SizedBox(height: 8),
                              TextField(
                                controller: roomsCtrl,
                                keyboardType: TextInputType.number,
                                autofocus: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  hintText: "Ví dụ: 2",
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
                            TextButton(
                              onPressed: () {
                                final text = roomsCtrl.text.trim();
                                if (text.isEmpty) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(content: Text("Vui lòng nhập số phòng")),
                                  );
                                } else {
                                  Navigator.pop(ctx, text);
                                }
                              },
                              child: const Text("Xác nhận"),
                            ),
                          ],
                        ),
                      );

                      if (selectedRoomsStr == null) return;

                      final selectedRooms = int.tryParse(selectedRoomsStr);
                      if (selectedRooms == null || selectedRooms <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Số phòng phải là số nguyên dương")),
                        );
                        return;
                      }

                      final confirm = await _confirm(
                        "Check-in",
                        "Check-in phòng $selectedRooms cho khách?",
                      );
                      if (!confirm) return;

                      try {
                        await di.sl<AdminCheckInUseCase>()(
                          bookingId: d.bookingId,
                          numberOfRooms: selectedRooms,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Check-in thành công!"), backgroundColor: Colors.green),
                        );
                        context.read<AdminInvoiceDetailBloc>().add(LoadAdminInvoiceDetail(d.bookingId));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
                        );
                      }
                    } else {
                      // Tour: bấm là check-in luôn
                      final confirm = await _confirm(
                        "Check-in",
                        "Xác nhận khách đã có mặt và bắt đầu tour?",
                      );
                      if (!confirm) return;

                      try {
                        await di.sl<AdminCheckInUseCase>()(bookingId: d.bookingId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Check-in thành công!"), backgroundColor: Colors.green),
                        );
                        context.read<AdminInvoiceDetailBloc>().add(LoadAdminInvoiceDetail(d.bookingId));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                ),
              ),

            if (showCheckIn && showCancel) const SizedBox(width: 12),

            // HỦY ĐƠN - root admin + adminhotel + admintour
            if (showCancel)
              Expanded(
                child: _buildActionButton(
                  label: "Hủy đơn",
                  icon: Icons.cancel_presentation,
                  color: Colors.red,
                  isOutlined: showCheckIn || showCheckOut || showRefund,
                  onPressed: () async {
                    final reasonCtrl = TextEditingController();
                    final reason = await showDialog<String>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Lý do hủy đơn"),
                        content: TextField(
                          controller: reasonCtrl,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: "Ví dụ: khách không đến đúng giờ, yêu cầu hủy...",
                          ),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
                          TextButton(
                            onPressed: () {
                              final text = reasonCtrl.text.trim();
                              if (text.isEmpty) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(content: Text("Vui lòng nhập lý do")),
                                );
                              } else {
                                Navigator.pop(ctx, text);
                              }
                            },
                            child: const Text("Gửi"),
                          ),
                        ],
                      ),
                    );

                    if (reason == null || reason.isEmpty) return;

                    final confirm = await _confirm(
                      "Hủy đơn hàng",
                      "Bạn chắc chắn muốn hủy đơn này?\nLý do: $reason",
                    );
                    if (!confirm) return;

                    try {
                      await di.sl<AdminCancelOrderUseCase>()(
                        bookingId: d.bookingId,
                        cancelMessage: reason,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Hủy đơn thành công!"), backgroundColor: Colors.green),
                      );
                      context.read<AdminInvoiceDetailBloc>().add(LoadAdminInvoiceDetail(d.bookingId));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
                      );
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget vẽ nút (Giữ nguyên, nhưng thêm shadow đậm hơn chút cho nổi)
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    return Container(
      // Thêm shadow riêng cho từng nút để tạo cảm giác nổi 3D trên nền xám
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.white : color,
          foregroundColor: isOutlined ? color : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16), // Nút cao hơn chút cho dễ bấm
          elevation: 0, // Tắt shadow mặc định của button để dùng shadow custom bên trên (hoặc để 0 cho phẳng)
          side: isOutlined ? BorderSide(color: color, width: 2) : BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // --- COMPONENTS ---

  Widget _buildSectionTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildInvoiceIdCard(String invoiceNumber) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Mã đơn hàng", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
          SelectableText(
            invoiceNumber,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(dynamic d, bool isHotel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isHotel ? Colors.blue[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isHotel ? Icons.hotel_rounded : Icons.tour_rounded,
                    color: isHotel ? Colors.blue : Colors.orange,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.serviceName ?? "Dịch vụ không tên",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                      ),
                      if (d.roomTypeName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            d.roomTypeName!,
                            style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: _buildInfoColumn(Icons.calendar_today_rounded, "Check-in", _formatDate(d.startDate))),
                Container(width: 1, height: 30, color: Colors.grey[200]),
                Expanded(child: _buildInfoColumn(Icons.event_available_rounded, "Check-out", _formatDate(d.endDate))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIconText(Icons.people_alt_rounded, "${d.numberOfPeople ?? 1} Khách"),
                  if (d.numberOfRooms != 0)
                    _buildIconText(Icons.door_front_door_rounded, "Phòng số: ${d.numberOfRooms}"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(dynamic d) {
    // Logic kiểm tra yêu cầu đặc biệt
    final bool hasSpecialRequest = d.specialRequests != null && d.specialRequests!.isNotEmpty;
    final String requestText = hasSpecialRequest ? d.specialRequests! : "Không có yêu cầu đặc biệt";
    final Color requestColor = hasSpecialRequest ? Colors.black87 : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  (d.customerName != null && d.customerName.isNotEmpty) ? d.customerName![0].toUpperCase() : "K",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.customerName ?? "Không rõ tên", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(d.customerEmail ?? "Không có email", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow(Icons.phone_iphone_rounded, "Số điện thoại", d.customerPhone ?? "N/A"),

          // --- LUÔN HIỂN THỊ DÒNG NÀY ---
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.notes_rounded, size: 20, color: hasSpecialRequest ? Colors.orange[400] : Colors.grey[400]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Yêu cầu khách hàng:", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text(
                      requestText,
                      style: TextStyle(
                          fontStyle: hasSpecialRequest ? FontStyle.italic : FontStyle.normal,
                          color: requestColor,
                          fontSize: 14
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPaymentCard(dynamic d) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          _buildPriceRow("Tổng tiền dịch vụ", _formatPrice(d.totalPrice)),
          if ((d.discountAmount ?? 0) > 0)
            _buildPriceRow("Giảm giá / Voucher", "- ${_formatPrice(d.discountAmount)}", color: Colors.green),
          if ((d.taxAmount ?? 0) > 0)
            _buildPriceRow("Thuế & Phí", "+ ${_formatPrice(d.taxAmount)}"),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(thickness: 1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Thực thu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(_formatPrice(d.finalPrice), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.payment, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                    "Thanh toán: ${d.paymentStatus ?? 'N/A'}",
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800], fontSize: 13)
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWarningCard(String reason) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.red[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Ghi chú / Lý do hủy", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[800], fontSize: 14)),
                const SizedBox(height: 4),
                Text(reason, style: TextStyle(color: Colors.red[900], fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers UI nhỏ ---

  Widget _buildInfoColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String price, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(price, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color ?? Colors.black87)),
        ],
      ),
    );
  }
}