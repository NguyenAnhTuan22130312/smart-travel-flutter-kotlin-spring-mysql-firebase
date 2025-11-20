import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_travel/domain/entities/hotel.dart';
import 'package:smart_travel/domain/entities/room_type.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotail_detail_bloc.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_detail_event.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_detail_state.dart';

class DetailHotelScreen extends StatefulWidget {
  const DetailHotelScreen({Key? key}) : super(key: key);

  @override
  State<DetailHotelScreen> createState() => _DetailHotelScreenState();
}

class _DetailHotelScreenState extends State<DetailHotelScreen>
    with TickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HotelDetailBloc, HotelDetailState>(
        builder: (context, state) {
          if (state is HotelDetailLoading) {
            return Center(
              child: Lottie.asset(
                'assets/lottie/travel_is_fun.json',
                width: 200,
                height: 200,
              ),
            );
          }

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

          if (state is HotelDetailLoaded) {
            final hotel = state.hotel;

            // ĐÃ SỬA: dùng đúng field ảnh (BE trả "images" là List)
            final List<String> images = hotel.imageUrls ?? [];

            // Bật auto play carousel
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _startAutoPlay(images);
            });

            // Tính giá hiển thị (lấy minPrice nếu có, không thì lấy phòng rẻ nhất)
            final double displayPrice =
                hotel.minPrice ??
                (hotel.rooms?.isNotEmpty == true
                    ? hotel.rooms!
                        .map((r) => r.price ?? double.infinity)
                        .reduce((a, b) => a < b ? a : b)
                    : 0.0);

            return CustomScrollView(
              slivers: [
                _buildImageCarouselSliver(images, hotel),
                SliverToBoxAdapter(
                  child: _buildInfoSection(hotel, displayPrice),
                ),
                _buildRoomsSection(hotel.rooms ?? []),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildImageCarouselSliver(List<String> images, Hotel hotel) {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back, color: Colors.black),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
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
                        child: const Icon(Icons.broken_image, size: 64),
                      ),
                );
              },
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Text(
                hotel.name ?? '',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(Hotel hotel, double displayPrice) {
    return FadeTransition(
      opacity: _fadeController,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hotel.name ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(
                  hotel.starRating ?? 0,
                  (_) => const Icon(
                    Icons.star,
                    color: Color(0xFFFDBF0E),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${hotel.averageRating?.toStringAsFixed(1) ?? '0.0'} (${hotel.reviewCount ?? 0} đánh giá)',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              hotel.description ?? 'Không có mô tả',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Text(
              '${_formatPrice(displayPrice)}đ / đêm',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00C853),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomsSection(List<RoomType> rooms) {
    if (rooms.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('Chưa có loại phòng nào')),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final room = rooms[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                room.name ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_formatPrice(room.price ?? 0.0)}đ / đêm',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF00C853),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text('Sức chứa: ${room.capacity ?? 0} người'),
              Text('Còn trống: ${room.availableRooms ?? 0} phòng'),
            ],
          ),
        );
      }, childCount: rooms.length),
    );
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}
