import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/presentation/blocs/booking/booking_bloc.dart';
import 'package:smart_travel/presentation/blocs/booking/booking_event.dart';
import 'package:smart_travel/presentation/blocs/booking/booking_state.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/presentation/widgets/common/custom_button.dart';
import 'package:smart_travel/presentation/screens/payment/payment_screen.dart';
import 'package:smart_travel/injection_container.dart' as di; // Import DI

final DestinationEntity mockDestination = DestinationEntity(
  id: 1,
  name: 'Vé tham quan Vịnh Hạ Long',
  province: 'Quảng Ninh',
  entryFee: 300000.0,
  averageRating: 4.8,
  imageUrl: 'assets/images/img_1.png',
  reviewCount: 120,
  viewCount: 5000,
  isActive: true,
  isFeatured: true,
);

class BookingScreen extends StatefulWidget {
  // final DestinationEntity destination; // Nên dùng cái này
  const BookingScreen({Key? key /* required this.destination */}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController _couponController = TextEditingController();
  DateTime _startDate = DateTime.now();
  int _numberOfPeople = 1;

  // (Các hàm _selectDate và _selectNumberOfPeople giữ nguyên)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textGray,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startDate) {
      setState(() { _startDate = picked; });
    }
  }

  void _selectNumberOfPeople(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext modalContext, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Chọn số lượng vé',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textGray,
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: AppColors.primary, size: 30),
                        onPressed: () {
                          if (_numberOfPeople > 1) {
                            setModalState(() {
                              _numberOfPeople--;
                            });
                            setState(() {});
                          }
                        },
                      ),
                      SizedBox(width: 20),
                      Text(
                        '$_numberOfPeople',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 20),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: AppColors.primary, size: 30),
                        onPressed: () {
                          setModalState(() {
                            _numberOfPeople++;
                          });
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  Spacer(),
                  PrimaryButton(
                    text: 'Xác nhận',
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                  ),
                  SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }
  // --- HẾT HÀM KHÔNG SỬA ---


  @override
  Widget build(BuildContext context) {
    // --- SỬA: THÊM LẠI BLOCPROVIDER VÀ BLOCCONSUMER ---
    return BlocProvider(
      create: (context) => di.sl<BookingBloc>(), // Lấy BLoC từ DI
      child: Scaffold(
        appBar: AppBar(
          title: Text('Xác nhận Đặt chỗ'),
          backgroundColor: AppColors.background,
          elevation: 0,
          foregroundColor: AppColors.textGray,
        ),
        backgroundColor: AppColors.background,
        body: BlocConsumer<BookingBloc, BookingState>(
          listener: (context, state) {
            // Lắng nghe state
            if (state is BookingCreationSuccess) {
              // --- SỬA: CHỈ ĐIỀU HƯỚNG KHI TẠO BOOKING THÀNH CÔNG ---
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentScreen(
                    // Lấy ID và Amount thật từ BLoC
                    bookingId: state.bookingId,
                    amount: state.amount,
                  ),
                ),
              );
            } else if (state is BookingFailure) {
              // Hiển thị lỗi nếu tạo booking thất bại
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            // Truyền state vào để hiển thị loading
            return _buildBookingForm(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildBookingForm(BuildContext context, BookingState state) {
    final DestinationEntity destination = mockDestination;
    final priceString = '${destination.entryFee?.toInt() ?? 0} VND';
    final double totalPrice = (destination.entryFee ?? 0.0) * _numberOfPeople;

    return Stack( // Thêm Stack để hiển thị loading
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // (Phần UI (Ảnh, Tên, Địa điểm,...) giữ nguyên)
              if (destination.imageUrl != null && destination.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    destination.imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, color: Colors.grey),
                              Text('Không tìm thấy ảnh tại:'),
                              Text(destination.imageUrl!, textAlign: TextAlign.center, style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 24),
              Text(destination.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textGray)),
              SizedBox(height: 16),
              _buildInfoRow(icon: Icons.location_on_outlined, title: 'Địa điểm', value: destination.province),
              SizedBox(height: 8),
              _buildInfoRow(icon: Icons.price_change_outlined, title: 'Giá vé', value: '$priceString / người'),
              SizedBox(height: 24),
              Text('Chi tiết đặt chỗ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textGray)),
              SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.date_range,
                title: 'Ngày sử dụng',
                value: DateFormat('dd/MM/yyyy').format(_startDate),
                isSelectable: true,
                onTap: () => _selectDate(context),
              ),
              SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.people_outline,
                title: 'Số lượng vé',
                value: '$_numberOfPeople người',
                isSelectable: true,
                onTap: () => _selectNumberOfPeople(context),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _couponController,
                decoration: InputDecoration(
                  labelText: 'Mã giảm giá (nếu có)',
                  // (style decoration giữ nguyên)
                  labelStyle: TextStyle(color: AppColors.textGray),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary)),
                ),
              ),
              SizedBox(height: 32),
              _buildPriceDetailRow('Giá tạm tính (1 người)', priceString),
              SizedBox(height: 8),
              _buildPriceDetailRow('Giảm giá', '0 VND'),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tổng cộng:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textGray)),
                  Text(
                    '${totalPrice.toInt()} VND',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
              SizedBox(height: 24),
              // --- HẾT PHẦN UI GIỮ NGUYÊN ---

              // --- SỬA LOGIC NÚT BẤM ---
              PrimaryButton(
                text: 'Tiến hành Thanh toán',
                isLoading: state is BookingLoading, // Hiển thị loading
                onPressed: (state is BookingLoading) ? null : () { // Vô hiệu hóa khi loading

                  // --- SỬA THEO Ý BẠN: Gửi "tourId" ---
                  // Chúng ta hardcode "1" ở đây, vì mockDestination.id là 1
                  // (Sau này bạn sẽ thay bằng tour.id thật)
                  String tourId = "1";
                  // ------------------------------------

                  context.read<BookingBloc>().add(
                    CreateBookingSubmitted(
                      tourId: tourId, // Gửi tourId
                      startDate: _startDate,
                      numberOfPeople: _numberOfPeople,
                      totalPrice: totalPrice,
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // Hiển thị lớp phủ loading
        if (state is BookingLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
      ],
    );
  }

  // ... (_buildInfoRow, _buildPriceDetailRow giữ nguyên)
  Widget _buildInfoRow({ required IconData icon, required String title, required String value, bool isSelectable = false, VoidCallback? onTap }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            SizedBox(width: 12),
            Text('$title:', style: TextStyle(fontSize: 16, color: AppColors.textGray)),
            SizedBox(width: 8),
            Expanded(
              child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textGray), textAlign: TextAlign.right),
            ),
            if (isSelectable) Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
  Widget _buildPriceDetailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
        Text(value, style: TextStyle(fontSize: 16, color: AppColors.textGray)),
      ],
    );
  }
}