import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_bloc.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_event.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_state.dart';
import 'package:smart_travel/presentation/widgets/common/bottom_navigation.dart';
import 'package:smart_travel/presentation/widgets/destination/DestinationFeaturedCard.dart';
import '../../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'ALL';
  int _selectedIndex = 0; // Index cho thanh điều hướng dưới

  // Danh mục theo CSDL (category trong bảng destinations)
  final List<Map<String, dynamic>> _categories = [
    {'id': 'ALL', 'icon': Icons.explore, 'label': 'Tất cả'},
    {'id': 'BEACH', 'icon': Icons.beach_access, 'label': 'Biển'},
    {'id': 'MOUNTAIN', 'icon': Icons.terrain, 'label': 'Núi'},
    {'id': 'CULTURE', 'icon': Icons.temple_buddhist, 'label': 'Văn hóa'},
    {'id': 'CITY', 'icon': Icons.location_city, 'label': 'Thành phố'},
    {'id': 'NATURE', 'icon': Icons.landscape, 'label': 'Thiên nhiên'},
  ];


  // Dữ liệu mẫu provinces với is_popular = true
  final List<Map<String, dynamic>> _popularProvinces = [
    {
      'id': 1,
      'name': 'Hà Nội',
      'code': 'HN',
      'region': 'NORTH',
      'image_url': 'assets/images/hanoi.jpg',
      'is_popular': true,
      'destination_count': 125,
    },
    {
      'id': 2,
      'name': 'TP. Hồ Chí Minh',
      'code': 'HCM',
      'region': 'SOUTH',
      'image_url': 'assets/images/hcm.jpg',
      'is_popular': true,
      'destination_count': 158,
    },
    {
      'id': 3,
      'name': 'Đà Nẵng',
      'code': 'DN',
      'region': 'CENTRAL',
      'image_url': 'assets/images/danang.jpg',
      'is_popular': true,
      'destination_count': 82,
    },
    {
      'id': 4,
      'name': 'Khánh Hòa',
      'code': 'KH',
      'region': 'SOUTH',
      'image_url': 'assets/images/nhatrang.jpg',
      'is_popular': true,
      'destination_count': 95,
    },
  ];

  // Dữ liệu user mẫu từ bảng users & user_profiles
  final Map<String, dynamic> _currentUser = {
    'id': 1,
    'full_name': 'Nguyễn Văn A',
    'email': 'nguyenvana@gmail.com',
    'role': 'USER',
    'profile': {
      'avatar_url': null, // hoặc 'https://example.com/avatar.jpg'
      'dark_mode_enabled': false,
    },
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    context.read<DestinationBloc>().add(LoadFeaturedDestinations());
  }

  // Xử lý khi chọn mục trong thanh điều hướng
  void _onNavItemTapped(int index) {
    if (index == _selectedIndex)
      return; // Tránh điều hướng lại nếu đang ở màn hình hiện tại
    setState(() {
      _selectedIndex = index;
    });
    // Điều hướng đến màn hình tương ứng
    Navigator.pushReplacementNamed(
      context,
      ['/home', '/destination/list', '/booking', '/profile', '/ai_chat'][index],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            _buildSearchBar(),
            _buildAIChatBanner(),
            _buildCategories(),
            _buildFeaturedDestinations(),
            _buildPopularProvinces(),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigationWithIndicator(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }

  // App Bar với thông tin user từ bảng users & user_profiles
  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage:
                _currentUser['profile']['avatar_url'] != null
                    ? NetworkImage(_currentUser['profile']['avatar_url'])
                    : null,
            child:
                _currentUser['profile']['avatar_url'] == null
                    ? Icon(Icons.person, color: AppColors.primary)
                    : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào 👋',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGray,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  _currentUser['full_name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF374151),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
    );
  }

  // Search Bar
  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm địa điểm, tour...',
              hintStyle: TextStyle(color: AppColors.textGray, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: AppColors.primary),
              suffixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune, color: Colors.white, size: 20),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onTap: () {
              // TODO: Navigate to search screen
            },
          ),
        ),
      ),
    );
  }

  // AI Chat Banner - liên quan đến tính năng AI chatbot
  Widget _buildAIChatBanner() {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () {
          // TODO: Navigate to AI chat screen
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'AI Trợ lý du lịch',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Để AI gợi ý tour phù hợp với bạn',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Categories - theo cột category trong bảng destinations
  Widget _buildCategories() {
    return SliverToBoxAdapter(
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category['id'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category['id'];
                });
                // TODO: Filter destinations by category
              },
              child: Container(
                width: 80,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'],
                      color: isSelected ? Colors.white : AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['label'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : const Color(0xFF374151),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Featured Destinations - từ bảng destinations với is_featured = true
  Widget _buildFeaturedDestinations() {
    return BlocBuilder<DestinationBloc, DestinationState>(
      builder: (context, state) {
        if (state is DestinationLoading) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else if (state is DestinationLoaded) {
          final featuredDestinations = state.destinations;
          if (featuredDestinations.isEmpty) {
            return const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Không có điểm đến nổi bật"),
                ),
              ),
            );
          }

          return SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Điểm đến nổi bật',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to all featured destinations
                        },
                        child: Text(
                          'Xem tất cả',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: featuredDestinations.length,
                    itemBuilder: (context, index) {
                      final destination = featuredDestinations[index];
                      return DestinationFeatured(destination);
                    },
                  ),
                ),
              ],
            ),
          );
        } else if (state is DestinationError) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text("Không thể tải điểm đến nổi bật"),
              ),
            ),
          );
        } else {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
      },
    );
  }



  // Popular Provinces - từ bảng provinces với is_popular = true
  Widget _buildPopularProvinces() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tỉnh thành phổ biến',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to all provinces
                  },
                  child: Text(
                    'Xem tất cả',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _popularProvinces.length,
              itemBuilder: (context, index) {
                final province = _popularProvinces[index];
                return _buildProvinceCard(province);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Province Card Widget
  Widget _buildProvinceCard(Map<String, dynamic> province) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to province destinations
        // Navigator.pushNamed(context, '/province/destinations', arguments: province['id']);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Image placeholder
              Container(
                color: Colors.grey[300],
                child: Center(
                  child: Icon(
                    Icons.location_city,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              // Province info
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      province['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${province['destination_count']}+ địa điểm',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
