import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart' hide Marker;
import 'package:smart_travel/domain/entities/hotel.dart';
import 'package:smart_travel/domain/entities/room_type.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_detail_bloc.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_detail_event.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_detail_state.dart';
import 'package:smart_travel/presentation/widgets/hotel/hotel_image_carousel_sliver.dart';
import 'package:smart_travel/presentation/widgets/hotel/hotel_info_section.dart';
import 'package:smart_travel/presentation/widgets/hotel/hotel_map.dart';
import 'package:smart_travel/presentation/widgets/hotel/hotel_room_type.dart';
import 'package:smart_travel/presentation/screens/booking/booking_screen.dart';
import 'package:smart_travel/presentation/screens/booking/booking_args.dart';

import '../../../injection_container.dart';
import '../../blocs/review/reviewhtd_bloc.dart';
import '../../widgets/review/review_list_widget.dart';

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
            // Giá chính xác của phòng đó
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HotelDetailBloc, HotelDetailState>(
      builder: (context, state) {

        // --- ĐÃ XÓA BOTTOM NAVIGATION BAR ---

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          // bottomNavigationBar: null, // Không cần dòng này vì mặc định là null
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

              // Tính toán giá min để hiển thị (chỉ dùng hiển thị ở phần Info nếu cần)
              double displayPrice = hotel.minPrice ?? 0.0;
              if (displayPrice <= 0 &&
                  hotel.rooms != null &&
                  hotel.rooms!.isNotEmpty) {
                final validRoomPrices = hotel.rooms!
                    .map((r) => r.price ?? 0.0)
                    .where((price) => price > 0)
                    .toList();
                if (validRoomPrices.isNotEmpty) {
                  displayPrice = validRoomPrices.reduce((a, b) => a < b ? a : b);
                }
              }

              final List<String> images = hotel.imageUrls ?? [];

              return CustomScrollView(
                slivers: [
                  HotelImageCarouselSliver(
                      images: images, onBack: () => Navigator.pop(context)),

                  SliverToBoxAdapter(
                    child: HotelInfoSection(
                      hotel: hotel,
                      displayPrice: displayPrice,
                      fadeAnimation: _fadeController,
                    ),
                  ),

                  // Danh sách phòng - Nơi duy nhất để đặt phòng
                  SliverToBoxAdapter(
                    child: HotelRoomTypeWidget(
                      rooms: hotel.rooms ?? [],
                      // Truyền callback khi chọn phòng cụ thể
                      onBook: (room) =>
                          _bookSpecificRoom(context, hotel, room),
                    ),
                  ),

                  SliverToBoxAdapter(child: HotelMapSection(hotel: hotel)),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)), // Padding bottom

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Đánh giá từ khách hàng",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 500,
                      child: BlocProvider(
                        create: (_) => ReviewHtdBloc(sl()),
                        child: ReviewListWidget(
                          type: "HOTEL",
                          serviceId: hotel.id,
                        ),
                      ),
                    ),
                  ),

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