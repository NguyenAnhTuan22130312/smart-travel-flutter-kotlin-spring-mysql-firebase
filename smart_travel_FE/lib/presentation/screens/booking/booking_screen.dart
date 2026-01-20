import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:smart_travel/domain/entities/province.dart';
import 'package:smart_travel/domain/entities/voucher.dart'; // Import Voucher Entity
import 'package:smart_travel/presentation/blocs/booking/booking_bloc.dart';
import 'package:smart_travel/presentation/blocs/booking/booking_event.dart';
import 'package:smart_travel/presentation/blocs/booking/booking_state.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';
import 'package:smart_travel/presentation/widgets/common/custom_button.dart';
import 'package:smart_travel/presentation/screens/payment/payment_screen.dart';
import 'package:smart_travel/injection_container.dart' as di;
import 'package:smart_travel/presentation/screens/booking/booking_args.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_bloc.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_state.dart';
// Import file Modal mới
import 'voucher_selection_modal.dart';

class BookingScreen extends StatefulWidget {
  final BookingArgs args;

  const BookingScreen({Key? key, required this.args}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController _couponController = TextEditingController();

  // State cho Tour
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));

  // State cho Hotel
  DateTimeRange? _dateRange;

  int _numberOfPeople = 1;
  int _numberOfRooms = 1;

  double _discountAmount = 0;
  bool _isCheckingVoucher = false;
  bool _isVoucherApplied = false;

  void _openVoucherModal() async {
    // 1. Lấy user ID từ Profile Bloc (như đã làm trước đó)
    final profileState = context.read<ProfileBloc>().state;
    int? userId;
    if (profileState is ProfileLoaded) userId = profileState.user.id;
    else if (profileState is ProfileUpdateSuccess) userId = profileState.user.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng đăng nhập để dùng voucher"), backgroundColor: Colors.red));
      return;
    }

    // 2. Mở Modal chọn Voucher
    final Voucher? result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoucherSelectionModal(userId: userId!),
    );

    if (result != null) {
      // --- TÍNH TOÁN TỔNG TIỀN HIỆN TẠI ĐỂ SO SÁNH ---
      double currentTotal = 0;
      if (widget.args.bookingType == 'TOUR') {
        currentTotal = widget.args.price * _numberOfPeople;
      } else {
        int nights = 1;
        if (_dateRange != null) {
          nights = _dateRange!.end.difference(_dateRange!.start).inDays;
          if (nights < 1) nights = 1;
        }
        currentTotal = widget.args.price * _numberOfRooms * nights;
      }

      // --- KIỂM TRA: NẾU VOUCHER > TỔNG TIỀN ---
      if (result.discountAmount > currentTotal) {
        // Hiện cảnh báo xác nhận
        bool? confirm = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Lưu ý", style: TextStyle(color: Colors.orange)),
            content: Text(
              "Voucher giảm ${NumberFormat('#,###').format(result.discountAmount)}đ lớn hơn giá trị đơn hàng (${NumberFormat('#,###').format(currentTotal)}đ).\n\n"
                  "Nếu áp dụng, bạn sẽ KHÔNG được hoàn lại phần tiền thừa.\nBạn có chắc chắn muốn dùng?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false), // Hủy
                child: const Text("Chọn mã khác", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () => Navigator.pop(ctx, true), // Đồng ý chịu lỗ
                child: const Text("Vẫn dùng", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );

        // Nếu người dùng chọn "Hủy" hoặc bấm ra ngoài -> Không áp dụng
        if (confirm != true) return;
      }

      // --- ÁP DỤNG VOUCHER (Nếu hợp lệ hoặc người dùng đã đồng ý) ---
      setState(() {
        _couponController.text = result.code;
        _discountAmount = result.discountAmount.toDouble();
        _isVoucherApplied = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã áp dụng mã: ${result.code}"), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _checkCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isCheckingVoucher = true);

    try {
      final response = await Dio().get(
        'http://10.0.2.2:8080/api/v1/vouchers/check',
        queryParameters: {'code': code},
      );

      if (response.statusCode == 200) {
        final double discount = response.data['discountAmount'];
        setState(() {
          _discountAmount = discount;
          _isVoucherApplied = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Áp dụng mã thành công!"), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      String msg = "Mã không hợp lệ hoặc đã hết hạn";
      if (e is DioException && e.response != null) {
        msg = e.response?.data['message'] ?? msg;
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red)
      );
      setState(() {
        _discountAmount = 0;
        _isVoucherApplied = false;
      });
    } finally {
      setState(() => _isCheckingVoucher = false);
    }
  }

  Future<void> _handleDateSelection(BuildContext context) async {
    if (widget.args.bookingType == 'TOUR') {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _startDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2101),
        builder: (context, child) => _buildThemePicker(context, child),
      );
      if (picked != null && picked != _startDate) {
        setState(() { _startDate = picked; });
      }
    } else {
      final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime(2101),
        builder: (context, child) => _buildThemePicker(context, child),
      );
      if (picked != null) {
        setState(() { _dateRange = picked; });
      }
    }
  }

  Widget _buildThemePicker(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          onSurface: AppColors.textGray,
        ),
      ),
      child: child!,
    );
  }

  void _showQuantityModal(BuildContext context, String title, int currentValue, Function(int) onChanged) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        int tempValue = currentValue;
        return StatefulBuilder(
          builder: (BuildContext modalContext, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.3,
              child: Column(
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textGray)),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: AppColors.primary, size: 30),
                        onPressed: () {
                          if (tempValue > 1) setModalState(() => tempValue--);
                        },
                      ),
                      const SizedBox(width: 20),
                      Text('$tempValue', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: AppColors.primary, size: 30),
                        onPressed: () => setModalState(() => tempValue++),
                      ),
                    ],
                  ),
                  const Spacer(),
                  PrimaryButton(
                    text: 'Xác nhận',
                    onPressed: () {
                      onChanged(tempValue);
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<BookingBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.args.bookingType == 'TOUR' ? 'Đặt Tour' : 'Đặt Khách sạn'),
          backgroundColor: AppColors.background,
          elevation: 0,
          foregroundColor: AppColors.textGray,
        ),
        backgroundColor: AppColors.background,
        body: BlocConsumer<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state is BookingCreationSuccess) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen(
                bookingId: state.bookingId,
                amount: state.amount,
              )));
            } else if (state is BookingFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) => _buildBookingForm(context, state),
        ),
      ),
    );
  }

  Widget _buildBookingForm(BuildContext context, BookingState state) {
    final bool isTour = widget.args.bookingType == 'TOUR';
    final formatter = NumberFormat('#,###');
    double totalPrice = 0;
    if (isTour) {
      totalPrice = widget.args.price * _numberOfPeople;
    } else {
      int nights = 1;
      if (_dateRange != null) {
        nights = _dateRange!.end.difference(_dateRange!.start).inDays;
        if (nights < 1) nights = 1;
      }
      totalPrice = widget.args.price * _numberOfRooms * nights;
    }

    double finalPrice = totalPrice - _discountAmount;
    if (finalPrice < 0) finalPrice = 0;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.args.imageUrl,
                  width: double.infinity, height: 200, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200, color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(widget.args.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textGray)),
              const SizedBox(height: 8),
              _buildInfoRow(
                  icon: Icons.monetization_on_outlined,
                  title: 'Đơn giá',
                  value: '${formatter.format(widget.args.price)} VND / ${isTour ? 'người' : 'đêm'}'
              ),

              const SizedBox(height: 24),
              Text('Chi tiết đặt chỗ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textGray)),
              const SizedBox(height: 16),

              _buildInfoRow(
                icon: Icons.date_range,
                title: isTour ? 'Ngày khởi hành' : 'Thời gian lưu trú',
                value: isTour
                    ? DateFormat('dd/MM/yyyy').format(_startDate)
                    : (_dateRange == null ? "Chọn ngày" : "${DateFormat('dd/MM').format(_dateRange!.start)} - ${DateFormat('dd/MM').format(_dateRange!.end)}"),
                isSelectable: true,
                onTap: () => _handleDateSelection(context),
              ),
              const SizedBox(height: 16),

              if (isTour) ...[
                _buildInfoRow(
                  icon: Icons.people_outline,
                  title: 'Số lượng người',
                  value: '$_numberOfPeople người',
                  isSelectable: true,
                  onTap: () => _showQuantityModal(context, "Chọn số người", _numberOfPeople, (val) => setState(() => _numberOfPeople = val)),
                ),
                const SizedBox(height: 16),
              ],

              if (!isTour) ...[
                _buildInfoRow(
                  icon: Icons.bedroom_parent_outlined,
                  title: 'Số lượng phòng',
                  value: '$_numberOfRooms phòng',
                  isSelectable: true,
                  onTap: () => _showQuantityModal(context, "Chọn số phòng", _numberOfRooms, (val) => setState(() => _numberOfRooms = val)),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _couponController,
                      enabled: !_isVoucherApplied,
                      decoration: InputDecoration(
                        labelText: 'Mã giảm giá',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        // Nút mở Modal
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.confirmation_number_outlined, color: Colors.orange),
                          tooltip: "Chọn Voucher của bạn",
                          onPressed: _isVoucherApplied ? null : _openVoucherModal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isVoucherApplied
                          ? () => setState(() { _isVoucherApplied = false; _discountAmount = 0; _couponController.clear(); })
                          : (_isCheckingVoucher ? null : _checkCoupon),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isVoucherApplied ? Colors.red.shade100 : AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isCheckingVoucher
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(_isVoucherApplied ? "Hủy" : "Áp dụng", style: TextStyle(color: _isVoucherApplied ? Colors.red : Colors.white)),
                    ),
                  )
                ],
              ),


              const SizedBox(height: 32),

              _buildPriceDetailRow('Tạm tính', '${formatter.format(totalPrice)} VND'),
              const SizedBox(height: 8),
              if (_discountAmount > 0)
                _buildPriceDetailRow('Giảm giá', '- ${formatter.format(_discountAmount)} VND', color: Colors.green),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tổng cộng:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textGray)),
                  Text('${formatter.format(finalPrice)} VND', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Tiến hành Thanh toán',
                isLoading: state is BookingLoading,
                onPressed: (state is BookingLoading) ? null : () {
                  if (!isTour && _dateRange == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn ngày lưu trú")));
                    return;
                  }
                  context.read<BookingBloc>().add(
                    CreateBookingSubmitted(
                      bookingType: widget.args.bookingType,
                      id: widget.args.id,
                      startDate: isTour ? _startDate : _dateRange!.start,
                      endDate: isTour ? null : _dateRange!.end,
                      numberOfPeople: _numberOfPeople,
                      numberOfRooms: isTour ? 0 : _numberOfRooms,
                      couponCode: _isVoucherApplied ? _couponController.text.trim() : null,
                      roomTypeId: widget.args.roomTypeId,
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),

        if (state is BookingLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          ),
      ],
    );
  }

  Widget _buildInfoRow({required IconData icon, required String title, required String value, bool isSelectable = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Text('$title:', style: TextStyle(fontSize: 16, color: AppColors.textGray)),
            const SizedBox(width: 8),
            Expanded(child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textGray), textAlign: TextAlign.right)),
            if (isSelectable) const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDetailRow(String title, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
        Text(value, style: TextStyle(fontSize: 16, color: color ?? AppColors.textGray, fontWeight: color != null ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}