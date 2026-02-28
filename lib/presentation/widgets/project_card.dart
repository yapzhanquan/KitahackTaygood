import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/project_model.dart';
import '../../providers/compare_provider.dart';
import 'status_badge.dart';

/// Premium Airbnb-style Project Card with:
/// - CachedNetworkImage with realistic Unsplash URLs
/// - Text shadows (BlurRadius: 4, Offset: 0,1) for readability
/// - Hover scale effect (1.03x) with AnimatedContainer
/// - AspectRatio for proper sizing
/// - Soft gradient overlay (transparent to Black/40)
/// - Compare checkbox for Apple-style comparison feature
class ProjectCard extends StatefulWidget {
  final Project project;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;
  final bool isBookmarked;
  final double? width;
  final bool showCompareButton;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.onBookmarkTap,
    this.isBookmarked = false,
    this.width,
    this.showCompareButton = true,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  Color get _categoryColor {
    switch (widget.project.category) {
      case ProjectCategory.housing: return AppColors.indigo500;
      case ProjectCategory.road: return AppColors.amber500;
      case ProjectCategory.drainage: return AppColors.cyan500;
      case ProjectCategory.school: return AppColors.pink500;
    }
  }

  IconData get _categoryIcon {
    switch (widget.project.category) {
      case ProjectCategory.housing: return Icons.apartment_rounded;
      case ProjectCategory.road: return Icons.route_rounded;
      case ProjectCategory.drainage: return Icons.water_rounded;
      case ProjectCategory.school: return Icons.school_rounded;
    }
  }

  String get _imageUrl => widget.project.imageUrl;

  double get _scale {
    if (_isPressed) return 0.97;
    if (_isHovered) return 1.03;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = widget.width ?? AppSpacing.cardMinWidth;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        onLongPressStart: (_) => setState(() => _isPressed = true),
        onLongPressEnd: (_) => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..scale(_scale),
          transformAlignment: Alignment.center,
          width: cardWidth,
          margin: const EdgeInsets.only(left: AppSpacing.pagePadding),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(
              color: _isHovered ? AppColors.slate300 : AppColors.cardBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered 
                    ? Colors.black.withValues(alpha: 0.15)
                    : AppColors.shadowColor,
                blurRadius: _isHovered ? 24 : 8,
                offset: Offset(0, _isHovered ? 8 : 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: AppSpacing.cardImageAspectRatio,
                child: _buildImageSection(),
              ),
              _buildContentSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: _imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildImagePlaceholder(),
            errorWidget: (context, url, error) => _buildErrorPlaceholder(),
          ),
          
          // Soft gradient overlay (transparent to Black/40) for text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          
          // Compare checkbox - top left (before status badge)
          if (widget.showCompareButton)
            Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.sm,
              child: _buildCompareButton(),
            ),
          
          // Glassmorphism status badge - top left (offset if compare button shown)
          Positioned(
            top: AppSpacing.sm,
            left: widget.showCompareButton ? AppSpacing.sm + 36 : AppSpacing.sm,
            child: GlassmorphismStatusBadge(status: widget.project.status),
          ),
          
