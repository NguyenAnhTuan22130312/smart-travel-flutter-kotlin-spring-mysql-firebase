import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart' hide Marker;
import 'package:smart_travel/domain/entities/hotel.dart';
import 'package:smart_travel/domain/entities/room_type.dart'; // Import RoomType
import 'package:smart_travel/presentation/blocs/hotel/hotel_detail_bloc.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_detail_event.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_detail_state.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';
import 'package:smart_travel/presentation/widgets/hotel/hotel_image_carousel_sliver.dart';
import 'package:smart_travel/presentation/widgets/hotel/hotel_info_section.dart';
import 'package:smart_travel/presentation/widgets/hotel/hotel_map.dart';
import 'package:smart_travel/presentation/widgets/hotel/hotel_room_type.dart';
import 'package:smart_travel/presentation/screens/booking/booking_screen.dart';
import 'package:smart_travel/presentation/screens/booking/booking_args.dart';

class DetailHotelScreen extends StatefulWidget {
  const DetailHotelScreen({Key? key}) : super(key: key);

  @override
  State<DetailHotelScreen> createState() => _DetailHotelScreenState();
}

class _DetailHotelScreenState extends State<DetailHotelScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hotelId = ModalRoute.of(context)!.settings.arguments as int;
      context.read<HotelDetailBloc>().add(
        GetHotelDetailEvent(
          hotelId: hotelId,
          checkIn: DateTime.now(),
          checkOut: DateTime.now().add(const Duration(days: 1)),
        ),
      );
    });

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // --- HÀM XỬ LÝ THÊM VÀO GIỎ HÀNG ---
  void _addToCart(BuildContext context, Hotel hotel) {
    // TODO: Gọi Bloc Cart để thêm sản phẩm vào giỏ hàng tại đây
    // Ví dụ: context.read<CartBloc>().add(AddHotelToCart(hotel));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text("Đã thêm khách sạn vào giỏ hàng!"),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // --- HÀM ĐẶT PHÒNG CỤ THỂ (KHI BẤM CHỌN PHÒNG TRONG LIST) ---
  void _bookSpecificRoom(BuildContext context, Hotel hotel, RoomType room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(
          args: BookingArgs(
            bookingType: 'HOTEL',
            id: hotel.id,
            // Hiển thị: "Tên KS - Tên Phòng"
            name: "${hotel.name} - ${room.name}",
            price: room.price ?? 0.0,
            imageUrl: (hotel.imageUrls != null && hotel.imageUrls!.isNotEmpty)
                ? hotel.imageUrls![0]
                : '',
            // Truyền ID loại phòng sang để trừ kho đúng
            roomTypeId: room.id,
          ),
        ),
      ),
    );
  }

  // --- HÀM ĐẶT MẶC ĐỊNH (KHI BẤM NÚT Ở BOTTOM BAR) ---
  // Tự động tìm phòng có giá thấp nhất (đang hiển thị) để đặt
  void _bookDefaultRoom(BuildContext context, Hotel hotel, double displayPrice) {
    if (hotel.rooms == null || hotel.rooms!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Khách sạn này hiện chưa có phòng trống")),
      );
      return;
    }

    // Tìm phòng có giá khớp với giá hiển thị (ưu tiên phòng đầu tiên tìm thấy)
    RoomType selectedRoom;
    try {
      selectedRoom = hotel.rooms!.firstWhere(
            (r) => (r.price ?? 0.0) == displayPrice,
        orElse: () => hotel.rooms!.first, // Nếu không khớp, lấy phòng đầu tiên
      );
    } catch (e) {
      selectedRoom = hotel.rooms!.first;
    }

    _bookSpecificRoom(context, hotel, selectedRoom);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HotelDetailBloc, HotelDetailState>(
      builder: (context, state) {
        Widget? bottomBar;
        double correctPrice = 0.0;

        if (state is HotelDetailLoaded) {
          final hotel = state.hotel;

          // Tính toán giá hiển thị (Min Price)
          correctPrice = hotel.minPrice ?? 0.0;
          if (correctPrice <= 0 &&
              hotel.rooms != null &&
              hotel.rooms!.isNotEmpty) {
            final validRoomPrices = hotel.rooms!
                .map((r) => r.price ?? 0.0)
                .where((price) => price > 0)
                .toList();

            if (validRoomPrices.isNotEmpty) {
              correctPrice = validRoomPrices.reduce((a, b) => a < b ? a : b);
            }
          }

          // Xây dựng BottomNavigationBar
          bottomBar = Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Giá từ",
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12)),
                        Text(
                          "${NumberFormat('#,###').format(correctPrice)} đ",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text("/ đêm",
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 10)),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => _addToCart(context, hotel),
                      icon: Icon(Icons.shopping_cart_outlined,
                          color: AppColors.primary),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        _bookDefaultRoom(context, hotel, correctPrice),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "Đặt ngay",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: bottomBar,
          body: Builder(builder: (context) {
            if (state is HotelDetailLoading) {
              return Center(
                  child: Lottie.asset('assets/lottie/travel_is_fun.json',
                      width: 200));
            }
            if (state is HotelDetailError) {
              return Center(child: Text(state.message));
            }

            if (state is HotelDetailLoaded) {
              final hotel = state.hotel;
              final List<String> images = hotel.imageUrls ?? [];
              return CustomScrollView(
                slivers: [
                  HotelImageCarouselSliver(
                      images: images, onBack: () => Navigator.pop(context)),
                  SliverToBoxAdapter(
                    child: HotelInfoSection(
                      hotel: hotel,
                      displayPrice: correctPrice,
                      fadeAnimation: _fadeController,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: HotelRoomTypeWidget(
                      rooms: hotel.rooms ?? [],
                      // Truyền callback khi chọn phòng cụ thể
                      onBook: (room) =>
                          _bookSpecificRoom(context, hotel, room),
                    ),
                  ),
                  SliverToBoxAdapter(child: HotelMapSection(hotel: hotel)),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        );
      },
    );
  }
}