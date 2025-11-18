import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:lottie/lottie.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/domain/entities/hotel.dart';
import 'package:smart_travel/domain/entities/review.dart';
import 'package:smart_travel/domain/entities/tour.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_bloc.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_event.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_state.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_colors.dart';

class DetailDestinationScreen extends StatefulWidget {
  const DetailDestinationScreen({Key? key}) : super(key: key);

  @override
  State<DetailDestinationScreen> createState() => _DetailDestinationScreenState();
}

class _DetailDestinationScreenState extends State<DetailDestinationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late PageController _pageController;
  Timer? _timer;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = ModalRoute.of(context)!.settings.arguments as int ;
      context.read<DestinationBloc>().add(GetDetailDestinationEvent(id));
    });

    _tabController = TabController(length: 4, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _pageController = PageController();
  }

  void _startAutoPlay(List<String> images) {
    if (images.isEmpty) return; // nếu không có ảnh, dừng

    _timer?.cancel(); // nếu có timer trước, hủy

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        _currentImageIndex = (_currentImageIndex + 1) % images.length; // cập nhật index
        _pageController.animateToPage(
          _currentImageIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<DestinationBloc, DestinationState>(
        listener: (context, state) {

          // Không cần setState ở đây vì BlocBuilder sẽ rebuild
        },
        builder: (context, state) {
          if (state is GetDetailDestinationLoading) {
            return Center(
              child: Lottie.asset(
                'assets/lottie/travel_is_fun.json',
                width: 200,
                height: 500,
                repeat: true,

              ),
            );
          }

          if (state is GetDetailDestinationError) {
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
                      final id = ModalRoute.of(context)!.settings.arguments as int;
                      context.read<DestinationBloc>().add(GetDetailDestinationEvent(id));
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is GetDetailDestinationLoaded) {
            final destination = state.destinationEntity;
            final images = destination.destinationImage
                ?.map((img) => img.imageUrl ?? '')
                .toList() ?? [];
            _startAutoPlay(images);

            return CustomScrollView(
              slivers: [
                _buildImageCarouselSliver(images, destination),
                SliverToBoxAdapter(child: _buildInfoSection(destination)),
                SliverToBoxAdapter(child: _buildTabBar(destination)),
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(destination),
                      _buildHotelsTab(destination.hotels ?? []),
                      _buildToursTab(destination.tours ?? []),
                      _buildReviewsTab(destination.reviews ?? []),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildImageCarouselSliver(List<String> images, DestinationEntity destination) {
    return SliverAppBar(
      expandedHeight: 340,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12)],
          ),
          child: const Icon(Icons.arrow_back, color: Color(0xFF1F2937), size: 24),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentImageIndex = index),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                  ),
                );
              },
            ),
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
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: images.asMap().entries.map((entry) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentImageIndex == entry.key ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentImageIndex == entry.key
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  );
                }).toList(),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          destination.address ?? 'Không có địa chỉ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(DestinationEntity destination) {
    return FadeTransition(
      opacity: _fadeController,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRatingRow(
                        destination.averageRating,
                        destination.reviewCount,
                      ),
                      const SizedBox(height: 12),
                      _buildViewCount(destination.viewCount),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildActionButtons(destination),
              ],
            ),
            const SizedBox(height: 20),
            _buildPriceAndHours(
              destination.entryFee ?? 0,
              _parseOpeningHours(destination.openingHours),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow(double rating, int count) {
    return Row(
      children: [
        ...List.generate(
          5,
              (i) => Icon(
            i < rating ? Icons.star : Icons.star_border,
            color: const Color(0xFFFDBF0E),
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${rating.toStringAsFixed(1)} / 5.0',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              '$count đánh giá',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewCount(int views) {
    return Row(
      children: [
        Icon(Icons.visibility, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Text(
          '$views lượt xem',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildActionButtons(DestinationEntity destination) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openMap(destination.latitude!, destination.longitude!),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(

                color: AppColors.button,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C853).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.directions, size: 18, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Chỉ đường',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _share,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color:  AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.share, size: 18, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Chia sẻ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAndHours(double fee, Map<String, String> hours) {
    final hourText = hours.values.isNotEmpty ? hours.values.first : 'Không có thông tin';
    return Row(
      children: [
        Expanded(
          child: _infoCard(
            Icons.local_offer,
            'Giá vé',
            fee > 0 ? '${_formatPrice(fee)}đ' : 'Miễn phí',
            AppColors.button,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _infoCard(Icons.access_time, 'Giờ mở cửa', hourText, Colors.blue),
        ),
      ],
    );
  }

  Widget _infoCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(DestinationEntity destination) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF2196F3),
        unselectedLabelColor: Colors.grey[500],
        indicatorColor: const Color(0xFF2196F3),
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: [
          const Tab(text: 'Tổng quan'),
          Tab(text: 'Khách sạn (${destination.hotels?.length ?? 0})'),
          Tab(text: 'Tour (${destination.tours?.length ?? 0})'),
          Tab(text: 'Đánh giá (${destination.reviews?.length ?? 0})'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(DestinationEntity destination) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mô tả', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            destination.description ?? 'Không có mô tả',
            style: TextStyle(height: 1.8, color: Colors.grey[700], fontSize: 14),
          ),
          const SizedBox(height: 28),
          const Text('Vị trí', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: gmap.GoogleMap(
                initialCameraPosition:gmap.CameraPosition(
                  target: gmap.LatLng(destination.latitude!, destination.longitude!),
                  zoom: 15,
                ),
                markers: {
                  gmap.Marker(
                    markerId: const gmap.MarkerId('dest'),
                    position: gmap.LatLng(destination.latitude!, destination.longitude!),
                    infoWindow: gmap.InfoWindow(title: destination.name),
                  ),
                },
                liteModeEnabled: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelsTab(List<Hotel> hotels) {
    if (hotels.isEmpty) {
      return const Center(child: Text('Chưa có khách sạn'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: hotels.length,
      itemBuilder: (context, i) {
        final h = hotels[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Material(
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        h.images!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey[300], width: 80, height: 80),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h.name!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              ...List.generate(h.starRating!, (_) => const Icon(Icons.star, color: Color(0xFFFDBF0E), size: 14)),
                              const SizedBox(width: 6),
                              Text('${h.starRating} sao', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${_formatPrice(h.pricePerNight!)}đ / đêm',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00C853), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFFDBF0E), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            h.averageRating!.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildToursTab(List<Tour> tours) {
    if (tours.isEmpty) {
      return const Center(child: Text('Chưa có tour'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tours.length,
      itemBuilder: (context, i) {
        final t = tours[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Material(
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        t.image!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey[300], width: 80, height: 80),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.name!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text('${t.durationDays} ngày', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${_formatPrice(t.pricePerPerson!)}đ / người',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00C853), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFFDBF0E), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            t.averageRating!.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab(List<Review> reviews) {
    if (reviews.isEmpty) {
      return const Center(child: Text('Chưa có đánh giá'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (context, i) {
        final r = reviews[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ...List.generate(5, (j) => Icon(
                      j < r.rating! ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFDBF0E),
                      size: 18,
                    )),
                    const SizedBox(width: 8),
                    Text('${r.rating}/5', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(r.comment!, style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.6)),
                if (r.imageUrls?.isNotEmpty == true) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: r.imageUrls!.length,
                      itemBuilder: (context, j) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            r.imageUrls![j],
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: Colors.grey[300], width: 90, height: 90),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Icon(Icons.thumb_up, size: 16, color: Colors.blue[600]),
                          const SizedBox(width: 4),
                          Text('${r.likesCount}', style: TextStyle(color: Colors.blue[600], fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(_formatDate(r.createdAt), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper
  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  Map<String, String> _parseOpeningHours(Map<String, dynamic>? hours) {
    if (hours == null || hours.isEmpty) return {'': 'Không có thông tin'};
    return hours.map((k, v) => MapEntry(k, v.toString()));
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _openMap(double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps?q=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _share() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Chia sẻ thành công!'),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}