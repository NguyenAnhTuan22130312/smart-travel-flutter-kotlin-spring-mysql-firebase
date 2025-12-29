import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/domain/entities/banner.dart';
import 'package:smart_travel/presentation/blocs/banner/banner_bloc.dart'; // Thay đổi đường dẫn theo dự án của bạn
import 'package:smart_travel/presentation/blocs/banner/banner_state.dart';
import '../../theme/app_colors.dart';

class HomeBannerSlider extends StatefulWidget {
  const HomeBannerSlider({Key? key}) : super(key: key);

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  late PageController _pageController;
  Timer? _timer;
  int _currentBannerPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay(int totalPages) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentBannerPage < totalPages - 1) {
        _currentBannerPage++;
      } else {
        _currentBannerPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentBannerPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BannerBloc, BannerState>(
      listener: (context, state) {
        if (state is BannerData) {
          final activeBanners = state.banners.where((b) => b.active).toList();
          if (activeBanners.isNotEmpty) {
            _startAutoPlay(activeBanners.length);
          }
        }
      },
      builder: (context, state) {
        if (state is BannerDataLoading) {
          return const SliverToBoxAdapter(
            child: SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator())
            ),
          );
        }

        if (state is BannerData) {
          List<BannerEntity> banners = state.banners.where((b) => b.active).toList();
          if (banners.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

          return SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  height: 180,
                  margin: const EdgeInsets.only(top: 16),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: banners.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentBannerPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final banner = banners[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: NetworkImage(banner.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7)
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                banner.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (banner.description != null)
                                Text(
                                  banner.description!,
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(banners.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentBannerPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentBannerPage == index
                            ? AppColors.primary
                            : Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}