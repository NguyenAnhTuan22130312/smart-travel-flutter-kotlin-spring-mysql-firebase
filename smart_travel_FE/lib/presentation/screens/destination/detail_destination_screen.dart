import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:convert';

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
  late Timer _timer;
  int _currentImageIndex = 0;

  final Map<String, dynamic> mockData = {
    "id": 2,
    "name": "Bà Nà Hills",
    "description":
    "Bà Nà Hills là khu du lịch nổi tiếng với cáp treo kỷ lục, cầu Vàng độc đáo và khí hậu mát mẻ như châu Âu.",
    "category": "MOUNTAIN",
    "address": "Xã Hòa Ninh, Huyện Hòa Vang, Đà Nẵng",
    "latitude": 15.9972,
    "longitude": 107.9965,
    "province": {
      "id": 2,
      "name": "Đà Nẵng",
      "imageUrl":
      "https://res.cloudinary.com/dcwqv4rng/image/upload/v1760535538/tdjci9thdvu6wkpaznw5.jpg"
    },
    "averageRating": 4.65,
    "reviewCount": 950,
    "viewCount": 32000,
    "entryFee": 750000.00,
    "openingHours":
    "{\"monday\": \"07:00-21:00\", \"tuesday\": \"07:00-21:00\", \"wednesday\": \"07:00-21:00\", \"thursday\": \"07:00-21:00\", \"friday\": \"07:00-21:00\", \"saturday\": \"07:00-21:00\", \"sunday\": \"07:00-21:00\"}",
    "imageUrls": [
      "https://res.cloudinary.com/dcwqv4rng/image/upload/v1760535538/tdjci9thdvu6wkpaznw5.jpg",
      "https://res.cloudinary.com/demo/image/upload/v1720535538/tour_banahills_main.jpg",
      "https://example.com/review-bana-tour1.jpg",
      "https://example.com/review-bana-hotel1.jpg",
      "https://images.unsplash.com/photo-1519985176271-0a9a33d7f6e8?w=800"
    ],
    "hotels": [
      {
        "id": 1,
        "name": "Mercure Ba Na Hills French Village",
        "address": "Khu du lịch Bà Nà Hills, Hòa Ninh, Hòa Vang, Đà Nẵng",
        "pricePerNight": 2800000.00,
        "starRating": 5,
        "averageRating": 4.70,
        "images": ["https://example.com/hotel-bana1-1.jpg"]
      },
      {
        "id": 2,
        "name": "Debay Hotel Ba Na Hills",
        "address": "Bà Nà Hills, Hòa Ninh, Hòa Vang, Đà Nẵng",
        "pricePerNight": 1900000.00,
        "starRating": 4,
        "averageRating": 4.50,
        "images": ["https://example.com/hotel-bana2-1.jpg"]
      }
    ],
    "tours": [
      {
        "id": 1,
        "name": "Tour Bà Nà Hills 1 Ngày",
        "durationDays": 1,
        "pricePerPerson": 850000.00,
        "averageRating": 4.80,
        "images": [
          "https://res.cloudinary.com/demo/image/upload/v1720535538/tour_banahills_main.jpg"
        ]
      },
      {
        "id": 2,
        "name": "Tour Bà Nà Hills - Hội An 2N1Đ",
        "durationDays": 2,
        "pricePerPerson": 1900000.00,
        "averageRating": 4.70,
        "images": [
          "https://res.cloudinary.com/demo/image/upload/v1720535541/tour_hoian_main.jpg"
        ]
      }
    ],
    "reviews": [
      {
        "id": 1,
        "rating": 5,
        "comment": "Tour tuyệt vời! Cầu Vàng và khí hậu trên đỉnh núi rất đáng nhớ.",
        "likesCount": 12,
        "createdAt": "2025-10-11T22:10:00",
        "images": ["https://example.com/review-bana-tour1.jpg"]
      },
      {
        "id": 2,
        "rating": 4,
        "comment": "Khách sạn sạch đẹp, nhân viên thân thiện. Ăn sáng ngon và phong cảnh đẹp.",
        "likesCount": 8,
        "createdAt": "2025-10-11T22:12:00",
        "images": ["https://example.com/review-bana-hotel1.jpg"]
      },
      {
        "id": 3,
        "rating": 5,
        "comment": "Tour kết hợp Bà Nà Hills và Hội An rất hợp lý, giá tốt, dịch vụ chu đáo.",
        "likesCount": 5,
        "createdAt": "2025-10-11T22:15:00",
        "images": ["https://example.com/review-bana-tour2.jpg"]
      }
    ]
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _pageController = PageController();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final imageCount = mockData['imageUrls'].length as int; // Ép kiểu an toàn
        int nextPage = (_currentImageIndex + 1) % imageCount;

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
    _tabController.dispose();
    _fadeController.dispose();
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildImageCarouselSliver(),
          SliverToBoxAdapter(child: _buildInfoSection()),
          SliverToBoxAdapter(child: _buildTabBar()),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildHotelsTab(),
                _buildToursTab(),
                _buildReviewsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarouselSliver() {
    final images = mockData['imageUrls'] as List;

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
                    mockData['name'],
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
                          mockData['address'],
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

  Widget _buildInfoSection() {
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
                        (mockData['averageRating'] as num).toDouble(),
                        mockData['reviewCount'] as int,
                      ),
                      const SizedBox(height: 12),
                      _buildViewCount(mockData['viewCount'] as int),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildActionButtons(),
              ],
            ),
            const SizedBox(height: 20),
            _buildPriceAndHours(
              (mockData['entryFee'] as num).toDouble(),
              _parseOpeningHours(),
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
              '$rating / 5.0',
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openMap(
              (mockData['latitude'] as num).toDouble(),
              (mockData['longitude'] as num).toDouble(),
            ),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C853), Color(0xFF00BF4F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2196F3), width: 2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.share, size: 18, color: Color(0xFF2196F3)),
                  SizedBox(width: 6),
                  Text(
                    'Chia sẻ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2196F3),
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
    return Row(
      children: [
        Expanded(
          child: _infoCard(
            Icons.local_offer,
            'Giá vé',
            '${_formatPrice(fee  )}đ',
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _infoCard(Icons.access_time, 'Giờ mở cửa', '07:00 - 21:00', Colors.blue),
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

  Widget _buildTabBar() {
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
          Tab(text: 'Khách sạn (${mockData['hotels'].length})'),
          Tab(text: 'Tour (${mockData['tours'].length})'),
          Tab(text: 'Đánh giá (${mockData['reviews'].length})'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mô tả', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            mockData['description'],
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
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    (mockData['latitude'] as num).toDouble(),
                    (mockData['longitude'] as num).toDouble(),
                  ),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('dest'),
                    position: LatLng(
                      (mockData['latitude'] as num).toDouble(),
                      (mockData['longitude'] as num).toDouble(),
                    ),
                    infoWindow: InfoWindow(title: mockData['name']),
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

  Widget _buildHotelsTab() {
    final hotels = mockData['hotels'] as List;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: hotels.length,
      itemBuilder: (context, i) {
        final h = hotels[i];
        final price = (h['pricePerNight'] as num).toDouble();
        final starRating = h['starRating'] as int;
        final avgRating = (h['averageRating'] as num).toDouble();

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
                        h['images'][0],
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
                            h['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              ...List.generate(starRating, (j) => const Icon(Icons.star, color: Color(0xFFFDBF0E), size: 14)),
                              const SizedBox(width: 6),
                              Text('$starRating sao', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${_formatPrice(price)}đ / đêm',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00C853), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Color(0xFFFDBF0E), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                avgRating.toStringAsFixed(1),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildToursTab() {
    final tours = mockData['tours'] as List;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tours.length,
      itemBuilder: (context, i) {
        final t = tours[i];
        final price = (t['pricePerPerson'] as num).toDouble();
        final days = t['durationDays'] as int;
        final avgRating = (t['averageRating'] as num).toDouble();

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
                        t['images'][0],
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
                            t['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text('$days ngày', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${_formatPrice(price)}đ / người',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00C853), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Color(0xFFFDBF0E), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                avgRating.toStringAsFixed(1),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildReviewsTab() {
    final reviews = mockData['reviews'] as List;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (context, i) {
        final r = reviews[i];
        final rating = r['rating'] as int;
        final likes = r['likesCount'] as int;

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
                      j < rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFDBF0E),
                      size: 18,
                    )),
                    const SizedBox(width: 8),
                    Text('$rating/5', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(r['comment'], style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.6)),
                if (r['images'].isNotEmpty) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: r['images'].length,
                      itemBuilder: (context, j) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            r['images'][j],
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
                          Text('$likes', style: TextStyle(color: Colors.blue[600], fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(_formatDate(r['createdAt']), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper: Định dạng giá tiền
  String _formatPrice(double price) {
    return price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  Map<String, String> _parseOpeningHours() {
    final data = mockData['openingHours'];
    if (data is String) {
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    }
    return {'Giờ mở cửa': '07:00 - 21:00'};
  }

  String _formatDate(String date) => date.split('T')[0].replaceAll('-', '/');

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