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
import 'package:url_launcher/url_launcher.dart';

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
                _buildImageCarouselSliver(images, hotel),

                // 2. Thông tin chung (Tên, sao, mô tả, giá)
                SliverToBoxAdapter(
                  child: _buildInfoSection(hotel, displayPrice),
                ),

                // 3. Danh sách phòng
                _buildRoomsSection(hotel.rooms ?? []),

                // 4. Bản đồ vị trí
                SliverToBoxAdapter(child: _buildLocationMapSection(hotel)),

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

  // === WIDGET CON: CAROUSEL ẢNH (SLIVER APPBAR) ===
  Widget _buildImageCarouselSliver(List<String> images, Hotel hotel) {
    return SliverAppBar(
      expandedHeight: 340,
      // Chiều cao khi mở rộng tối đa
      floating: false,
      pinned: true,
      // Giữ lại thanh Appbar khi cuộn lên
      elevation: 0,
      backgroundColor: Colors.white,
      // Nút Back (Trở về)
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12),
            ],
          ),
          child: const Icon(Icons.arrow_back, color: textDark, size: 24),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // PageView để lướt qua lại các ảnh
            PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged:
                  (index) => setState(() => _currentImageIndex = index),
              itemBuilder: (context, index) {
                return Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                );
              },
            ),
            // Lớp phủ Gradient mờ ở dưới ảnh để làm nổi bật text (nếu có)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            // Chỉ báo vị trí ảnh (Dấu chấm slide indicator)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    images.asMap().entries.map((entry) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _currentImageIndex == entry.key ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              _currentImageIndex == entry.key
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === WIDGET CON: BẢN ĐỒ VỊ TRÍ ===
  Widget _buildLocationMapSection(Hotel hotel) {
    // Kiểm tra nếu không có tọa độ thì ẩn section này
    if (hotel.latitude == null || hotel.longitude == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vị trí khách sạn',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 12),
          // Dòng địa chỉ + Nút chỉ đường
          Row(
            children: [
              const Icon(Icons.location_on, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hotel.address ?? 'Không có địa chỉ',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Nút bấm mở Google Map bên ngoài
              ElevatedButton.icon(
                onPressed:
                    () => _openGoogleMap(hotel.latitude!, hotel.longitude!),
                icon: const Icon(Icons.directions, size: 18),
                label: const Text('Chỉ đường', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Hiển thị bản đồ nhỏ (Static Map View)
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox.expand(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(hotel.latitude!, hotel.longitude!),
                    zoom: 15.5,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('hotel_location'),
                      position: LatLng(hotel.latitude!, hotel.longitude!),
                      infoWindow: InfoWindow(
                        title: hotel.name,
                        snippet: 'Nhấn để xem trên Google Maps',
                      ),
                    ),
                  },
                  liteModeEnabled: false,
                  onTap:
                      (_) => _openGoogleMap(hotel.latitude!, hotel.longitude!),
                  zoomControlsEnabled: false,
                  // Tắt zoom để tránh xung đột cuộn trang
                  scrollGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  rotateGesturesEnabled: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === HÀM HỖ TRỢ: MỞ APP GOOGLE MAP ===
  void _openGoogleMap(double lat, double lng) async {
    // Tạo URL scheme để mở ứng dụng bản đồ
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không thể mở bản đồ')));
    }
  }

  // === WIDGET CON: THÔNG TIN KHÁCH SẠN (TÊN, SAO, GIÁ) ===
  Widget _buildInfoSection(Hotel hotel, double displayPrice) {
    return FadeTransition(
      opacity: _fadeController, // Hiệu ứng hiện dần
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tên khách sạn
            Text(
              hotel.name ?? '',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: textDark,
              ),
            ),
            const SizedBox(height: 10),
            // Hàng hiển thị số sao và đánh giá
            Row(
              children: [
                ...List.generate(
                  hotel.starRating ?? 0,
                  (_) => const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFBBF24),
                    size: 18,
                  ),
                ),
                if ((hotel.starRating ?? 0) > 0) const SizedBox(width: 6),
                Text(
                  '${hotel.averageRating?.toStringAsFixed(1) ?? '0.0'} '
                  '(${hotel.reviewCount ?? 0} đánh giá)',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Mô tả khách sạn
            Text(
              hotel.description ?? 'Không có mô tả',
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 22),
            // Khung hiển thị Giá tiền
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: secondaryPastel, // Nền nhạt
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Text(
                    "Giá tiền : ",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_formatPrice(displayPrice)}đ / đêm',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === WIDGET CON: DANH SÁCH PHÒNG ===
  Widget _buildRoomsSection(List<RoomType> rooms) {
    // Nếu không có phòng nào -> Hiển thị thông báo
    if (rooms.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text(
              'Chưa có loại phòng khả dụng',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Các loại phòng',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${rooms.length} lựa chọn cho bạn',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 12),
          // List các item phòng
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            // Tắt cuộn riêng của list này
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              final bool isLast = index == rooms.length - 1;
              // Kiểm tra số lượng phòng trống
              final bool isAvailable = (room.availableRooms ?? 0) > 0;

              return Container(
                margin: EdgeInsets.only(bottom: isLast ? 16 : 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon giường trang trí
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.king_bed_rounded,
                        size: 36,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Thông tin chi tiết phòng
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            // Chỉ thu nhỏ khi cần, không phóng to
                            alignment: Alignment.centerLeft,
                            // Canh lề trái
                            child: Text(
                              room.name ?? 'Phòng tiêu chuẩn',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${room.capacity ?? 2} người',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Tag hiển thị tình trạng (Còn phòng / Hết phòng)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isAvailable
                                      ? secondaryPastel
                                      : Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isAvailable
                                  ? 'Còn ${room.availableRooms} phòng'
                                  : 'Hết phòng',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color:
                                    isAvailable
                                        ? primaryColor
                                        : Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Giá tiền + Nút chọn
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_formatPrice(room.price ?? 0)}',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const Text(
                          'đ/đêm',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            // Nếu hết phòng thì disable nút chọn
                            onPressed:
                                isAvailable
                                    ? () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Đã chọn: ${room.name}',
                                          ),
                                        ),
                                      );
                                    }
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                            ),
                            child: const Text(
                              'Chọn',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // === HÀM HỖ TRỢ: ĐỊNH DẠNG GIÁ TIỀN ===
  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}
