import 'package:flutter/material.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



//Bottom Navigation Bar với indicator line
class AppBottomNavigationWithIndicator extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavigationWithIndicator({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  List<Map<String, dynamic>> _getNavItems(BuildContext context) {
    return [
      {'icon': Icons.home_rounded, 'label': AppLocalizations.of(context)!.navHome},
      {'icon': Icons.explore_rounded, 'label': AppLocalizations.of(context)!.navExplore},
      {'icon': Icons.confirmation_number_rounded, 'label': AppLocalizations.of(context)!.navBooking},
      {'icon': Icons.smart_toy_rounded, 'label': AppLocalizations.of(context)!.navAiChat},
      {'icon': Icons.person_rounded, 'label': AppLocalizations.of(context)!.navProfile},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navItems = _getNavItems(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: isDark ? Border(
          top: BorderSide(
            color: Colors.grey[800]!,
            width: 0.5,
          ),
        ) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
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
              navItems.length,
                  (index) => _buildNavItemWithIndicator(
                context: context,
                icon: navItems[index]['icon'],
                label: navItems[index]['label'],
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
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textGray,
            ),
            const SizedBox(height: 4),
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontSize: isSelected ? 12 : 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textGray,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}