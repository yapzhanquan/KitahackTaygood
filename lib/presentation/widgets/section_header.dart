import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Premium Section Header with optional action button
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;
  final int? count;
  final EdgeInsets? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
    this.count,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.headerMargin,
      ),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: title,
                    style: AppTypography.headlineSmall,
                  ),
                  if (count != null) ...[
                    TextSpan(
                      text: ' ($count)',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionText!,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.slate600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Category Section Header with icon
class CategorySectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int count;
  final String? actionText;
  final VoidCallback? onActionTap;

  const CategorySectionHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.count,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.headlineSmall,
                ),
                Text(
                  '$count projects',
                  style: AppTypography.labelSmall,
                ),
              ],
            ),
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onActionTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  actionText!,
                  style: AppTypography.labelMedium,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
