import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../data/services/news_scraper_service.dart';
import '../../providers/project_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/compare_provider.dart';
import '../../models/project_model.dart';
import '../widgets/status_badge.dart';
import '../widgets/vertical_timeline.dart';
import '../widgets/project_card.dart';
import '../widgets/property_map.dart';
import 'add_checkin_page.dart';
import 'comparison_page.dart';
import 'developer_profile_page.dart';
import '../../auth/login_guard.dart';

/// Premium Airbnb-style Project Detail Page
class ProjectDetailPage extends StatelessWidget {
  final String projectId;

  const ProjectDetailPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, provider, _) {
        final project = provider.getProjectById(projectId);
        final isSaved = provider.isProjectSaved(project.id);
        
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  _buildHeroAppBar(
                    context,
                    project,
                    isSaved: isSaved,
                  ),
                  SliverToBoxAdapter(
                    child: _buildContent(context, project),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _StickyBottomBar(project: project),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroAppBar(
    BuildContext context,
    Project project, {
    required bool isSaved,
  }) {
    final color = _getCategoryColor(project.category);
    
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      leading: _buildCircleButton(
        icon: Icons.arrow_back_rounded,
        onTap: () => Navigator.pop(context),
      ),
      actions: [
        _buildCircleButton(
          icon: Icons.share_outlined,
          onTap: () => _shareProject(context, project),
        ),
        const SizedBox(width: AppSpacing.xs),
        _buildCircleButton(
          icon: isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          onTap: () => _toggleSavedProject(context, project),
        ),
        const SizedBox(width: AppSpacing.md),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: project.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildImagePlaceholder(color),
              errorWidget: (context, url, error) => _buildErrorPlaceholder(color, project.category),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [Colors.black.withValues(alpha: 0.3), Colors.transparent],
                ),
              ),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0, height: 120,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.background.withValues(alpha: 0.9),
                      AppColors.background,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 100, left: AppSpacing.md,
              child: GlassmorphismStatusBadge(status: project.status),
            ),
            Positioned(
              bottom: AppSpacing.md, right: AppSpacing.md,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.grid_view_rounded, size: 16, color: AppColors.textPrimary),
                        const SizedBox(width: AppSpacing.xs),
                        Text(AppStrings.showAllPhotos, style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareProject(BuildContext context, Project project) async {
    final shareText = StringBuffer()
      ..writeln('Project: ${project.name}')
      ..writeln('Location: ${project.location}')
      ..writeln('Status: ${project.status.label}')
      ..writeln('Image: ${project.imageUrl}')
      ..writeln('Shared via ProjekWatch');

    await Clipboard.setData(ClipboardData(text: shareText.toString()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Project details copied. Paste to share.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleSavedProject(BuildContext context, Project project) {
    final provider = context.read<ProjectProvider>();
    final wasSaved = provider.isProjectSaved(project.id);
    provider.toggleSavedProject(project.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(wasSaved ? 'Removed from saved projects' : 'Saved project'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.xs),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.glassBg, shape: BoxShape.circle, border: Border.all(color: AppColors.glassStroke)),
              child: Icon(icon, size: 20, color: AppColors.slate700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.08), color.withValues(alpha: 0.18), color.withValues(alpha: 0.12)],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: color.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder(Color color, ProjectCategory category) {
    IconData icon;
    switch (category) {
      case ProjectCategory.housing: icon = Icons.apartment_rounded;
      case ProjectCategory.road: icon = Icons.route_rounded;
      case ProjectCategory.drainage: icon = Icons.water_rounded;
      case ProjectCategory.school: icon = Icons.school_rounded;
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.slate100, AppColors.slate200],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.slate400),
            const SizedBox(height: 12),
            Text(
              'ProjekWatch',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.slate400,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Image unavailable',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.slate300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Project project) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.bottomBarHeight + 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TitleSection(project: project),
          const _SectionDivider(),
          _AgencySection(project: project),
          const _SectionDivider(),
          _NewsCoverageSection(project: project),
          const _SectionDivider(),
          _HighlightsSection(project: project),
          const _SectionDivider(),
          _DescriptionSection(project: project),
          const _SectionDivider(),
          _DetailsSection(project: project),
          const _SectionDivider(),
          _TimelineSection(project: project),
          const _SectionDivider(),
          _ReviewsSection(project: project),
          const _SectionDivider(),
          _LocationSection(project: project),
          const _SectionDivider(),
          _CompareSection(project: project),
          const _SectionDivider(),
          const _DisclaimerSection(),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Color _getCategoryColor(ProjectCategory category) {
    switch (category) {
      case ProjectCategory.housing: return AppColors.indigo500;
      case ProjectCategory.road: return AppColors.amber500;
      case ProjectCategory.drainage: return AppColors.cyan500;
      case ProjectCategory.school: return AppColors.pink500;
    }
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding), height: 1, color: AppColors.divider);
}

class _TitleSection extends StatelessWidget {
  final Project project;
  const _TitleSection({required this.project});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(project.name, style: AppTypography.displaySmall),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              CategoryBadge(category: project.category),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Expanded(child: Text(project.location, style: AppTypography.subtitle, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(children: [StatusBadge(status: project.status, showIcon: true), const SizedBox(width: AppSpacing.sm), ConfidenceBadge(confidence: project.confidence, showIcon: true)]),
        ],
      ),
    );
  }
}

class _AgencySection extends StatefulWidget {
  final Project project;
  const _AgencySection({required this.project});

  @override
  State<_AgencySection> createState() => _AgencySectionState();
}

class _AgencySectionState extends State<_AgencySection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final profile = project.developerProfile;
    final hasSources = project.scrapedSources.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding, vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Agency header row
          Row(
            children: [
              Container(
                width: AppSpacing.avatarLg, height: AppSpacing.avatarLg,
                decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
                child: const Icon(Icons.business_rounded, color: AppColors.textPrimary, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${AppStrings.managedBy} ${project.agencyOrDeveloper}', style: AppTypography.titleMedium),
                    const SizedBox(height: 2),
                    Text(AppStrings.communityCheckInsCount(project.checkIns.length), style: AppTypography.subtitle),
                  ],
                ),
              ),
              if (hasSources || profile != null)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => DeveloperProfilePage(project: project)),
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.indigo600, AppColors.indigo700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.indigo600.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.hub_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('Developer', style: AppTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Expandable Developer Background card
          if (hasSources || profile != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _DeveloperBackgroundCard(project: project, isExpanded: _isExpanded, onToggle: () => setState(() => _isExpanded = !_isExpanded)),
          ],
        ],
      ),
    );
  }
}

