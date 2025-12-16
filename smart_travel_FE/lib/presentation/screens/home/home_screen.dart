import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_bloc.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_event.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_state.dart';
import 'package:smart_travel/presentation/blocs/province/province_bloc.dart';
import 'package:smart_travel/presentation/blocs/province/province_event.dart';
import 'package:smart_travel/presentation/blocs/province/province_state.dart';
import 'package:smart_travel/presentation/widgets/category/custom_category.dart';
import 'package:smart_travel/presentation/widgets/common/bottom_navigation.dart';
import 'package:smart_travel/presentation/widgets/destination/destination_card.dart';
import 'package:smart_travel/presentation/widgets/province/province_is_popular_card.dart';
import 'package:smart_travel/presentation/screens/booking/booking_screen.dart';
import 'package:smart_travel/presentation/screens/booking/booking_args.dart';
import '../../theme/app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smart_travel/presentation/screens/chat/ai_chat_screen.dart';

import 'package:smart_travel/presentation/blocs/profile/profile_bloc.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_event.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0; // Index cho thanh điều hướng dưới

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<DestinationBloc>().add(LoadAllDestinations());
    context.read<DestinationBloc>().add(LoadFeaturedDestinations());
    context.read<ProvinceBloc>().add(LoadProvinceIsPopular());
    // Load profile data
    context.read<ProfileBloc>().add(LoadProfile());
  }

  void _onNavItemTapped(int index) {
    // Dãy routes tương ứng với các tab
    final List<String> routes = ['/home', '/explore', '/booking', '/hotel-list', '/ai_chat', '/profile'];
    final String routeName = routes[index];

    // // 1. Trường hợp đặc biệt: Đặt tour (index 2)
    // if (index == 2) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => const BookingScreen()),
    //   );
    //   // KHÔNG CẦN return, vì logic tiếp theo cũng có thể đúng (nếu bạn muốn highlight tab)
    // }
    //
    // // 2. Trường hợp màn hình Phụ cần nút Back: Khách sạn (index 3)
    // else
      if (index == 3) {
      // SỬ DỤNG pushNamed để GIỮ HomeScreen lại trong Stack.
      Navigator.pushNamed(context, routeName);

      // KHÔNG thay đổi _selectedIndex, giữ tab Home (hoặc tab hiện tại) được highlight
      return;
    // 3. Trường hợp chuyển đổi giữa các tab chính (0, 1, 4, 5)
    } else if (index == 4) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AIChatScreen()),
        );
        // Không cần return nếu bạn muốn tab bar ở dưới sáng lên icon chat
        // Nhưng thường Chat sẽ mở ra màn hình riêng, nên return để giữ tab cũ cũng được.
        return;
      }

      // 4. Profile (Index 5) - SỬA LẠI INDEX CHO ĐÚNG
      else if (index == 5) {
        Navigator.pushNamed(context, '/profile');
        return;
      } else {
      if (index == _selectedIndex) {
        return; // Tránh điều hướng lại nếu chọn lại tab đang active
      }
      setState(() {
        _selectedIndex = index;
      });
      // Dùng pushReplacementNamed để thay thế màn hình chính hiện tại.
      Navigator.pushReplacementNamed(context, routeName);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
          slivers: [
            _buildAppBar(),
            _buildSearchBar(),
            _buildAIChatBanner(),
            const CustomCategory(),
            _buildDestinationsListByCategory(),
            _buildFeaturedDestinations(),
            _buildPopularProvinces(),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      bottomNavigationBar: AppBottomNavigationWithIndicator(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }

  // App Bar với thông tin user từ ProfileBloc
  Widget _buildAppBar() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        String fullName = 'Khách';
        String? avatarUrl;
        
        if (state is ProfileLoaded) {
          fullName = state.user.fullName;
          avatarUrl = state.user.avatarUrl;
        }

        return SliverAppBar(
          floating: true,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.mainGradient,
            ),
          ),
          title: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl == null || avatarUrl.isEmpty
                      ? Icon(Icons.person, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.hello,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                        color: Colors.white,
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
          ),
        );
      },
    );
  }

  // Search Bar
  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05
                ),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchHint,
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
            onChanged: (value) {
              context.read<DestinationBloc>().add(SearchDestinationEvent(
                  value
              ));
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AIChatScreen()),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
              gradient: AppColors.mainGradient,
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
                  children: [
                    Text(
                      AppLocalizations.of(context)!.aiAssistantTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.aiAssistantSubtitle,
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


  //NEW: Hiển thị danh sách destinations được lọc theo category
  Widget _buildDestinationsListByCategory() {
    return BlocBuilder<DestinationBloc, DestinationState>(
      buildWhen: (previous, current) {
        // Chỉ rebuild khi state là FilterDestination*
        return current is FilterDestinationLoading ||
            current is FilterDestinationLoaded ||
            current is FilterDestinationError;
      },
      builder: (context, state) {
        if (state is FilterDestinationLoading) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: const CircularProgressIndicator(),
              ),
            ),
          );
        } else if (state is FilterDestinationLoaded) {
          final destinations = state.destinations;
          if (destinations.isEmpty) {
            return SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    AppLocalizations.of(context)!.noDestinations,
                    style: TextStyle(
                      color: AppColors.textGray,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }

          return SliverToBoxAdapter(
            child: Column(
              children: [
                //
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(
                        '${AppLocalizations.of(context)!.travelDestinations} (${destinations.length})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<DestinationBloc>().add(LoadAllDestinations(loadAll: true));
                        },
                        child: Text(
                          AppLocalizations.of(context)!.seeAll,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Horizontal Scroll List
                Container(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: destinations.length,
                    itemBuilder: (context, index) {
                      final destination = destinations[index];
                      return Padding(
                        padding: EdgeInsets.only(right: index == destinations.length - 1 ? 0 : 12),
                        child: DestinationCart(destination),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        } else if (state is FilterDestinationError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Lỗi: ${state.message}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  // Featured Destinations - từ bảng destinations với is_featured = true
  Widget _buildFeaturedDestinations() {
    return BlocBuilder<DestinationBloc, DestinationState>(
      buildWhen: (previous, current) {
        //Chỉ rebuild khi state là FeaturedDestination*
        return current is FeaturedDestinationLoading ||
            current is FeaturedDestinationLoaded ||
            current is FeaturedDestinationError;
      },
      builder: (context, state) {
        if (state is FeaturedDestinationLoading) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        else if (state is FeaturedDestinationLoaded) {
          final featuredDestinations = state.destinations;
          if (featuredDestinations.isEmpty) {
            return SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(AppLocalizations.of(context)!.noFeaturedDestinations),
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
                       Text(
                        '${AppLocalizations.of(context)!.featuredDestinations} (${featuredDestinations.length})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<DestinationBloc>().add(LoadFeaturedDestinations(loadAll: true));
                        },
                        child: Text(
                          AppLocalizations.of(context)!.seeAll,
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
                      return Padding(
                        padding: EdgeInsets.only(right: index == featuredDestinations.length - 1 ? 0 : 12),
                        child: DestinationCart(destination),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        } else if (state is FeaturedDestinationError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(AppLocalizations.of(context)!.errorLoadFeatured),
              ),
            ),
          );
        }
        else {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
      },
    );
  }


  // Popular Provinces - từ bảng provinces với is_popular = true
  Widget _buildPopularProvinces() {
    return BlocBuilder<ProvinceBloc, ProvinceState>(
        builder: ( context,  state) {
          if (state is ProvinceLoading) {
            return SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }
          else if (state is ProvincePopularLoaded) {
            final provinceIsPopulars = state.province;
            if (provinceIsPopulars.isEmpty) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(AppLocalizations.of(context)!.noPopularProvinces),
                  ),
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                          '${AppLocalizations.of(context)!.popularProvinces} (${provinceIsPopulars.length})',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Navigate to all provinces
                          },
                          child: Text(
                            AppLocalizations.of(context)!.seeAll,
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
                      itemCount: provinceIsPopulars.length,
                      itemBuilder: (context, index) {
                        final province = provinceIsPopulars[index];
                        return ProvinceIsPopular(province);
                      },
                    ),
                  ],
                ),
              ),
            );
          } else if (state is ProvinceError) {
            return SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(AppLocalizations.of(context)!.errorLoadProvinces),
                ),
              ),
            );
          }
          else {
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }
        }
    );
  }
}
