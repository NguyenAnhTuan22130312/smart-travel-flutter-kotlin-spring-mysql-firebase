import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/injection_container.dart' as di;
import 'package:smart_travel/data/data_sources/local/auth_local_data_source.dart';
import 'package:smart_travel/l10n/app_localizations.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_bloc.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_event.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_state.dart';
import 'package:smart_travel/presentation/screens/chat/ai_chat_screen.dart';
import 'package:smart_travel/presentation/screens/profile/favorite_places_screen.dart';
import 'package:smart_travel/presentation/screens/tour/tour_list_screen.dart';
import 'package:smart_travel/presentation/widgets/profile/profile_menu_item_widget.dart';
import 'package:smart_travel/presentation/widgets/common/bottom_navigation.dart';
import 'package:smart_travel/router/route_names.dart';
import '../../theme/app_colors.dart';
import 'package:smart_travel/core/utils/auth_error_handler_mixin.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with AuthErrorHandlerMixin {
  int _selectedIndex = 5; // Profile tab index (Cá nhân)

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadProfile();
  }

  Future<void> _checkAuthAndLoadProfile() async {
    // Check if user is authenticated
    final authDataSource = di.sl<AuthLocalDataSource>();
    final token = await authDataSource.getToken();

    if (token == null || token.isEmpty) {
      // User not authenticated, redirect to login
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      // User authenticated, load profile
      if (mounted) {
        context.read<ProfileBloc>().add(LoadProfile());
      }
    }
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TourListScreen()),
        );
        break;

      case 3: // Khách sạn (Push màn hình mới - Dùng RouteNames chuẩn)
        Navigator.pushNamed(context, RouteNames.hotelList);
        break;

      case 4: // AI Chat (Push màn hình mới)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AIChatScreen()),
        );
        break;

      case 5: // Profile
        setState(() => _selectedIndex = index);
        Navigator.pushReplacementNamed(context, RouteNames.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            // Check if error is related to token expiration
            if (handleTokenExpiration(state.message)) return;

            final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: AppLocalizations.of(context)!.error,
                message: state.message,
                contentType: ContentType.failure,
              ),
            );
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return Center(
              child: Lottie.asset(
                'assets/lottie/travel_is_fun.json',
                width: 200,
                height: 500,
                repeat: true,
              ),
            );
          }

          if (state is ProfileLoaded) {
            final user = state.user;

            return CustomScrollView(
              slivers: [
                // 1. Header Section (Agoda Style)
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      40 + MediaQuery.of(context).padding.top,
                      20,
                      30,
                    ),
                    decoration: const BoxDecoration(
                      gradient: AppColors.mainGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  user.avatarUrl != null &&
                                          user.avatarUrl!.isNotEmpty
                                      ? NetworkImage(user.avatarUrl!)
                                      : null,
                              child:
                                  user.avatarUrl == null ||
                                          user.avatarUrl!.isEmpty
                                      ? Icon(
                                        Icons.person,
                                        size: 30,
                                        color: AppColors.primary,
                                      )
                                      : null,
                            ),
                            const SizedBox(width: 16),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.fullName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.email,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                    ),
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

                // 2. Menu Sections (Cards)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Section 1: Tài khoản của tôi
                        _buildSection(
                          context,
                          title: AppLocalizations.of(context)!.myAccount,
                          items: [
                            ProfileMenuItemWidget(
                              icon: Icons.person_outline,
                              title: AppLocalizations.of(context)!.profile,
                              iconColor: AppColors.primary,
                              onTap: () async {
                                await Navigator.pushNamed(
                                  context,
                                  '/profile/edit',
                                );
                                if (context.mounted) {
                                  context.read<ProfileBloc>().add(
                                    LoadProfile(),
                                  );
                                }
                              },
                            ),
                            ProfileMenuItemWidget(
                              icon: Icons.receipt_long_outlined,
                              title: AppLocalizations.of(context)!.myInvoices,
                              // title: AppLocalizations.of(context)!.myTrips, // ← khuyến khích thêm vào file .arb
                              iconColor: AppColors.primary,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  RouteNames.myInvoices,
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // NEW SECTION: Danh sách yêu thích
                        _buildSection(
                          context,
                          title:
                              "Hoạt động của tôi", // Hoặc AppLocalizations.of(context)!.myActivity
                          items: [
                            // Trong profile_screen.dart
                            ProfileMenuItemWidget(
                              icon: Icons.favorite_border_rounded,
                              title: "Danh sách địa điểm yêu thích",
                              iconColor: Colors.pinkAccent,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const FavoritePlacesScreen(),
                                  ),
                                );
                              },
                              showDivider: false,
                            ),
                          ],
                        ),
                        // Section 2: Quyền lợi thành viên
                        _buildSection(
                          context,
                          title: AppLocalizations.of(context)!.memberBenefits,
                          items: [
                            ProfileMenuItemWidget(
                              icon: Icons.star_outline,
                              title: AppLocalizations.of(context)!.samtraVip,
                              iconColor: AppColors.primary,
                              onTap: () async {
                                await Navigator.pushNamed(
                                  context,
                                  '/profile/level',
                                );
                                if (context.mounted) {
                                  context.read<ProfileBloc>().add(
                                    LoadProfile(),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Section 3: Cài đặt
                        _buildSection(
                          context,
                          title: AppLocalizations.of(context)!.settings,
                          items: [
                            ProfileMenuItemWidget(
                              icon: Icons.settings_outlined,
                              title:
                                  AppLocalizations.of(context)!.generalSettings,
                              iconColor: AppColors.primary,
                              onTap: () async {
                                await Navigator.pushNamed(
                                  context,
                                  '/profile/settings',
                                );
                                if (context.mounted) {
                                  context.read<ProfileBloc>().add(
                                    LoadProfile(),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Section 4: Trợ giúp và thông tin
                        _buildSection(
                          context,
                          title: AppLocalizations.of(context)!.helpAndInfo,
                          items: [
                            ProfileMenuItemWidget(
                              icon: Icons.info_outline,
                              title: AppLocalizations.of(context)!.aboutUs,
                              iconColor: AppColors.primary,
                              onTap: () {},
                            ),
                            ProfileMenuItemWidget(
                              icon: Icons.headset_mic_outlined,
                              title: AppLocalizations.of(context)!.helpCenter,
                              iconColor: AppColors.primary,
                              onTap: () {},
                              showDivider: false,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Section 5: Quản lý tài khoản
                        _buildSection(
                          context,
                          title:
                              AppLocalizations.of(context)!.accountManagement,
                          items: [
                            ProfileMenuItemWidget(
                              icon: Icons.lock_outline,
                              title:
                                  AppLocalizations.of(context)!.changePassword,
                              iconColor: AppColors.primary,
                              onTap: () async {
                                await Navigator.pushNamed(
                                  context,
                                  '/profile/change-password',
                                );
                                if (context.mounted) {
                                  context.read<ProfileBloc>().add(
                                    LoadProfile(),
                                  );
                                }
                              },
                            ),
                            ProfileMenuItemWidget(
                              icon: Icons.delete_outline,
                              title:
                                  AppLocalizations.of(context)!.deleteAccount,
                              iconColor: Colors.red,
                              onTap: () async {
                                await Navigator.pushNamed(
                                  context,
                                  '/profile/account-management',
                                );
                                if (context.mounted) {
                                  context.read<ProfileBloc>().add(
                                    LoadProfile(),
                                  );
                                }
                              },
                            ),
                            ProfileMenuItemWidget(
                              icon: Icons.logout,
                              title: AppLocalizations.of(context)!.logout,
                              iconColor: Colors.red,
                              onTap: () => _showLogoutDialog(context),
                              showDivider: false,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          // Initial or Error state
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.errorLoadProfile,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ProfileBloc>().add(LoadProfile());
                  },
                  child: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNavigationWithIndicator(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.logout),
            content: Text(AppLocalizations.of(context)!.logoutConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<ProfileBloc>().add(Logout());
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text(
                  AppLocalizations.of(context)!.logout,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
