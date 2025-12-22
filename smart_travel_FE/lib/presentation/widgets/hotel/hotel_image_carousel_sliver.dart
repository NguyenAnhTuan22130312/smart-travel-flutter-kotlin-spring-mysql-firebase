import 'dart:async';
import 'package:flutter/material.dart';

class HotelImageCarouselSliver extends StatefulWidget {
  final List<String> images;
  final VoidCallback? onBack;

  const HotelImageCarouselSliver({
    super.key,
    required this.images,
    this.onBack,
  });

  @override
  State<HotelImageCarouselSliver> createState() =>
      _HotelImageCarouselSliverState();
}

class _HotelImageCarouselSliverState extends State<HotelImageCarouselSliver> {
  late final PageController _pageController;
  int _currentImageIndex = 0;
  Timer? _timer; // Thêm Timer vào đây

  static const Color textDark = Color(0xFF1F2937);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay(); // Bắt đầu tự động chạy khi init
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_pageController.hasClients && widget.images.isNotEmpty) {
        final nextPage = (_currentImageIndex + 1) % widget.images.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Quan trọng: Phải huỷ timer khi thoát
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;

    return SliverAppBar(
      expandedHeight: 340,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: GestureDetector(
        onTap: widget.onBack ?? () => Navigator.pop(context),
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
            PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() => _currentImageIndex = index);
                // Reset timer khi người dùng vuốt thủ công để tránh đang vuốt thì nó nhảy
                _startAutoPlay();
              },
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
            // Gradient & Indicator giữ nguyên...
            _buildGradientOverlay(),
            _buildIndicators(images),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
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
    );
  }

  Widget _buildIndicators(List<String> images) {
    return Positioned(
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
    );
  }
}