          // Glassmorphism bookmark button - top right
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: _buildBookmarkButton(),
          ),
          
          // Project name with text shadow - bottom
          Positioned(
            bottom: AppSpacing.sm,
            left: AppSpacing.sm,
            right: AppSpacing.sm,
            child: Text(
              widget.project.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.titleLarge.copyWith(
                color: Colors.white,
                shadows: const [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 4,
                    color: Color(0x73000000), // Colors.black45
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _categoryColor.withValues(alpha: 0.08),
            _categoryColor.withValues(alpha: 0.18),
            _categoryColor.withValues(alpha: 0.12),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: _categoryColor.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Loading...',
              style: AppTypography.captionMedium.copyWith(
                color: _categoryColor.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.slate100,
            AppColors.slate200,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _categoryIcon,
              size: 48,
              color: AppColors.slate400,
            ),
            const SizedBox(height: 8),
            Text(
              'ProjekWatch',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.slate400,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.project.category.label,
              style: AppTypography.captionMedium.copyWith(
                color: AppColors.slate300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarkButton() {
    return GestureDetector(
      onTap: widget.onBookmarkTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 0.5),
            ),
            child: Icon(
              widget.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              size: 18,
              color: widget.isBookmarked ? AppColors.slate900 : AppColors.slate700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompareButton() {
    return Consumer<CompareProvider>(
      builder: (context, provider, _) {
        final isSelected = provider.isSelected(widget.project);
        final isMaxReached = provider.isMaxReached;
        final canSelect = isSelected || !isMaxReached;
        
        return GestureDetector(
          onTap: canSelect ? () => provider.toggleProject(widget.project) : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.slate900 
                      : Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected 
                        ? AppColors.slate900 
                        : Colors.white.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  isSelected ? Icons.check_rounded : Icons.compare_arrows_rounded,
                  size: 16,
                  color: isSelected 
                      ? Colors.white 
                      : (canSelect ? AppColors.slate700 : AppColors.slate400),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContentSection() {
    final df = DateFormat('MMM d, y');

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CategoryBadge(category: widget.project.category, compact: true, showIcon: false),
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 2),
              Expanded(
                child: Text(widget.project.location, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.labelSmall),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              ConfidenceBadge(confidence: widget.project.confidence, compact: true),
              const Spacer(),
              Flexible(
                child: Text('Verified ${df.format(widget.project.lastVerified)}', style: AppTypography.captionMedium, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Glassmorphism Status Badge with BackdropFilter blur
class GlassmorphismStatusBadge extends StatelessWidget {
  final ProjectStatus status;
  const GlassmorphismStatusBadge({super.key, required this.status});

  Color get _textColor {
    switch (status) {
      case ProjectStatus.active: return AppColors.green700;
      case ProjectStatus.slowing: return AppColors.amber700;
      case ProjectStatus.stalled: return AppColors.red700;
      case ProjectStatus.unverified: return AppColors.gray600;
    }
  }

  Color get _dotColor {
    switch (status) {
      case ProjectStatus.active: return AppColors.green500;
      case ProjectStatus.slowing: return AppColors.amber500;
      case ProjectStatus.stalled: return AppColors.red500;
      case ProjectStatus.unverified: return AppColors.gray500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: _dotColor, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(status.label, style: AppTypography.badge.copyWith(color: _textColor, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact version for lists with hover effects
class ProjectCardCompact extends StatefulWidget {
  final Project project;
  final VoidCallback? onTap;
  const ProjectCardCompact({super.key, required this.project, this.onTap});

  @override
  State<ProjectCardCompact> createState() => _ProjectCardCompactState();
}

class _ProjectCardCompactState extends State<ProjectCardCompact> {
  bool _isHovered = false;
  bool _isPressed = false;

  double get _scale {
    if (_isPressed) return 0.97;
    if (_isHovered) return 1.02;
    return 1.0;
  }

  Color _getCategoryColor() {
    switch (widget.project.category) {
      case ProjectCategory.housing: return AppColors.indigo500;
      case ProjectCategory.road: return AppColors.amber500;
      case ProjectCategory.drainage: return AppColors.cyan500;
      case ProjectCategory.school: return AppColors.pink500;
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.project.category) {
      case ProjectCategory.housing: return Icons.apartment_rounded;
      case ProjectCategory.road: return Icons.route_rounded;
      case ProjectCategory.drainage: return Icons.water_rounded;
      case ProjectCategory.school: return Icons.school_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) { setState(() => _isPressed = false); widget.onTap?.call(); },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..scale(_scale),
          transformAlignment: Alignment.center,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: _isHovered ? AppColors.slate300 : AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? Colors.black.withValues(alpha: 0.1) : AppColors.shadowColor,
                blurRadius: _isHovered ? 16 : 4,
                offset: Offset(0, _isHovered ? 4 : 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(_getCategoryIcon(), color: _getCategoryColor(), size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.project.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.titleMedium),
                    const SizedBox(height: 4),
                    Text(widget.project.location, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.labelSmall),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              StatusBadge(status: widget.project.status, compact: true),
            ],
          ),
        ),
      ),
    );
  }
}
