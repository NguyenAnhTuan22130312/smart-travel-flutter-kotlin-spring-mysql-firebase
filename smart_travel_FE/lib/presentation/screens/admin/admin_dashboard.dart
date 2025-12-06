import 'package:flutter/material.dart';
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  // Danh sách menu
  final List<Map<String, dynamic>> menuItems = const [
    {'id': 'dashboard', 'icon': Icons.dashboard, 'label': 'Dashboard', 'color': Colors.blue},
    {'id': 'admin/provinces', 'icon': Icons.edit_location_alt, 'label': 'Tỉnh Thành', 'color': Colors.green},
    {'id': 'admin/destinations', 'icon': Icons.location_pin, 'label': 'Địa Điểm', 'color': Colors.orange},
    {'id': 'admin/hotels', 'icon': Icons.hotel, 'label': 'Khách Sạn', 'color': Colors.purple},
    {'id': 'admin/tours', 'icon': Icons.tour, 'label': 'Tour', 'color': Colors.teal},
    {'id': 'admin/bookings', 'icon': Icons.calendar_month, 'label': 'Lịch Đặt', 'color': Colors.red},
    {'id': 'admin/promotions', 'icon': Icons.sticky_note_2_outlined, 'label': 'Khuyến Mãi', 'color': Colors.pink},
    {'id': 'admin/users', 'icon': Icons.people, 'label': 'Người Dùng', 'color': Colors.indigo},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              route: item['id'] == 'dashboard' ? null : '/${item['id']}',
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: thêm logic xoá token nếu có
          Navigator.pushReplacementNamed(context, '/login');
        },
        tooltip: 'Đăng xuất',
        child: const Icon(Icons.logout),
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
      onTap: route != null
          ? () => Navigator.pushNamed(context, route)
          : null, // Dashboard thì không cần chuyển trang
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.white,
            ),
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