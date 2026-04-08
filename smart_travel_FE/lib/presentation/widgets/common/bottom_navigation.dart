import 'package:flutter/material.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';

//Bottom Navigation Bar với indicator line
class AppBottomNavigationWithIndicator extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavigationWithIndicator({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  static final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home_rounded, 'label': 'Trang chủ'},
    {'icon': Icons.explore_rounded, 'label': 'Khám phá'},
    {'icon': Icons.confirmation_number_rounded, 'label': 'Đặt tour'},
    {'icon': Icons.hotel_rounded, 'label': 'Khách sạn'},
    {'icon': Icons.smart_toy_rounded, 'label': 'AI Chat'},
    {'icon': Icons.person_rounded, 'label': 'Cá nhân'},
  ];
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              (index) => _buildNavItemWithIndicator(
                context: context,
                icon: _navItems[index]['icon'],
                label: _navItems[index]['label'],
                isSelected: currentIndex == index,
                onTap: () => onTap(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItemWithIndicator({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final unselectedColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ??
        AppColors.textGray;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: 3,
              width: isSelected ? 30 : 0,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            // Icon
            Icon(
              icon,
              size: 26,
              color: isSelected ? AppColors.primary : unselectedColor,
            ),
            const SizedBox(height: 4),
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontSize: isSelected ? 12 : 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : unselectedColor,
              ),
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
