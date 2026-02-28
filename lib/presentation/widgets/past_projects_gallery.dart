import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/developer_network_model.dart';

/// Horizontally scrollable gallery of developer's past projects with community reviews
class PastProjectsGallery extends StatelessWidget {
  final List<PastProject> projects;
  final String developerName;

  const PastProjectsGallery({
    super.key,
    required this.projects,
    required this.developerName,
  });

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.amber50,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: AppColors.amber600,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project Legacy',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate900,
                      ),
                    ),
                    Text(
                      '${projects.length} completed projects',
                      style: AppTypography.captionMedium.copyWith(
                        color: AppColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildLegacyScore(),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Stats Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: _buildStatsRow(),
        ),
        const SizedBox(height: AppSpacing.lg),
        
        // Horizontal Gallery
        SizedBox(
          height: 320,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
            scrollDirection: Axis.horizontal,
            itemCount: projects.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: index < projects.length - 1 ? AppSpacing.md : 0),
                child: _PastProjectCard(project: projects[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.folder_off_rounded,
            size: 48,
            color: AppColors.slate300,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No Past Projects Found',
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.slate500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Unable to retrieve project history for this developer',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.slate400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLegacyScore() {
    final avgRating = projects
        .where((p) => p.communityRating != null)
        .fold<double>(0, (sum, p) => sum + p.communityRating!) /
        projects.where((p) => p.communityRating != null).length;
    
    final problemCount = projects.where((p) => 
        p.status == PastProjectStatus.problemsReported || 
        p.status == PastProjectStatus.abandoned).length;
    
    final isGood = avgRating >= 3.5 && problemCount == 0;
    final isBad = avgRating < 2.5 || problemCount >= 2;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isBad ? AppColors.red50 : isGood ? AppColors.green50 : AppColors.amber50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isBad ? AppColors.red200 : isGood ? AppColors.green200 : AppColors.amber200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 16,
            color: isBad ? AppColors.red600 : isGood ? AppColors.green600 : AppColors.amber600,
          ),
          const SizedBox(width: 4),
          Text(
            avgRating.isNaN ? 'N/A' : avgRating.toStringAsFixed(1),
            style: AppTypography.labelMedium.copyWith(
              color: isBad ? AppColors.red700 : isGood ? AppColors.green700 : AppColors.amber700,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final completedCount = projects.where((p) => p.status == PastProjectStatus.completed).length;
    final delayedCount = projects.where((p) => p.status == PastProjectStatus.delayed).length;
    final problemCount = projects.where((p) => 
        p.status == PastProjectStatus.problemsReported || 
        p.status == PastProjectStatus.abandoned).length;
    final totalUnits = projects.fold<int>(0, (sum, p) => sum + p.units);
    
    return Row(
      children: [
        _buildStatChip('✓ On-time', '$completedCount', AppColors.green600, AppColors.green50),
        const SizedBox(width: 8),
        _buildStatChip('⏱ Delayed', '$delayedCount', AppColors.amber600, AppColors.amber50),
        const SizedBox(width: 8),
        _buildStatChip('⚠️ Problems', '$problemCount', AppColors.red600, AppColors.red50),
        const Spacer(),
        Text(
          '${_formatNumber(totalUnits)} units delivered',
          style: AppTypography.captionMedium.copyWith(
            color: AppColors.slate500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        '$label: $value',
        style: AppTypography.captionMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _PastProjectCard extends StatelessWidget {
  final PastProject project;

  const _PastProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final isBad = project.status == PastProjectStatus.problemsReported || 
                  project.status == PastProjectStatus.abandoned;
    
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isBad ? AppColors.red200 : AppColors.slate200,
          width: isBad ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isBad ? AppColors.red600 : AppColors.slate900).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with status overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLg - 1),
                ),
                child: CachedNetworkImage(
                  imageUrl: project.imageUrl,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.slate100,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.slate400,
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.slate100,
                    child: Icon(Icons.image_not_supported_rounded, color: AppColors.slate300),
                  ),
                ),
              ),
              // Status badge
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: project.status.color,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    project.status.label,
                    style: AppTypography.captionMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              // Rating badge
              if (project.communityRating != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, size: 12, color: AppColors.amber400),
                        const SizedBox(width: 2),
                        Text(
                          project.communityRating!.toStringAsFixed(1),
                          style: AppTypography.captionMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 12, color: AppColors.slate400),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          project.location,
                          style: AppTypography.captionMedium.copyWith(
                            color: AppColors.slate500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildInfoChip(Icons.apartment_rounded, '${project.units} units'),
                      const SizedBox(width: 6),
                      _buildInfoChip(Icons.calendar_today_rounded, '${project.completionDate.year}'),
                    ],
                  ),
                  const Spacer(),
                  
                  // Review snippet
                  if (project.reviewSnippet != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isBad ? AppColors.red50 : AppColors.slate50,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isBad ? Icons.warning_amber_rounded : Icons.format_quote_rounded,
                                size: 12,
                                color: isBad ? AppColors.red500 : AppColors.slate400,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${project.reviewCount} reviews',
                                style: AppTypography.captionMedium.copyWith(
                                  color: AppColors.slate500,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            project.reviewSnippet!,
                            style: AppTypography.captionMedium.copyWith(
                              color: isBad ? AppColors.red700 : AppColors.slate600,
                              fontStyle: FontStyle.italic,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // Community photos indicator
                  if (project.communityPhotos.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.photo_camera_rounded, size: 12, color: AppColors.blue500),
                        const SizedBox(width: 4),
                        Text(
                          '${project.communityPhotos.length} community photos',
                          style: AppTypography.captionMedium.copyWith(
                            color: AppColors.blue600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // View source link
                  InkWell(
                    onTap: () => _launchUrl(project.sourceUrl),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.open_in_new_rounded, size: 12, color: AppColors.blue500),
                        const SizedBox(width: 4),
                        Text(
                          'View Reality',
                          style: AppTypography.captionMedium.copyWith(
                            color: AppColors.blue600,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: AppColors.slate500),
          const SizedBox(width: 3),
          Text(
            text,
            style: AppTypography.captionMedium.copyWith(
              color: AppColors.slate600,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
