import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class LevelProgressWidget extends StatelessWidget {
  final String currentLevel;
  final int experiencePoints;
  final int? nextLevelAt;
  final double progressPercentage;

  const LevelProgressWidget({
    Key? key,
    required this.currentLevel,
    required this.experiencePoints,
    this.nextLevelAt,
    required this.progressPercentage,
  }) : super(key: key);

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'đồng':
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'bạc':
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'vàng':
      case 'gold':
        return const Color(0xFFFFD700);
      case 'kim cương':
      case 'diamond':
        return const Color(0xFFB9F2FF);
      default:
        return AppColors.primary;
    }
  }

  IconData _getLevelIcon(String level) {
    switch (level.toLowerCase()) {
      case 'kim cương':
      case 'diamond':
        return Icons.diamond;
      default:
        return Icons.workspace_premium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = _getLevelColor(currentLevel);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getLevelIcon(currentLevel),
                  color: levelColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cấp độ hiện tại',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentLevel,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: levelColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Progress Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Điểm kinh nghiệm',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                nextLevelAt != null
                    ? '$experiencePoints / $nextLevelAt XP'
                    : '$experiencePoints XP (Cấp tối đa)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressPercentage / 100,
              minHeight: 12,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(levelColor),
            ),
          ),
          const SizedBox(height: 8),
          // Percentage
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${progressPercentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: levelColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
