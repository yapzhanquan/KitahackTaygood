import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/project_model.dart';
import '../../models/checkin_model.dart';
import 'status_badge.dart';

/// Premium Vertical Timeline Widget
/// Custom-built timeline with dot indicators and connecting lines
class VerticalTimeline extends StatelessWidget {
  final List<CheckIn> checkIns;
  final int? maxItems;
  final VoidCallback? onSeeAllTap;

  const VerticalTimeline({
    super.key,
    required this.checkIns,
    this.maxItems,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayItems = maxItems != null 
        ? checkIns.take(maxItems!).toList() 
        : checkIns;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...displayItems.asMap().entries.map((entry) {
          final index = entry.key;
          final checkIn = entry.value;
          final isLast = index == displayItems.length - 1;
          
          return _TimelineItem(
            checkIn: checkIn,
            isLast: isLast && (maxItems == null || checkIns.length <= maxItems!),
            isFirst: index == 0,
          );
        }),
        
        // Show more button
        if (maxItems != null && checkIns.length > maxItems!) ...[
          _buildShowMoreButton(),
        ],
      ],
    );
  }

  Widget _buildShowMoreButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 36),
      child: GestureDetector(
        onTap: onSeeAllTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Show all ${checkIns.length} check-ins',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.xxs),
              Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final CheckIn checkIn;
  final bool isLast;
  final bool isFirst;

  const _TimelineItem({
    required this.checkIn,
    required this.isLast,
    required this.isFirst,
  });

  Color get _dotColor {
    switch (checkIn.status) {
      case ProjectStatus.active:
        return AppColors.green500;
      case ProjectStatus.slowing:
        return AppColors.amber500;
      case ProjectStatus.stalled:
        return AppColors.red500;
      case ProjectStatus.unverified:
        return AppColors.gray400;
    }
  }

  Color get _dotBgColor {
    switch (checkIn.status) {
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

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator column
          _buildTimelineIndicator(),
          
          const SizedBox(width: AppSpacing.md),
          
          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineIndicator() {
    return SizedBox(
      width: 24,
      child: Column(
        children: [
          // Dot with outer glow effect
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: _dotBgColor,
              shape: BoxShape.circle,
              border: Border.all(color: _dotColor, width: 3),
            ),
          ),
          
          // Connecting line
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status + Date
          Row(
            children: [
              StatusBadge(status: checkIn.status, compact: true),
              const Spacer(),
              Text(
                _formatDate(checkIn.timestamp),
                style: AppTypography.captionMedium,
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          // Note
          Text(
            checkIn.note,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: AppSpacing.xs),
          
          // Reporter
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: AppSpacing.xs),
              Text(
                checkIn.reporterName,
                style: AppTypography.captionMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          checkIn.reporterName.isNotEmpty 
              ? checkIn.reporterName[0].toUpperCase() 
              : '?',
          style: AppTypography.captionMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final months = (diff.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }
}

/// Lightweight review card for the reviews section with photo support
class CheckInReviewCard extends StatelessWidget {
  final CheckIn checkIn;

  const CheckInReviewCard({
    super.key,
    required this.checkIn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      checkIn.reporterName,
                      style: AppTypography.titleSmall,
                    ),
                    Text(
                      _formatDate(checkIn.timestamp),
                      style: AppTypography.captionMedium,
                    ),
                  ],
                ),
              ),
              StatusBadge(status: checkIn.status, compact: true),
            ],
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          // Note
          Text(
            checkIn.note,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),

          // Photo evidence (grainy site photo)
          if (checkIn.photoUrl != null) ...[
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: checkIn.photoUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 120,
                      color: AppColors.slate100,
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 120,
                      color: AppColors.slate100,
                      child: const Center(child: Icon(Icons.image_not_supported_outlined, color: AppColors.slate400)),
                    ),
                  ),
                  // "Community Evidence" badge overlay
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt_rounded, size: 12, color: Colors.white.withValues(alpha: 0.9)),
                          const SizedBox(width: 4),
                          Text(
                            'Community Evidence',
                            style: AppTypography.captionMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Check-in ID badge (source citation)
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.blue50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.blue100, width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user_rounded, size: 10, color: AppColors.blue500),
                    const SizedBox(width: 4),
                    Text(
                      'ID: ${checkIn.id}',
                      style: AppTypography.captionMedium.copyWith(
                        color: AppColors.blue600,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(Icons.link_rounded, size: 12, color: AppColors.slate400),
              const SizedBox(width: 4),
              Text(
                'Verified on-site',
                style: AppTypography.captionMedium.copyWith(color: AppColors.slate400, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: AppSpacing.avatarMd,
      height: AppSpacing.avatarMd,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Center(
        child: Text(
          checkIn.reporterName.isNotEmpty 
              ? checkIn.reporterName[0].toUpperCase() 
              : '?',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
