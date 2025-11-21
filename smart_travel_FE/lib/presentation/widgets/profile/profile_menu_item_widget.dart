import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ProfileMenuItemWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool showDivider;

  const ProfileMenuItemWidget({
    Key? key,
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
    this.iconColor,
    this.showDivider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: iconColor ?? Theme.of(context).iconTheme.color,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                if (trailing != null && trailing!.isNotEmpty) ...[
                  Text(
                    trailing!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Theme.of(context).dividerColor,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).dividerColor,
            indent: 56,
          ),
      ],
    );
  }
}
