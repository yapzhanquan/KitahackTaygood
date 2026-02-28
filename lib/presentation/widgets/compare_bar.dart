import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/compare_provider.dart';
import '../../models/project_model.dart';
import '../screens/comparison_page.dart';

/// Floating Compare Bar - appears when projects are selected for comparison
/// Inspired by Apple's product comparison UI
class CompareBar extends StatelessWidget {
  const CompareBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CompareProvider>(
      builder: (context, provider, _) {
        return AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          offset: provider.hasSelection ? Offset.zero : const Offset(0, 1),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: provider.hasSelection ? 1.0 : 0.0,
            child: _buildBar(context, provider),
          ),
        );
      },
    );
  }

  Widget _buildBar(BuildContext context, CompareProvider provider) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        0,
        AppSpacing.pagePadding,
        AppSpacing.lg + MediaQuery.of(context).padding.bottom,
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.slate900,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Selected project thumbnails
          Expanded(
            child: _buildThumbnails(context, provider),
          ),
          
          const SizedBox(width: AppSpacing.sm),
          
          // Compare button
          _buildCompareButton(context, provider),
        ],
      ),
    );
  }

  Widget _buildThumbnails(BuildContext context, CompareProvider provider) {
    return Row(
      children: [
        // Close button
        GestureDetector(
          onTap: provider.clearAll,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.slate700,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: const Icon(
              Icons.close_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(width: AppSpacing.sm),
        
        // Thumbnails
        ...provider.selectedProjects.map((project) => 
          _buildThumbnail(context, project, provider),
        ),
        
        // Empty slots
        if (provider.selectedCount < provider.maxSelection)
          ...List.generate(
            provider.maxSelection - provider.selectedCount,
            (index) => _buildEmptySlot(),
          ),
      ],
    );
  }

  Widget _buildThumbnail(BuildContext context, Project project, CompareProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: GestureDetector(
        onTap: () => provider.removeProject(project),
        child: Stack(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.slate600, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd - 2),
                child: CachedNetworkImage(
                  imageUrl: _getImageUrl(project.category),
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppColors.slate700),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.slate700,
                    child: const Icon(Icons.image, color: AppColors.slate500, size: 20),
                  ),
                ),
              ),
            ),
            // Remove indicator
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.slate600,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.slate900, width: 2),
                ),
                child: const Icon(
                  Icons.remove,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySlot() {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: AppColors.slate600,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          color: AppColors.slate800,
        ),
        child: const Icon(
          Icons.add_rounded,
          size: 20,
          color: AppColors.slate500,
        ),
      ),
    );
  }

  Widget _buildCompareButton(BuildContext context, CompareProvider provider) {
    final canCompare = provider.canCompare;
    
    return GestureDetector(
      onTap: canCompare
          ? () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ComparisonPage()),
            )
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: canCompare ? Colors.white : AppColors.slate700,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.compare_arrows_rounded,
              size: 18,
              color: canCompare ? AppColors.slate900 : AppColors.slate500,
            ),
            const SizedBox(width: 6),
            Text(
              'Compare',
              style: AppTypography.labelMedium.copyWith(
                color: canCompare ? AppColors.slate900 : AppColors.slate500,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (provider.selectedCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: canCompare ? AppColors.slate900 : AppColors.slate600,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '${provider.selectedCount}',
                  style: AppTypography.captionMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getImageUrl(ProjectCategory category) {
    switch (category) {
      case ProjectCategory.housing:
        return 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=200&h=200&fit=crop';
      case ProjectCategory.road:
        return 'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?w=200&h=200&fit=crop';
      case ProjectCategory.drainage:
        return 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=200&h=200&fit=crop';
      case ProjectCategory.school:
        return 'https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=200&h=200&fit=crop';
    }
  }
}
