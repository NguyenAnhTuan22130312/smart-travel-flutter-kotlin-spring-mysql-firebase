import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart' hide Marker;
import 'package:smart_travel/domain/entities/hotel.dart';
import 'package:smart_travel/domain/entities/room_type.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotail_detail_bloc.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_detail_event.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_detail_state.dart';
import 'package:smart_travel/presentation/widgets/hotel/hotel_image_carousel_sliver.dart';
import 'package:smart_travel/presentation/widgets/hotel/hotel_info_section.dart';
import 'package:smart_travel/presentation/widgets/hotel/hotel_map.dart';
import 'package:smart_travel/presentation/widgets/hotel/hotel_room_type.dart';

// Màn hình chi tiết khách sạn
class DetailHotelScreen extends StatefulWidget {
  const DetailHotelScreen({Key? key}) : super(key: key);

  @override
  State<DetailHotelScreen> createState() => _DetailHotelScreenState();
}

class _DetailHotelScreenState extends State<DetailHotelScreen>
    with TickerProviderStateMixin {
  // --- KHAI BÁO BIẾN QUẢN LÝ UI ---
  late PageController _pageController; // Điều khiển việc lướt ảnh (Carousel)
  Timer? _timer; // Bộ đếm thời gian để tự động chuyển ảnh
  int _currentImageIndex = 0; // Lưu chỉ số ảnh đang hiển thị
  late AnimationController
  _fadeController; // Điều khiển hiệu ứng hiện dần (Fade)

  // --- KHAI BÁO MÀU SẮC (CẤU HÌNH UI) ---
  static const Color primaryColor = Color(0xFF2DBBAA);
  static const Color secondaryPastel = Color(0xFFE6FAF7);
  static const Color textDark = Color(0xFF1F2937);

  // ---------------------------------------------------------------------

  // === 1. KHỞI TẠO TRẠNG THÁI (Lifecycle: Init) ===
  @override
  void initState() {
    super.initState();

    // Gọi API lấy chi tiết khách sạn ngay khi màn hình được dựng xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hotelId = ModalRoute.of(context)!.settings.arguments as int;
      // Gửi event lấy dữ liệu vào BLoC
      context.read<HotelDetailBloc>().add(
        GetHotelDetailEvent(
          hotelId: hotelId,
          checkIn: DateTime.now(),
          checkOut: DateTime.now().add(const Duration(days: 1)),
        ),
      );
    });

    // Khởi tạo Controller cho PageView và Animation
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward(); // Chạy hiệu ứng fade ngay khi vào màn hình
  }

  // === LOGIC TỰ ĐỘNG CHUYỂN ẢNH ===
  void _startAutoPlay(List<String> images) {
    _timer?.cancel(); // Hủy timer cũ nếu có
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_pageController.hasClients && images.isNotEmpty) {
        // Tính toán trang tiếp theo (xoay vòng)
        final nextPage = (_currentImageIndex + 1) % images.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // === 2. HỦY TRẠNG THÁI (Lifecycle: Dispose) ===
  @override
  void dispose() {
    // Giải phóng tài nguyên để tránh rò rỉ bộ nhớ (Memory Leak)
    _pageController.dispose();
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  // === 3. XÂY DỰNG GIAO DIỆN (Build UI) ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dùng BlocBuilder để lắng nghe thay đổi trạng thái từ HotelDetailBloc
      body: BlocBuilder<HotelDetailBloc, HotelDetailState>(
        builder: (context, state) {
          // TRƯỜNG HỢP 1: Đang tải dữ liệu (Loading)
          if (state is HotelDetailLoading) {
            return Center(
              child: Lottie.asset(
                'assets/lottie/travel_is_fun.json',
                width: 200,
                height: 200,
              ),
            );
          }

          // TRƯỜNG HỢP 2: Có lỗi xảy ra (Error)
          if (state is HotelDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Logic thử lại: Lấy lại ID và gọi lại Event
                      final hotelId =
                          ModalRoute.of(context)!.settings.arguments as int;
                      context.read<HotelDetailBloc>().add(
                        GetHotelDetailEvent(
                          hotelId: hotelId,
                          checkIn: DateTime.now(),
                          checkOut: DateTime.now().add(const Duration(days: 1)),
                        ),
                      );
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          // TRƯỜNG HỢP 3: Tải thành công (Loaded)
          if (state is HotelDetailLoaded) {
            final hotel = state.hotel;
            final List<String> images = hotel.imageUrls ?? [];

            // Kích hoạt tự động chạy ảnh sau khi giao diện đã dựng xong
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _startAutoPlay(images);
            });

            // Logic tính giá hiển thị (Ưu tiên minPrice, nếu null thì tìm phòng rẻ nhất)
            final double displayPrice =
                hotel.minPrice ??
                (hotel.rooms?.isNotEmpty == true
                    ? hotel.rooms!
                        .map((r) => r.price ?? double.infinity)
                        .reduce((a, b) => a < b ? a : b)
                    : 0.0);

            // CustomScrollView cho phép cuộn toàn màn hình với các hiệu ứng Sliver
            return CustomScrollView(
              slivers: [
                // 1. Ảnh bìa (Carousel) + Appbar ẩn hiện
                HotelImageCarouselSliver(
                  images: hotel.imageUrls ?? [],
                  onBack: () => Navigator.pop(context),
                ),

                // 2. Thông tin chung (Tên, sao, mô tả, giá)
                SliverToBoxAdapter(
                  child: HotelInfoSection(
                    hotel: hotel,
                    displayPrice: displayPrice,
                    fadeAnimation: _fadeController, // truyền animation cũ
                  ),
                ),

                // 3. Danh sách phòng
                SliverToBoxAdapter(
                  child: HotelRoomTypeWidget(rooms: hotel.rooms ?? []),
                ),

                // 4. Bản đồ vị trí
                SliverToBoxAdapter(child: HotelMapSection(hotel: hotel)),

                // Khoảng trống dưới cùng để không bị cấn nút điều hướng
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          }
          // Mặc định trả về widget rỗng
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
