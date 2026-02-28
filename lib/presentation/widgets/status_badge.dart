import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/project_model.dart';

/// Premium Status Badge with Tint + Text style
/// Airbnb-inspired subtle backgrounds with bold text colors
class StatusBadge extends StatelessWidget {
  final ProjectStatus status;
  final double? fontSize;
  final EdgeInsets? padding;
  final bool showIcon;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize,
    this.padding,
    this.showIcon = false,
    this.compact = false,
  });

  // Tint + Text color pairs for each status
  Color get _backgroundColor {
    switch (status) {
      case ProjectStatus.active:
        return AppColors.green50;
      case ProjectStatus.slowing:
        return AppColors.amber50;
      case ProjectStatus.stalled:
        return AppColors.red50;
      case ProjectStatus.unverified:
        return AppColors.gray50;
    }
  }

  Color get _textColor {
    switch (status) {
      case ProjectStatus.active:
        return AppColors.green700;
      case ProjectStatus.slowing:
        return AppColors.amber700;
      case ProjectStatus.stalled:
        return AppColors.red700;
      case ProjectStatus.unverified:
        return AppColors.gray600;
    }
  }

  Color get _borderColor {
    switch (status) {
      case ProjectStatus.active:
        return AppColors.green100;
      case ProjectStatus.slowing:
        return AppColors.amber100;
      case ProjectStatus.stalled:
        return AppColors.red100;
      case ProjectStatus.unverified:
        return AppColors.gray100;
    }
  }

  IconData get _icon {
    switch (status) {
      case ProjectStatus.active:
        return Icons.play_circle_outline_rounded;
      case ProjectStatus.slowing:
        return Icons.schedule_rounded;
      case ProjectStatus.stalled:
        return Icons.pause_circle_outline_rounded;
      case ProjectStatus.unverified:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveFontSize = fontSize ?? (compact ? 11.0 : 12.0);
    final effectivePadding = padding ?? EdgeInsets.symmetric(
      horizontal: compact ? AppSpacing.xs : AppSpacing.sm,
      vertical: compact ? 3.0 : AppSpacing.xxs,
    );

    return Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              _icon,
              size: effectiveFontSize + 2,
              color: _textColor,
            ),
            SizedBox(width: compact ? 4 : 6),
          ],
          Text(
            status.label,
            style: AppTypography.badge.copyWith(
              color: _textColor,
              fontSize: effectiveFontSize,
            ),
          ),
        ],
      ),
    );
  }
}

/// Confidence Badge with similar Tint + Text style
class ConfidenceBadge extends StatelessWidget {
  final ConfidenceLevel confidence;
  final double? fontSize;
  final EdgeInsets? padding;
  final bool showIcon;
  final bool compact;

  const ConfidenceBadge({
    super.key,
    required this.confidence,
    this.fontSize,
    this.padding,
    this.showIcon = false,
    this.compact = false,
  });

  Color get _backgroundColor {
    switch (confidence) {
      case ConfidenceLevel.high:
        return AppColors.blue50;
      case ConfidenceLevel.medium:
        return AppColors.amber50;
      case ConfidenceLevel.low:
        return AppColors.gray50;
    }
  }

  Color get _textColor {
    switch (confidence) {
      case ConfidenceLevel.high:
        return AppColors.blue700;
      case ConfidenceLevel.medium:
        return AppColors.amber700;
      case ConfidenceLevel.low:
        return AppColors.gray600;
    }
  }

  Color get _borderColor {
    switch (confidence) {
      case ConfidenceLevel.high:
        return AppColors.blue100;
      case ConfidenceLevel.medium:
        return AppColors.amber100;
      case ConfidenceLevel.low:
        return AppColors.gray100;
    }
  }

  IconData get _icon {
    switch (confidence) {
      case ConfidenceLevel.high:
        return Icons.verified_rounded;
      case ConfidenceLevel.medium:
        return Icons.info_outline_rounded;
      case ConfidenceLevel.low:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveFontSize = fontSize ?? (compact ? 10.0 : 11.0);
    final effectivePadding = padding ?? EdgeInsets.symmetric(
      horizontal: compact ? 6.0 : AppSpacing.xs,
      vertical: compact ? 2.0 : 3.0,
    );

    return Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              _icon,
              size: effectiveFontSize + 1,
              color: _textColor,
            ),
            SizedBox(width: compact ? 3 : 4),
          ],
          Text(
            '${confidence.label} conf.',
            style: AppTypography.captionMedium.copyWith(
              color: _textColor,
              fontSize: effectiveFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Category Badge with category-specific colors
class CategoryBadge extends StatelessWidget {
  final ProjectCategory category;
  final double? fontSize;
  final EdgeInsets? padding;
  final bool showIcon;
  final bool compact;

  const CategoryBadge({
    super.key,
    required this.category,
    this.fontSize,
    this.padding,
    this.showIcon = true,
    this.compact = false,
  });

  Color get _backgroundColor {
    switch (category) {
      case ProjectCategory.housing:
        return AppColors.indigo50;
      case ProjectCategory.road:
        return AppColors.amber50;
      case ProjectCategory.drainage:
        return AppColors.cyan50;
      case ProjectCategory.school:
        return AppColors.pink50;
    }
  }

  Color get _textColor {
    switch (category) {
      case ProjectCategory.housing:
        return AppColors.indigo700;
      case ProjectCategory.road:
        return AppColors.amber700;
      case ProjectCategory.drainage:
        return AppColors.cyan700;
      case ProjectCategory.school:
        return AppColors.pink700;
    }
  }

  Color get _borderColor {
    switch (category) {
      case ProjectCategory.housing:
        return AppColors.indigo100;
      case ProjectCategory.road:
        return AppColors.amber100;
      case ProjectCategory.drainage:
        return AppColors.cyan100;
      case ProjectCategory.school:
        return AppColors.pink100;
    }
  }

  IconData get _icon {
    switch (category) {
      case ProjectCategory.housing:
        return Icons.apartment_rounded;
      case ProjectCategory.road:
        return Icons.route_rounded;
      case ProjectCategory.drainage:
        return Icons.water_rounded;
      case ProjectCategory.school:
        return Icons.school_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveFontSize = fontSize ?? (compact ? 11.0 : 12.0);
    final effectivePadding = padding ?? EdgeInsets.symmetric(
      horizontal: compact ? AppSpacing.xs : AppSpacing.sm,
      vertical: compact ? 3.0 : AppSpacing.xxs,
    );

    return Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              _icon,
              size: effectiveFontSize + 2,
              color: _textColor,
            ),
            SizedBox(width: compact ? 4 : 6),
          ],
          Text(
            category.label,
            style: AppTypography.badge.copyWith(
              color: _textColor,
              fontSize: effectiveFontSize,
            ),
          ),
        ],
      ),
    );
  }
}