class _DeveloperBackgroundCard extends StatelessWidget {
  final Project project;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _DeveloperBackgroundCard({
    required this.project,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final profile = project.developerProfile;
    final sources = project.scrapedSources;
    final df = DateFormat('MMM d, yyyy');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Header - always visible
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: const Icon(Icons.person_outline_rounded, size: 22, color: AppColors.slate600),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Developer Background (Auto)', style: AppTypography.titleMedium),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.green50,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                            ),
                            child: Text('Ready', style: AppTypography.labelSmall.copyWith(color: AppColors.green600, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.slate400),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Expanded content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedContent(context, profile, sources, df),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, DeveloperProfile? profile, List<ScrapedSource> sources, DateFormat df) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, color: AppColors.slate100),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timestamp
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 14, color: AppColors.slate400),
                  const SizedBox(width: 4),
                  Text(
                    'Updated ${df.format(DateTime.now())}',
                    style: AppTypography.captionMedium.copyWith(color: AppColors.slate400),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Summary
              Text(
                profile != null
                    ? '${profile.name} — ${profile.litigationNote ?? "no significant risk flags detected from available data."}'
                    : '${project.agencyOrDeveloper} — background check in progress.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Sources
              if (sources.isNotEmpty) ...[
                Text('Sources', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.sm),
                ...sources.take(3).map((source) => _buildSourceItem(context, source)),
                if (sources.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${sources.length - 3} more sources',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.indigo500, fontWeight: FontWeight.w500),
                    ),
                  ),
              ],

              const SizedBox(height: AppSpacing.lg),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Refresh'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.slate700,
                        side: const BorderSide(color: AppColors.slate300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Consumer<ReportProvider>(
                      builder: (context, reportProvider, _) {
                        return _GenerateReportButton(
                          project: project,
                          provider: reportProvider,
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),
              // Disclaimer
              Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 12, color: AppColors.slate400),
                  const SizedBox(width: 4),
                  Text(
                    'Public sources; may be incomplete.',
                    style: AppTypography.captionMedium.copyWith(color: AppColors.slate400, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSourceItem(BuildContext context, ScrapedSource source) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final uri = Uri.parse(source.url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(source.typeIcon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(source.title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(source.snippet ?? source.domain, style: AppTypography.captionMedium.copyWith(color: AppColors.slate400), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${_getConfidencePercent(source)}%',
                  style: AppTypography.labelSmall.copyWith(
                    color: _getConfidenceColor(source),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.slate400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getConfidencePercent(ScrapedSource source) {
    switch (source.type) {
      case SourceType.government: return 90;
      case SourceType.news: return 50;
      case SourceType.developer: return 90;
      case SourceType.forum: return 50;
      case SourceType.community: return 60;
    }
  }

  Color _getConfidenceColor(ScrapedSource source) {
    final pct = _getConfidencePercent(source);
    if (pct >= 70) return AppColors.green600;
    if (pct >= 50) return AppColors.amber600;
    return AppColors.red600;
  }
}

/// Inline "Generate Full Report" button with loading state
class _GenerateReportButton extends StatelessWidget {
  final Project project;
  final ReportProvider provider;

  const _GenerateReportButton({required this.project, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isGenerating = provider.isGenerating;

    return ElevatedButton.icon(
      onPressed: isGenerating ? null : () => _generate(context),
      icon: isGenerating
          ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white.withValues(alpha: 0.7)))
          : const Icon(Icons.picture_as_pdf_rounded, size: 16),
      label: Text(isGenerating ? '${(provider.progress * 100).toInt()}%' : 'Full Report'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.indigo600,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.indigo400,
        disabledForegroundColor: Colors.white70,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        padding: const EdgeInsets.symmetric(vertical: 10),
        elevation: 0,
      ),
    );
  }

  Future<void> _generate(BuildContext context) async {
    final projectProvider = context.read<ProjectProvider>();
    final proj = projectProvider.getProjectById(project.id);

    final result = await provider.generateReport(proj);

    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Expanded(child: Text('Reality Audit Report ready!')),
              TextButton(
                onPressed: () async {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  await Printing.sharePdf(bytes: result.pdfBytes, filename: result.fileName);
                },
                child: const Text('VIEW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          backgroundColor: AppColors.green600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 8),
        ),
      );
      provider.reset();
    } else if (provider.errorMessage != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${provider.errorMessage}'),
          backgroundColor: AppColors.red500,
          behavior: SnackBarBehavior.floating,
        ),
      );
      provider.reset();
    }
  }
}

/// News Coverage section showing location-aware Malaysian news
class _NewsCoverageSection extends StatelessWidget {
  final Project project;
  const _NewsCoverageSection({required this.project});

  @override
  Widget build(BuildContext context) {
    final newsService = NewsScraperService();
    final headlines = newsService.getNewsForProject(project);
    
    if (headlines.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding, vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.newspaper_rounded, size: 22, color: AppColors.textPrimary),
              const SizedBox(width: AppSpacing.sm),
              Text('News Coverage', style: AppTypography.headlineMedium),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 12, color: AppColors.green600),
                    const SizedBox(width: 4),
                    Text('Live', style: AppTypography.labelSmall.copyWith(color: AppColors.green600, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Recent coverage from Malaysian property news sources',
            style: AppTypography.subtitle.copyWith(color: AppColors.slate500),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...headlines.take(3).map((headline) => _NewsHeadlineCard(headline: headline)),
          if (headlines.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Center(
                child: TextButton(
                  onPressed: () => _showAllNews(context, headlines),
                  child: Text(
                    'View ${headlines.length - 3} more articles',
                    style: AppTypography.labelMedium.copyWith(color: AppColors.indigo600),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAllNews(BuildContext context, List<NewsHeadline> headlines) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.slate300, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: Row(
                children: [
                  const Icon(Icons.newspaper_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text('All News Coverage', style: AppTypography.headlineSmall),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                itemCount: headlines.length,
                itemBuilder: (context, index) => _NewsHeadlineCard(headline: headlines[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsHeadlineCard extends StatelessWidget {
  final NewsHeadline headline;
  const _NewsHeadlineCard({required this.headline});

  Color get _sentimentColor {
    switch (headline.sentiment) {
      case NewsSentiment.positive: return AppColors.green600;
      case NewsSentiment.negative: return AppColors.red600;
      case NewsSentiment.neutral: return AppColors.slate500;
    }
  }

  Color get _sentimentBgColor {
    switch (headline.sentiment) {
      case NewsSentiment.positive: return AppColors.green50;
      case NewsSentiment.negative: return AppColors.red50;
      case NewsSentiment.neutral: return AppColors.slate100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMM d, yyyy');
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final uri = Uri.parse(headline.url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source and date row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.language_rounded, size: 12, color: AppColors.slate600),
                          const SizedBox(width: 4),
                          Text(headline.source, style: AppTypography.labelSmall.copyWith(color: AppColors.slate600, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _sentimentBgColor,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(headline.sentimentIcon, style: const TextStyle(fontSize: 10)),
                          const SizedBox(width: 4),
                          Text(headline.sentimentLabel, style: AppTypography.labelSmall.copyWith(color: _sentimentColor, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(df.format(headline.publishedAt), style: AppTypography.captionMedium.copyWith(color: AppColors.slate400)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                // Title
                Text(
                  headline.title,
                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Snippet
                Text(
                  headline.snippet,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.slate500, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                // Read more link
                Row(
                  children: [
                    if (headline.isVerified) ...[
                      Icon(Icons.verified_rounded, size: 14, color: AppColors.blue500),
                      const SizedBox(width: 4),
                      Text('Verified Source', style: AppTypography.captionMedium.copyWith(color: AppColors.blue500)),
                      const SizedBox(width: 12),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Text('Read article', style: AppTypography.labelSmall.copyWith(color: AppColors.indigo600)),
                        const SizedBox(width: 4),
                        Icon(Icons.open_in_new_rounded, size: 12, color: AppColors.indigo600),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HighlightsSection extends StatelessWidget {
  final Project project;
  const _HighlightsSection({required this.project});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMM d, y');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding, vertical: AppSpacing.lg),
      child: Column(
        children: [
          _HighlightRow(icon: Icons.calendar_today_rounded, title: AppStrings.expectedCompletion, subtitle: project.expectedCompletion != null ? df.format(project.expectedCompletion!) : AppStrings.notSpecified),
          const SizedBox(height: AppSpacing.lg),
          _HighlightRow(icon: Icons.update_rounded, title: AppStrings.lastActivity, subtitle: df.format(project.lastActivity)),
          const SizedBox(height: AppSpacing.lg),
          _HighlightRow(icon: Icons.verified_user_outlined, title: AppStrings.lastVerified, subtitle: df.format(project.lastVerified)),
        ],
      ),
    );
  }
}

class _HighlightRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _HighlightRow({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
          child: Icon(icon, size: 22, color: AppColors.textPrimary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(title, style: AppTypography.titleSmall), const SizedBox(height: 2), Text(subtitle, style: AppTypography.subtitle)],
          ),
        ),
      ],
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  final Project project;
  const _DescriptionSection({required this.project});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding, vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(AppStrings.aboutThisProject, style: AppTypography.headlineMedium), const SizedBox(height: AppSpacing.sm), Text(project.description, style: AppTypography.bodyMedium.copyWith(height: 1.7))],
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  final Project project;
  const _DetailsSection({required this.project});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMM d, y');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding, vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.projectDetails, style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm, runSpacing: AppSpacing.sm,
            children: [
              _DetailChip(icon: Icons.category_rounded, label: project.category.label),
              _DetailChip(icon: Icons.public_rounded, label: project.isPublic ? AppStrings.publicLabel : AppStrings.privateLabel),
              _DetailChip(icon: Icons.business_rounded, label: project.agencyOrDeveloper),
              _DetailChip(icon: Icons.event_rounded, label: project.expectedCompletion != null ? 'Due ${df.format(project.expectedCompletion!)}' : AppStrings.noDeadline),
              _DetailChip(icon: Icons.people_rounded, label: AppStrings.checkInsCount(project.checkIns.length)),
              _DetailChip(icon: Icons.shield_outlined, label: '${project.confidence.label}${AppStrings.confidenceSuffix}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusMd), border: Border.all(color: AppColors.border)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 18, color: AppColors.textSecondary), const SizedBox(width: AppSpacing.xs), Flexible(child: Text(label, style: AppTypography.labelMedium))]),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  final Project project;
  const _TimelineSection({required this.project});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding, vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${AppStrings.timeline} (${project.checkIns.length})', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          if (project.checkIns.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
              child: Center(child: Column(children: [const Icon(Icons.history_rounded, size: 40, color: AppColors.textTertiary), const SizedBox(height: AppSpacing.sm), Text(AppStrings.noCheckIns, style: AppTypography.subtitle)])),
            )
          else
            VerticalTimeline(checkIns: project.checkIns, maxItems: 3),
        ],
      ),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  final Project project;
  const _ReviewsSection({required this.project});

  @override
  Widget build(BuildContext context) {
    final checkinsQuery = FirebaseFirestore.instance
        .collection('checkins')
        .where('projectId', isEqualTo: project.id)
        .orderBy('createdAt', descending: true);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: checkinsQuery.snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? const [];
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.rate_review_outlined,
                    size: 24,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${docs.length} ${AppStrings.communityReports}',
                    style: AppTypography.headlineMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (docs.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'No community reports yet.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else
                ...docs.map((doc) => _FirestoreCheckinCard(data: doc.data())),
            ],
          ),
        );
      },
    );
  }
}

class _FirestoreCheckinCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _FirestoreCheckinCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final userName = (data['userName'] as String?)?.trim().isNotEmpty == true
        ? (data['userName'] as String).trim()
        : 'Community User';
    final note = (data['note'] as String?)?.trim() ?? '';
    final statusLabel = (data['status'] as String?)?.trim() ?? 'Unverified';
    final createdAtTs = data['createdAt'];
    final createdAt = createdAtTs is Timestamp ? createdAtTs.toDate() : null;
    final dateText = createdAt != null
        ? DateFormat('MMM d, yyyy').format(createdAt)
        : 'Just now';

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
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.surfaceVariant,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: AppTypography.labelLarge,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: AppTypography.titleSmall),
                    Text(dateText, style: AppTypography.captionMedium),
                  ],
                ),
              ),
              _StatusPill(statusLabel: statusLabel),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            note,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String statusLabel;
  const _StatusPill({required this.statusLabel});

  @override
  Widget build(BuildContext context) {
    final normalized = statusLabel.toLowerCase();
    Color color;
    switch (normalized) {
      case 'active':
        color = AppColors.green600;
        break;
      case 'slowing':
        color = AppColors.amber600;
        break;
      case 'stalled':
        color = AppColors.red600;
        break;
      default:
        color = AppColors.gray600;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        statusLabel,
        style: AppTypography.badge.copyWith(color: color),
      ),
    );
  }
}

class _LocationSection extends StatelessWidget {
  final Project project;
  const _LocationSection({required this.project});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding, vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.whereYoullFindIt, style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.xxs),
          Text(project.location, style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.md),
          PropertyMap(
            latitude: project.latitude,
            longitude: project.longitude,
            projectName: project.name,
            height: 200,
            showFullScreenButton: true,
          ),
        ],
      ),
    );
  }
}

class _CompareSection extends StatelessWidget {
  final Project project;
  const _CompareSection({required this.project});

  @override
  Widget build(BuildContext context) {
    return Consumer<CompareProvider>(
      builder: (context, provider, _) {
        final isSelected = provider.isSelected(project);
        final otherSelected = provider.selectedProjects.where((p) => p.id != project.id).toList();
        
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Compare Projects', style: AppTypography.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'See how this project stacks up against others',
                style: AppTypography.subtitle,
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Compare button
              GestureDetector(
                onTap: () {
                  if (!isSelected) {
                    provider.addProject(project);
                  }
                  if (provider.canCompare) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ComparisonPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Select another project from the home page to compare'),
                        backgroundColor: AppColors.slate700,
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'GO',
                          textColor: Colors.white,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.slate100, AppColors.slate50],
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.slate900,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: const Icon(
                          Icons.compare_arrows_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.canCompare 
                                  ? 'Compare Now'
                                  : 'Compare with Similar Projects',
                              style: AppTypography.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              provider.canCompare
                                  ? '${provider.selectedCount} projects selected'
                                  : 'Select this and another project to compare',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: AppColors.slate400,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Show selected projects if any
              if (otherSelected.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Also selected:',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
                ),
                const SizedBox(height: AppSpacing.xs),
                ...otherSelected.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.green500,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          p.name,
                          style: AppTypography.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => provider.removeProject(p),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: AppColors.slate400,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DisclaimerSection extends StatelessWidget {
  const _DisclaimerSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.amber50, borderRadius: BorderRadius.circular(AppSpacing.radiusLg), border: Border.all(color: AppColors.amber100)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const Icon(Icons.warning_amber_rounded, color: AppColors.amber600, size: 20), const SizedBox(width: AppSpacing.sm), Expanded(child: Text(AppStrings.communityDataDisclaimer, style: AppTypography.bodySmall.copyWith(color: AppColors.amber700, height: 1.5)))],
      ),
    );
  }
}

/// Full-page Developer Background with all scraped sources
class _DeveloperBackgroundPage extends StatelessWidget {
  final Project project;
  const _DeveloperBackgroundPage({required this.project});

  @override
  Widget build(BuildContext context) {
    final profile = project.developerProfile;
    final sources = project.scrapedSources;
    final df = DateFormat('MMM d, yyyy – h:mm a');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Developer Background'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          // Developer card
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: AppColors.slate100, borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                      child: const Icon(Icons.business_rounded, size: 28, color: AppColors.slate600),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile?.name ?? project.agencyOrDeveloper, style: AppTypography.headlineMedium),
                          if (profile?.sources.isNotEmpty == true)
                            Text(profile!.sources.first.url, style: AppTypography.captionMedium.copyWith(color: AppColors.indigo500)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(AppSpacing.radiusFull)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 14, color: AppColors.green600),
                          const SizedBox(width: 4),
                          Text('Ready', style: AppTypography.labelSmall.copyWith(color: AppColors.green600, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text('Updated ${df.format(DateTime.now())}', style: AppTypography.captionMedium.copyWith(color: AppColors.slate400)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  profile?.litigationNote != null
                      ? '${profile!.name} — ${profile.litigationNote}'
                      : '${profile?.name ?? project.agencyOrDeveloper} — no significant risk flags detected from available data.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
                ),

                // Developer stats
                if (profile != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      _buildStat('Years Active', '${profile.yearsActive}'),
                      _buildStat('Projects', '${profile.totalProjects}'),
                      _buildStat('Completed', '${profile.completedProjects}'),
                      _buildStat('Delayed', '${profile.delayedProjects}'),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Official Sources
          _buildSourceSection(context, 'Official Sources', Icons.language_rounded, sources.where((s) => s.type == SourceType.developer || s.type == SourceType.government).toList()),

          const SizedBox(height: AppSpacing.lg),

          // Filings & Reports
          _buildSourceSection(context, 'Filings & Reports', Icons.description_rounded, sources.where((s) => s.type == SourceType.government).toList()),

          const SizedBox(height: AppSpacing.lg),

          // News Coverage
          _buildSourceSection(context, 'News Coverage', Icons.newspaper_rounded, sources.where((s) => s.type == SourceType.news).toList()),

          const SizedBox(height: AppSpacing.lg),

          // Public Reviews
          _buildSourceSection(context, 'Public Reviews', Icons.trending_up_rounded, sources.where((s) => s.type == SourceType.forum || s.type == SourceType.community).toList()),

          const SizedBox(height: AppSpacing.lg),

          // Compliance notice
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.amber50,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.amber200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18, color: AppColors.amber700),
                    const SizedBox(width: 8),
                    Text('Compliance Notice', style: AppTypography.labelMedium.copyWith(color: AppColors.amber700, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This information is generated from public sources only. No login scraping, CAPTCHA bypass, or paywall bypass is used. Data may be incomplete — always verify via official channels.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.amber700, height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.captionMedium.copyWith(color: AppColors.slate400)),
        ],
      ),
    );
  }

  Widget _buildSourceSection(BuildContext context, String title, IconData icon, List<ScrapedSource> sectionSources) {
    if (sectionSources.isEmpty) {
      // Show placeholder for empty sections with a relevant search link
      sectionSources = _getPlaceholderSources(title);
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Text(title, style: AppTypography.headlineSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...sectionSources.map((source) => _buildFullSourceItem(context, source)),
        ],
      ),
    );
  }

  List<ScrapedSource> _getPlaceholderSources(String sectionTitle) {
    final devName = project.agencyOrDeveloper;
    switch (sectionTitle) {
      case 'Official Sources':
        return [
          ScrapedSource(id: 'gen_official', title: '$devName — Official Website', url: 'https://www.google.com/search?q=$devName+official', type: SourceType.developer, scrapedAt: DateTime.now(), snippet: 'Developer-provided URL.', domain: devName.toLowerCase().replaceAll(' ', '') + '.com'),
          ScrapedSource(id: 'gen_search', title: 'Google Search: $devName', url: 'https://www.google.com/search?q=$devName', type: SourceType.developer, scrapedAt: DateTime.now(), snippet: 'Generated search link — manual review recommended.', domain: 'google.com'),
        ];
      case 'Filings & Reports':
        return [
          ScrapedSource(id: 'gen_ssm', title: 'SSM Company Search: $devName', url: 'https://www.ssm.com.my', type: SourceType.government, scrapedAt: DateTime.now(), snippet: 'Search SSM portal for company filings. Manual review required.', domain: 'ssm.com.my'),
          ScrapedSource(id: 'gen_public', title: 'Public Reports: $devName', url: 'https://www.google.com/search?q=$devName+annual+report+PDF', type: SourceType.government, scrapedAt: DateTime.now(), snippet: 'Search for publicly available PDF reports.', domain: 'google.com'),
        ];
      case 'News Coverage':
        return [
          ScrapedSource(id: 'gen_news', title: 'Recent News: $devName', url: 'https://news.google.com/search?q=$devName', type: SourceType.news, scrapedAt: DateTime.now(), snippet: 'Google News results — review for positive/negative sentiment.', domain: 'news.google.com'),
        ];
      default:
        return [
          ScrapedSource(id: 'gen_reviews', title: 'Google Reviews: $devName', url: 'https://www.google.com/search?q=$devName+reviews', type: SourceType.forum, scrapedAt: DateTime.now(), snippet: 'Public search link — no ToS-restricted scraping.', domain: 'google.com'),
        ];
    }
  }

  Widget _buildFullSourceItem(BuildContext context, ScrapedSource source) {
    final pct = _getConfidencePercent(source);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final uri = Uri.parse(source.url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(source.title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                    ),
                    Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.indigo500),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: pct >= 70 ? AppColors.green50 : (pct >= 50 ? AppColors.amber50 : AppColors.red50),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        'Confidence: $pct%',
                        style: AppTypography.captionMedium.copyWith(
                          color: pct >= 70 ? AppColors.green600 : (pct >= 50 ? AppColors.amber600 : AppColors.red600),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (source.type == SourceType.news)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.slate100, borderRadius: BorderRadius.circular(AppSpacing.radiusFull)),
                        child: Text('Neutral', style: AppTypography.captionMedium.copyWith(color: AppColors.slate500)),
                      ),
                    if (source.type != SourceType.news)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.slate100, borderRadius: BorderRadius.circular(AppSpacing.radiusFull)),
                        child: Text(source.typeLabel, style: AppTypography.captionMedium.copyWith(color: AppColors.slate500)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  source.snippet ?? source.domain,
                  style: AppTypography.captionMedium.copyWith(color: AppColors.slate400, fontStyle: FontStyle.italic),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getConfidencePercent(ScrapedSource source) {
    switch (source.type) {
      case SourceType.government: return 60;
      case SourceType.news: return 50;
      case SourceType.developer: return 90;
      case SourceType.forum: return 40;
      case SourceType.community: return 60;
    }
  }
}

class _StickyBottomBar extends StatelessWidget {
  final Project project;
  const _StickyBottomBar({required this.project});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMM d, y');
    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.pagePadding, AppSpacing.md, AppSpacing.pagePadding, AppSpacing.lg + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border, width: 1))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [StatusBadge(status: project.status, compact: true), const SizedBox(width: AppSpacing.xs), ConfidenceBadge(confidence: project.confidence, compact: true)]),
                const SizedBox(height: 4),
                Text('${AppStrings.verified} ${df.format(project.lastVerified)}', style: AppTypography.captionMedium),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: () async {
              if (!await requireLogin(context)) return;
              if (!context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddCheckinPage(projectId: project.id),
                ),
              );
            },
            icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
            label: Text(AppStrings.addCheckin, style: AppTypography.button.copyWith(color: AppColors.textInverse)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.slate900,
              foregroundColor: AppColors.textInverse,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
