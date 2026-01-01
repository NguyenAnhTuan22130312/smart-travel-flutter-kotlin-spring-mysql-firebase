import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_bloc.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_event.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_state.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_bloc.dart';
import 'package:smart_travel/presentation/blocs/province/province_bloc.dart';
import 'package:smart_travel/presentation/blocs/province/province_event.dart';
import 'package:smart_travel/presentation/blocs/province/province_state.dart';
import 'package:smart_travel/presentation/screens/chat/ai_chat_screen.dart';
import 'package:smart_travel/presentation/screens/tour/tour_list_screen.dart';
import 'package:smart_travel/presentation/widgets/category/custom_category.dart';
import 'package:smart_travel/presentation/widgets/common/bottom_navigation.dart';
import 'package:smart_travel/presentation/widgets/common/refreshable_scroll_view.dart';
import 'package:smart_travel/presentation/widgets/destination/destination_card.dart';
import 'package:smart_travel/presentation/widgets/province/province_is_popular_card.dart';
import 'package:smart_travel/router/route_names.dart';
import '../../theme/app_colors.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 1;
  String _sortBy = 'popular'; // popular, rating, price
  RangeValues _priceRange = const RangeValues(0, 10000000);
  double _minRating = 0;
  // Biến tạm (dùng trong bottom sheet)
  late String _tempSortBy;
  late RangeValues _tempPriceRange;
  late double _tempMinRating;

  late AnimationController _filterAnimationController;

  @override
  void initState() {
    super.initState();
    _filterAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    // Nếu ấn vào tab đang đứng thì không làm gì
    if (index == _selectedIndex) return;

    switch (index) {
      case 0: // Home
        setState(() => _selectedIndex = index);
        Navigator.pushReplacementNamed(context, RouteNames.home);
        break;

      case 1: // Khám phá
        setState(() => _selectedIndex = index);
        Navigator.pushReplacementNamed(context, RouteNames.explore);
        break;

      case 2: // Tour (Push màn hình mới)
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TourListScreen()));
        break;

      case 3: // Khách sạn (Push màn hình mới - Dùng RouteNames chuẩn)
        Navigator.pushNamed(context, RouteNames.hotelList);
        break;

      case 4: // AI Chat (Push màn hình mới)
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatScreen()));
        break;

      case 5: // Profile
        setState(() => _selectedIndex = index);
        Navigator.pushReplacementNamed(context, RouteNames.profile);
        break;
    }
  }

  void _showFilterBottomSheet() {
    // Khởi tạo lại giá trị tạm từ giá trị hiện tại
    _tempSortBy = _sortBy;
    _tempPriceRange = _priceRange;
    _tempMinRating = _minRating;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            // Thêm StatefulBuilder ở đây
            builder: (BuildContext context, StateSetter setModalState) {
              return _buildFilterBottomSheet(
                setModalState,
              ); // Truyền setModalState vào
            },
          ),
    );
  }

  //LỌC
  Widget _buildFilterBottomSheet(StateSetter setModalState) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bộ lọc',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sắp xếp theo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSortOptions(setModalState), // Truyền setModalState

                  const SizedBox(height: 24),

                  const Text(
                    'Khoảng giá',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPriceRangeSlider(setModalState), // Truyền setModalState

                  const SizedBox(height: 24),

                  const Text(
                    'Đánh giá',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRatingFilter(setModalState), // Truyền setModalState

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Action buttons (giữ nguyên)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setModalState(() {
                        _tempSortBy = 'popular';
                        _tempPriceRange = const RangeValues(0, 10000000);
                        _tempMinRating = 0;
                      });

                      setState(() {
                        _sortBy = 'popular';
                        _priceRange = const RangeValues(0, 10000000);
                        _minRating = 0;
                      });

                      context.read<DestinationBloc>().add(
                        LoadAllDestinations(),
                      );
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Đặt lại',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _sortBy = _tempSortBy;
                        _priceRange = _tempPriceRange;
                        _minRating = _tempMinRating;
                      });

                      context.read<DestinationBloc>().add(
                        FilterDestinationsEvent(
                          sortBy: _tempSortBy,
                          minPrice: _tempPriceRange.start,
                          maxPrice: _tempPriceRange.end,
                          minRating: _tempMinRating,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Áp dụng',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //OPTION ĐỂ LỌC
  Widget _buildSortOptions(StateSetter setModalState) {
    final options = [
      {'id': 'popular', 'label': 'Phổ biến nhất', 'icon': Icons.trending_up},
      {'id': 'rating', 'label': 'Đánh giá cao', 'icon': Icons.star},
      {
        'id': 'price_low',
        'label': 'Giá thấp đến cao',
        'icon': Icons.arrow_upward,
      },
      {
        'id': 'price_high',
        'label': 'Giá cao đến thấp',
        'icon': Icons.arrow_downward,
      },
    ];

    return Column(
      children:
          options.map((option) {
            final isSelected = _tempSortBy == option['id'];
            return GestureDetector(
              onTap: () {
                setModalState(() {
                  // Dùng setModalState thay vì setState
                  _tempSortBy = option['id'] as String;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      option['icon'] as IconData,
                      color: isSelected ? AppColors.primary : Colors.grey[600],
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option['label'] as String,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : const Color(0xFF374151),
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 22,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  //SLIDER LỌC THEO GIÁ
  Widget _buildPriceRangeSlider(StateSetter setModalState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_tempPriceRange.start.toInt()}đ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGray,
                ),
              ),
              Text(
                '${_tempPriceRange.end.toInt()}đ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGray,
                ),
              ),
            ],
          ),
          RangeSlider(
            values: _tempPriceRange,
            min: 0,
            max: 10000000,
            divisions: 20,
            activeColor: AppColors.primary,
            onChanged: (values) {
              setModalState(() {
                // Dùng setModalState
                _tempPriceRange = values;
              });
            },
          ),
        ],
      ),
    );
  }

  //LỌC THEO ĐÁNH GIÁ
  Widget _buildRatingFilter(StateSetter setModalState) {
    return Column(
      children: List.generate(5, (index) {
        final rating = 5 - index;
        final isSelected = _tempMinRating == rating.toDouble();

        return GestureDetector(
          onTap: () {
            setModalState(() {
              // Dùng setModalState
              _tempMinRating = rating.toDouble();
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                ...List.generate(
                  rating,
                  (i) => Icon(Icons.star, color: Colors.amber, size: 20),
                ),
                ...List.generate(
                  5 - rating,
                  (i) => Icon(
                    Icons.star_border,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Từ $rating sao trở lên',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color:
                        isSelected
                            ? AppColors.primary
                            : const Color(0xFF374151),
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(Icons.check_circle, color: AppColors.primary, size: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshableScrollView(
            slivers: [
              _buildAppBar(),
              _buildSearchBar(),
              const CustomCategory(),
              _buildExploreDestinations(),
              _buildProvinces(),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
      bottomNavigationBar: AppBottomNavigationWithIndicator(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }

  //APPBAR
  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      floating: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.mainGradient,
          ),
        ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              gradient: AppColors.mainGradient,
            ),
            child: const Icon(Icons.explore, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'Khám phá',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
            ),
          ),
        ],
      ),
      centerTitle: false,
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.white, Colors.grey[50]!]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm địa điểm du lịch...',
              hintStyle: TextStyle(color: AppColors.textGray, fontSize: 14),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.search, color: AppColors.primary, size: 20),
              ),
              suffixIcon: GestureDetector(
                onTap: _showFilterBottomSheet,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.tune, color: Colors.white, size: 20),
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onTap: () {},
            onChanged: (value) {
              context.read<DestinationBloc>().add(
                SearchDestinationEvent(value),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExploreDestinations() {
    return BlocBuilder<DestinationBloc, DestinationState>(
       builder: (context, state) {
        // 1. Đang loading → hiện loading
        if (state is FilterDestinationLoading) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Có dữ liệu → hiển thị bình thường
        if (state is FilterDestinationLoaded) {
          final destinations = state.destinations;

          if (destinations.isEmpty) {
            return const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.explore_off, size: 64, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'Không tìm thấy điểm đến',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Tiêu đề
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.green.withOpacity(0.2),
                        AppColors.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Địa điểm du lịch (${destinations.length})',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed:
                            () => context.read<DestinationBloc>().add(
                              LoadAllDestinations(loadAll: true),
                            ),
                        child: const Text(
                          'Xem tất cả',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: destinations.length,
                  itemBuilder:
                      (context, index) => DestinationCart(destinations[index]),
                ),
              ]),
            ),
          );
        }

        // 3. MỌI TRƯỜNG HỢP KHÁC (Initial, Error, v.v.) → TỰ ĐỘNG LOAD LẠI + HIỆN LOADING
        // ← Đây là chỗ quan trọng nhất!
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<DestinationBloc>().add(LoadAllDestinations());
        });

        return const SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProvinces() {
    return BlocBuilder<ProvinceBloc, ProvinceState>(
      builder: (context, state) {
        if (state is ProvinceLoading) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 3,
                ),
              ),
            ),
          );
        } else if (state is ProvinceLoaded) {
          final provinces = state.province;
          if (provinces.isEmpty) {
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }

          return SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.green.withOpacity(0.2),
                          AppColors.primary.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.green.withOpacity(0.1),
                                AppColors.primary.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.place,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Tỉnh thành (${provinces.length})',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: provinces.length,
                    itemBuilder: (context, index) {
                      final province = provinces[index];
                      return ProvinceIsPopular(province);
                    },
                  ),
                ],
              ),
            ),
          );
        } else if (state is ProvinceError) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}
