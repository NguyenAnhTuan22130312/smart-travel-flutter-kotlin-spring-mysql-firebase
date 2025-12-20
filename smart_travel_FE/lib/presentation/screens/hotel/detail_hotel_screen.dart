import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart' hide Marker;
import 'package:smart_travel/domain/entities/hotel.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotail_detail_bloc.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_detail_event.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_detail_state.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart'; // Import màu
import 'package:smart_travel/presentation/widgets/hotel/hotel_image_carousel_sliver.dart';
import 'package:smart_travel/presentation/widgets/hotel/hotel_info_section.dart';
import 'package:smart_travel/presentation/widgets/hotel/hotel_map.dart';
import 'package:smart_travel/presentation/widgets/hotel/hotel_room_type.dart';
import 'package:smart_travel/presentation/screens/booking/booking_screen.dart'; // Import màn hình Booking
import 'package:smart_travel/presentation/screens/booking/booking_args.dart'; // Import Args

class DetailHotelScreen extends StatefulWidget {
  const DetailHotelScreen({Key? key}) : super(key: key);

  @override
  State<DetailHotelScreen> createState() => _DetailHotelScreenState();
}

class _DetailHotelScreenState extends State<DetailHotelScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  Timer? _timer;
  int _currentImageIndex = 0;
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

    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  void _startAutoPlay(List<String> images) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_pageController.hasClients && images.isNotEmpty) {
        final nextPage = (_currentImageIndex + 1) % images.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
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

  // --- HÀM XỬ LÝ ĐẶT NGAY ---
  void _bookNow(BuildContext context, Hotel hotel, double price) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(
          args: BookingArgs(
            id: hotel.id,
            name: hotel.name ?? "Khách sạn",
            price: price, // Giá lấy từ minPrice hoặc phòng rẻ nhất
            imageUrl: (hotel.imageUrls != null && hotel.imageUrls!.isNotEmpty)
                ? hotel.imageUrls![0]
                : '',
            bookingType: 'HOTEL', // Quan trọng: Đánh dấu là đặt khách sạn
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HotelDetailBloc, HotelDetailState>(
      builder: (context, state) {
        // --- 1. KHAI BÁO BIẾN Ở ĐÂY ĐỂ TOÀN BỘ BUILDER ĐỀU THẤY ---
        Widget? bottomBar;
        double correctPrice = 0.0;

        if (state is HotelDetailLoaded) {
          final hotel = state.hotel;

          // Tính toán giá đúng
          correctPrice = hotel.minPrice ?? 0.0;

          if (correctPrice <= 0 && hotel.rooms != null && hotel.rooms!.isNotEmpty) {
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
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
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
                        Text("Giá từ", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        Text(
                          "${NumberFormat('#,###').format(correctPrice)} đ",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text("/ đêm", style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
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
                      icon: Icon(Icons.shopping_cart_outlined, color: AppColors.primary),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _bookNow(context, hotel, correctPrice),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "Đặt ngay",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
              return Center(child: Lottie.asset('assets/lottie/travel_is_fun.json', width: 200));
            }
            if (state is HotelDetailError) {
              return Center(child: Text(state.message));
            }

            if (state is HotelDetailLoaded) {
              final hotel = state.hotel;
              final List<String> images = hotel.imageUrls ?? [];

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_timer == null || !_timer!.isActive) _startAutoPlay(images);
              });

              return CustomScrollView(
                slivers: [
                  HotelImageCarouselSliver(images: images, onBack: () => Navigator.pop(context)),
                  SliverToBoxAdapter(
                    child: HotelInfoSection(
                      hotel: hotel,
                      displayPrice: correctPrice,
                      fadeAnimation: _fadeController,
                    ),
                  ),
                  SliverToBoxAdapter(child: HotelRoomTypeWidget(rooms: hotel.rooms ?? [])),
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