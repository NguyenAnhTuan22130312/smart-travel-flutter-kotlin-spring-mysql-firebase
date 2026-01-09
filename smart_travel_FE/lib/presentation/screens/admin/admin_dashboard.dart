import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_bloc.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_event.dart';
import 'package:smart_travel/presentation/blocs/statistics/statistics_bloc.dart';
import 'package:smart_travel/presentation/blocs/statistics/statistics_event.dart';
import 'package:smart_travel/presentation/blocs/statistics/statistics_state.dart';
import 'package:smart_travel/presentation/widgets/statistic/statistics_overview_widget.dart';

import 'package:smart_travel/presentation/theme/app_colors.dart';
import 'package:smart_travel/injection_container.dart' as di;

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  // Danh sách menu
  final List<Map<String, dynamic>> menuItems = const [
    {
      'id': 'admin/provinces',
      'icon': Icons.edit_location_alt,
      'label': 'Tỉnh Thành',
      'color': Colors.green,
    },
    {
      'id': 'admin/destination',
      'icon': Icons.location_pin,
      'label': 'Địa Điểm',
      'color': Colors.orange,
    },
    {
      'id': 'admin/hotels',
      'icon': Icons.hotel,
      'label': 'Khách Sạn',
      'color': Colors.purple,
    },
    {
      'id': 'admin/tours',
      'icon': Icons.tour,
      'label': 'Tour',
      'color': Colors.teal,
    },
    {
      'id': 'admin/invoices',
      'icon': Icons.receipt_long,
      'label': 'Quản lý đơn hàng',
      'color': Colors.blue,
    },
    {
      'id': 'admin/voucher',
      'icon': Icons.sticky_note_2_outlined,
      'label': 'Khuyến Mãi',
      'color': Colors.pink,
    },
    {
      'id': 'admin/users',
      'icon': Icons.people,
      'label': 'Người Dùng',
      'color': Colors.indigo,
    },
    {
      'id': 'admin/banner',
      'icon': Icons.add_photo_alternate,
      'label': 'Banner',
      'color': Colors.amberAccent,
    },
    {
      'id': 'admin/audio',
      'icon': Icons.audio_file,
      'label': 'audio',
      'color': Colors.deepPurpleAccent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<StatisticsBloc>()..add(const LoadDashboardStats()),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            'Admin Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 2,
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: AppColors.mainGradient),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Statistics Overview at the top
              BlocBuilder<StatisticsBloc, StatisticsState>(
                builder: (context, state) {
                  if (state is StatisticsLoaded) {
                    return StatisticsOverviewWidget(stats: state.stats);
                  }
                  if (state is StatisticsLoading) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade600],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              // Menu Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 cột trên mobile, sẽ tự responsive
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return _buildMenuCard(
                      context: context,
                      icon: item['icon'],
                      label: item['label'],
                      color: item['color'],
                      route:
                          item['id'] == 'dashboard' ? null : '/${item['id']}',
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showLogoutDialog(context);
          },
          tooltip: 'Đăng xuất',
          child: const Icon(Icons.logout),
          backgroundColor: AppColors.green,
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    String? route,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap:
          route != null
              ? () => Navigator.pushNamed(context, route)
              : null, // Dashboard thì không cần chuyển trang
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          title: Text("Xác nhận đăng xuất"),
          content: Text("Bạn có muốn đăng xuất khỏi tài khoản này?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<ProfileBloc>().add(Logout());
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text(
                "Xác nhận",
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
  );
}
