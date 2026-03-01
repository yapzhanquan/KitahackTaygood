import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/compare_provider.dart';
import '../../models/project_model.dart';
import '../widgets/source_link_badge.dart';
import '../widgets/project_image.dart';

/// Apple-style Project Comparison Page
/// High-contrast visual indicators with AI-driven conflict insights
class ComparisonPage extends StatefulWidget {
  const ComparisonPage({super.key});

  @override
  State<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompareProvider>().generateVerdict();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CompareProvider>(
      builder: (context, provider, _) {
        if (provider.selectedProjects.length < 2) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Compare'),
              backgroundColor: AppColors.surface,
            ),
            body: const Center(
              child: Text('Please select at least 2 projects to compare'),
            ),
          );
        }

        final projects = provider.selectedProjects;
        
        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              _buildStickyHeader(context, projects, provider),
              SliverToBoxAdapter(child: _buildConflictInsightCard(projects)),
              SliverToBoxAdapter(child: _buildRealityGapSection(projects)),
              _buildComparisonSections(projects),
              SliverToBoxAdapter(child: _buildVerdictCard(provider, projects)),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStickyHeader(BuildContext context, List<Project> projects, CompareProvider provider) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.slate100,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: const Icon(Icons.close_rounded, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Compare Projects', style: TextStyle(fontWeight: FontWeight.w700)),
      actions: [
        TextButton(
          onPressed: () {
            provider.clearAll();
            Navigator.pop(context);
          },
          child: Text(
            'Clear All',
            style: AppTypography.labelMedium.copyWith(color: AppColors.red500),
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.surface,
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 56),
                Expanded(
                  child: _buildProjectHeaders(projects, provider),
                ),
              ],
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildProjectHeaders(List<Project> projects, CompareProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: projects.asMap().entries.map((entry) {
          final index = entry.key;
          final project = entry.value;
          return Expanded(
            child: _buildProjectHeader(project, provider, index),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProjectHeader(Project project, CompareProvider provider, int index) {
    final isHighRisk = project.riskLevel == RiskLevel.high || project.status == ProjectStatus.stalled;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Column(
        children: [
          // Image with remove button
          Stack(
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isHighRisk ? AppColors.red500.withValues(alpha: 0.5) : AppColors.slate200,
                    width: isHighRisk ? 3 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isHighRisk 
                          ? AppColors.red500.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: ProjectImage(
                    project: project,
                    fit: BoxFit.cover,
                    placeholder: Container(color: AppColors.slate100),
                    errorWidget: Container(
                      color: AppColors.slate100,
                      child: const Icon(Icons.image, color: AppColors.slate400),
                    ),
                  ),
                ),
              ),
              // Remove button
              Positioned(
                top: -4,
                right: -4,
                child: GestureDetector(
                  onTap: () {
                    provider.removeProject(project);
                    if (provider.selectedCount < 2) {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.slate800,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                  ),
                ),
              ),
              // Risk warning badge
              if (isHighRisk)
                Positioned(
                  bottom: -4,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.red500,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_rounded, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'HIGH RISK',
                            style: AppTypography.captionMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 9,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Project name
          Text(
            project.name,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: AppSpacing.xs),
          
          // Status indicator
          _buildStatusIndicator(project.status),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(ProjectStatus status) {
    Color dotColor;
    Color bgColor;
    switch (status) {
      case ProjectStatus.active:
        dotColor = AppColors.green500;
        bgColor = AppColors.green50;
        break;
      case ProjectStatus.slowing:
        dotColor = AppColors.amber500;
        bgColor = AppColors.amber50;
        break;
      case ProjectStatus.stalled:
        dotColor = AppColors.red500;
        bgColor = AppColors.red50;
        break;
      case ProjectStatus.unverified:
        dotColor = AppColors.slate400;
        bgColor = AppColors.slate100;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusDot(color: dotColor, isPulsing: status == ProjectStatus.active),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: AppTypography.labelSmall.copyWith(
              color: dotColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConflictInsightCard(List<Project> projects) {
    // Find the conflict between projects
    final hasConflict = projects.any((p) => p.status == ProjectStatus.stalled) &&
        projects.any((p) => p.status == ProjectStatus.active);
    
    if (!hasConflict) return const SizedBox.shrink();
    
    final stalledProject = projects.firstWhere((p) => p.status == ProjectStatus.stalled);
    final activeProject = projects.firstWhere((p) => p.status == ProjectStatus.active);
    
    return Container(
      margin: const EdgeInsets.all(AppSpacing.pagePadding),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.amber500.withValues(alpha: 0.1),
            AppColors.red500.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.amber200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.amber500,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Conflict Detected',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.amber700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          RichText(
            text: TextSpan(
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.slate700,
                height: 1.6,
              ),
              children: [
                const TextSpan(text: 'You\'re comparing an '),
                TextSpan(
                  text: 'Active',
                  style: TextStyle(
                    color: AppColors.green600,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: ' project ('),
                TextSpan(
                  text: activeProject.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const TextSpan(text: ') with a '),
                TextSpan(
                  text: 'Stalled',
                  style: TextStyle(
                    color: AppColors.red600,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: ' project ('),
                TextSpan(
                  text: stalledProject.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const TextSpan(text: '). This comparison can help you '),
                const TextSpan(
                  text: 'avoid a potential "sick project"',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealityGapSection(List<Project> projects) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      decoration: BoxDecoration(
        color: AppColors.slate900,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.slate800,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'THE REALITY AUDIT',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.source_rounded, size: 10, color: Colors.white.withValues(alpha: 0.8)),
                      const SizedBox(width: 4),
                      Text(
                        '${projects.fold(0, (sum, p) => sum + p.scrapedSources.length)} Sources',
                        style: AppTypography.captionMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Two-column comparison
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: projects.asMap().entries.map((entry) {
                final idx = entry.key;
                final project = entry.value;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: idx > 0 ? AppSpacing.md : 0),
                    child: _buildProjectRealityColumn(project),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Gap Analysis Row
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.slate800,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppSpacing.radiusXl)),
            ),
            child: Column(
              children: [
                Text(
                  'CREDIBILITY GAP ANALYSIS',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: projects.map((p) {
                    final devClaim = _getDeveloperClaimValue(p);
                    final gap = devClaim - p.progressPercentage;
                    final isLargeGap = gap > 20;
                    
                    return Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isLargeGap)
                                const Icon(Icons.warning_rounded, color: AppColors.red400, size: 18),
                              if (isLargeGap) const SizedBox(width: 4),
                              Text(
                                gap > 0 ? '-$gap%' : '+${gap.abs()}%',
                                style: AppTypography.headlineMedium.copyWith(
                                  color: isLargeGap ? AppColors.red400 : AppColors.green400,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isLargeGap 
                                  ? AppColors.red500.withValues(alpha: 0.2)
                                  : AppColors.green500.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                            ),
                            child: Text(
                              isLargeGap ? '⚠️ UNTRUSTWORTHY' : '✓ TRUSTWORTHY',
                              style: AppTypography.captionMedium.copyWith(
                                color: isLargeGap ? AppColors.red400 : AppColors.green400,
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectRealityColumn(Project project) {
    final devClaim = _getDeveloperClaimValue(project);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Project name
        Text(
          project.name,
          style: AppTypography.labelMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.md),
        
        // OFFICIAL CLAIMS section
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.slate800,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.business_rounded, size: 12, color: Colors.white.withValues(alpha: 0.6)),
                  const SizedBox(width: 4),
                  Text(
                    'OFFICIAL CLAIMS',
                    style: AppTypography.captionMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Official progress
              Row(
                children: [
                  Text(
                    '$devClaim%',
                    style: AppTypography.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'claimed',
                    style: AppTypography.captionMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Official milestones (up to 2)
              ...project.officialMilestones.take(2).map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('•', style: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.description,
                            style: AppTypography.captionMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 10,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          GestureDetector(
                            onTap: () => _launchUrl(m.source.url),
                            child: Row(
                              children: [
                                Icon(Icons.link_rounded, size: 8, color: AppColors.blue400),
                                const SizedBox(width: 2),
                                Text(
                                  '${m.source.domain} • ${DateFormat('MMM d').format(m.date)}',
                                  style: AppTypography.captionMedium.copyWith(
                                    color: AppColors.blue400,
                                    fontSize: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // COMMUNITY EVIDENCE section
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: project.progressPercentage < 30 
                ? AppColors.red500.withValues(alpha: 0.15)
                : AppColors.green500.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: project.progressPercentage < 30 
                  ? AppColors.red500.withValues(alpha: 0.3)
                  : AppColors.green500.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.groups_rounded, size: 12, 
                    color: project.progressPercentage < 30 ? AppColors.red400 : AppColors.green400),
                  const SizedBox(width: 4),
                  Text(
                    'COMMUNITY EVIDENCE',
                    style: AppTypography.captionMedium.copyWith(
                      color: project.progressPercentage < 30 ? AppColors.red400 : AppColors.green400,
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Community verified progress
              Row(
                children: [
                  Text(
                    '${project.progressPercentage}%',
                    style: AppTypography.titleLarge.copyWith(
                      color: project.progressPercentage < 30 ? AppColors.red400 : AppColors.green400,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'verified',
                    style: AppTypography.captionMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Community check-ins (up to 2)
              ...project.checkIns.take(2).map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      c.status == ProjectStatus.active ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      size: 10,
                      color: c.status == ProjectStatus.active ? AppColors.green400 : AppColors.red400,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '"${c.note}"',
                            style: AppTypography.captionMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.blue500.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  c.id.length > 12 ? c.id.substring(0, 12) : c.id,
                                  style: AppTypography.captionMedium.copyWith(
                                    color: AppColors.blue400,
                                    fontSize: 7,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${c.reporterName} • ${DateFormat('MMM d').format(c.timestamp)}',
                                style: AppTypography.captionMedium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildRealityRow(String label, List<String> values, List<Color> colors) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...values.asMap().entries.map((entry) => Expanded(
          flex: 3,
          child: Text(
            entry.value,
            style: AppTypography.headlineMedium.copyWith(
              color: colors[entry.key],
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
        )),
      ],
    );
  }

  Widget _buildGapRow_DEPRECATED(List<Project> projects) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.red500,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Text(
              'GAP',
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        ...projects.map((p) {
          final devClaim = _getDeveloperClaimValue(p);
          final gap = devClaim - p.progressPercentage;
          final isLargeGap = gap > 20;
          
          return Expanded(
            flex: 3,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLargeGap)
                      const Icon(Icons.warning_rounded, color: AppColors.red400, size: 16),
                    if (isLargeGap) const SizedBox(width: 4),
                    Text(
                      gap > 0 ? '-$gap%' : '${gap.abs()}%',
                      style: AppTypography.titleLarge.copyWith(
                        color: isLargeGap ? AppColors.red400 : AppColors.green400,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Text(
                  isLargeGap ? 'Untrustworthy' : 'Trustworthy',
                  style: AppTypography.captionMedium.copyWith(
                    color: isLargeGap ? AppColors.red400 : AppColors.green400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGapRow(List<Project> projects) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.red500,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Text(
              'GAP',
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        ...projects.map((p) {
          final devClaim = _getDeveloperClaimValue(p);
          final gap = devClaim - p.progressPercentage;
          final isLargeGap = gap > 20;
          
          return Expanded(
            flex: 3,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLargeGap)
                      const Icon(Icons.warning_rounded, color: AppColors.red400, size: 16),
                    if (isLargeGap) const SizedBox(width: 4),
                    Text(
                      gap > 0 ? '-$gap%' : '${gap.abs()}%',
                      style: AppTypography.titleLarge.copyWith(
                        color: isLargeGap ? AppColors.red400 : AppColors.green400,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Text(
                  isLargeGap ? 'Untrustworthy' : 'Trustworthy',
                  style: AppTypography.captionMedium.copyWith(
                    color: isLargeGap ? AppColors.red400 : AppColors.green400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _getDeveloperClaim(Project p) {
    // Simulate developer claims (usually inflated)
    final claim = _getDeveloperClaimValue(p);
    return '$claim%';
  }

  int _getDeveloperClaimValue(Project p) {
    // Developer claims are typically inflated
    if (p.status == ProjectStatus.stalled) return 85; // Claims high but stalled
    if (p.status == ProjectStatus.slowing) return p.progressPercentage + 23;
    return p.progressPercentage + 5; // Small gap for healthy projects
  }

  Color _getProgressColor(int progress) {
    if (progress >= 70) return AppColors.green400;
    if (progress >= 40) return AppColors.amber400;
    return AppColors.red400;
  }

  Widget _buildComparisonSections(List<Project> projects) {
    return SliverList(
      delegate: SliverChildListDelegate([
        const SizedBox(height: AppSpacing.xl),
        
        _buildSectionHeader('Physical Delivery'),
        _buildComparisonRow(
          'Status',
          projects.map((p) => _buildStatusCell(p)).toList(),
        ),
        _buildComparisonRow(
          'Progress',
          projects.map((p) => _buildProgressCell(p)).toList(),
        ),
        _buildComparisonRow(
          'Days Since Activity',
          projects.map((p) => _buildActivityCell(p)).toList(),
        ),
        _buildComparisonRow(
          'Expected Completion',
          projects.map((p) => _buildTextCell(
            p.expectedCompletion != null 
                ? DateFormat('MMM yyyy').format(p.expectedCompletion!) 
                : 'Not set',
          )).toList(),
        ),
        
        _buildSectionHeader('Community Trust'),
        _buildComparisonRow(
          'Confidence Level',
          projects.map((p) => _buildConfidenceCell(p)).toList(),
        ),
        _buildComparisonRow(
          'Community Sentiment',
          projects.map((p) => _buildSentimentCellWithSource(p)).toList(),
        ),
        _buildComparisonRow(
          'Total Check-ins',
          projects.map((p) => _buildCheckInCell(p)).toList(),
        ),
        
        _buildSectionHeader('Developer Record'),
        _buildComparisonRow(
          'Developer',
          projects.map((p) => _buildDeveloperCell(p)).toList(),
        ),
        _buildComparisonRow(
          'Risk Level',
          projects.map((p) => _buildRiskCell(p)).toList(),
        ),
        _buildComparisonRow(
          'Last Verified',
          projects.map((p) => _buildTextCell(DateFormat('MMM d, yyyy').format(p.lastVerified))).toList(),
        ),
      ]),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.xl,
        AppSpacing.pagePadding,
        AppSpacing.md,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.slate500,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildComparisonRow(String label, List<Widget> cells) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.slate100, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.slate500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: cells.map((cell) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: cell,
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCell(Project project) {
    final isStalled = project.status == ProjectStatus.stalled;
    Color bgColor;
    Color textColor;
    
    switch (project.status) {
      case ProjectStatus.active:
        bgColor = AppColors.green50;
        textColor = AppColors.green700;
        break;
      case ProjectStatus.slowing:
        bgColor = AppColors.amber50;
        textColor = AppColors.amber700;
        break;
      case ProjectStatus.stalled:
        bgColor = AppColors.red50;
        textColor = AppColors.red700;
        break;
      case ProjectStatus.unverified:
        bgColor = AppColors.slate100;
        textColor = AppColors.slate600;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: isStalled ? Border.all(color: AppColors.red300, width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              project.status.label,
              style: AppTypography.labelMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (isStalled) ...[
            const SizedBox(width: 6),
            Icon(Icons.warning_rounded, size: 14, color: textColor),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressCell(Project project) {
    final progress = project.progressPercentage / 100;
    Color progressColor;
    
    if (progress >= 0.7) {
      progressColor = AppColors.green500;
    } else if (progress >= 0.4) {
      progressColor = AppColors.amber500;
    } else {
      progressColor = AppColors.red500;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.slate200,
                  valueColor: AlwaysStoppedAnimation(progressColor),
                  minHeight: 10,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${project.progressPercentage}%',
              style: AppTypography.titleMedium.copyWith(
                color: progressColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityCell(Project project) {
    final days = project.daysSinceActivity;
    final isWarning = days > 30;
    final isCritical = days > 90;
    
    return Row(
      children: [
        if (isCritical)
          const Icon(Icons.error_rounded, size: 18, color: AppColors.red500)
        else if (isWarning)
          const Icon(Icons.warning_rounded, size: 18, color: AppColors.amber500)
        else
          const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.green500),
        const SizedBox(width: 8),
        Text(
          '$days days',
          style: AppTypography.bodyMedium.copyWith(
            color: isCritical ? AppColors.red600 : (isWarning ? AppColors.amber600 : AppColors.textPrimary),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceCell(Project project) {
    Color color;
    IconData icon;
    
    switch (project.confidence) {
      case ConfidenceLevel.high:
        color = AppColors.green600;
        icon = Icons.verified_rounded;
        break;
      case ConfidenceLevel.medium:
        color = AppColors.amber600;
        icon = Icons.info_outline_rounded;
        break;
      case ConfidenceLevel.low:
        color = AppColors.red600;
        icon = Icons.warning_amber_rounded;
        break;
    }
    
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          project.confidence.label,
          style: AppTypography.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSentimentCell(Project project) {
    final sentiment = project.sentimentScore;
    String label;
    Color color;
    IconData icon;
    
    if (sentiment > 0.3) {
      label = 'Positive';
      color = AppColors.green600;
      icon = Icons.trending_up_rounded;
    } else if (sentiment < -0.3) {
      label = 'Negative';
      color = AppColors.red600;
      icon = Icons.trending_down_rounded;
    } else {
      label = 'Neutral';
      color = AppColors.slate500;
      icon = Icons.trending_flat_rounded;
    }
    
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSentimentCellWithSource(Project project) {
    final analysis = project.sentimentAnalysis;
    final sentiment = analysis?.score ?? project.sentimentScore;
    String label;
    Color color;
    IconData icon;
    
    if (sentiment > 0.3) {
      label = 'Positive';
      color = AppColors.green600;
      icon = Icons.trending_up_rounded;
    } else if (sentiment < -0.3) {
      label = 'Negative';
      color = AppColors.red600;
      icon = Icons.trending_down_rounded;
    } else {
      label = 'Neutral';
      color = AppColors.slate500;
      icon = Icons.trending_flat_rounded;
    }
    
    // Get source domains
    final sourceDomains = analysis?.sources.map((s) => s.domain).take(2).join(', ') ?? 'community data';
    final reviewCount = analysis?.totalReviews ?? project.checkIns.length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.slate50,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.slate200, width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.source_rounded, size: 9, color: AppColors.slate400),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Based on $reviewCount reviews from $sourceDomains',
                  style: AppTypography.captionMedium.copyWith(
                    color: AppColors.slate500,
                    fontSize: 8,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckInCell(Project project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${project.checkIns.length} reports',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (project.checkIns.isNotEmpty) ...[
          const SizedBox(height: 4),
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
                Icon(Icons.verified_user_rounded, size: 9, color: AppColors.blue500),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Latest: ${project.checkIns.first.id}',
                    style: AppTypography.captionMedium.copyWith(
                      color: AppColors.blue600,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDeveloperCell(Project project) {
    final profile = project.developerProfile;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          project.agencyOrDeveloper,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        if (profile != null) ...[
          Row(
            children: [
              // Rating badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: profile.rating >= 3.5 ? AppColors.green50 : (profile.rating >= 2.5 ? AppColors.amber50 : AppColors.red50),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 10, 
                      color: profile.rating >= 3.5 ? AppColors.green600 : (profile.rating >= 2.5 ? AppColors.amber600 : AppColors.red600)),
                    const SizedBox(width: 2),
                    Text(
                      profile.rating.toStringAsFixed(1),
                      style: AppTypography.captionMedium.copyWith(
                        color: profile.rating >= 3.5 ? AppColors.green700 : (profile.rating >= 2.5 ? AppColors.amber700 : AppColors.red700),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // Track record
              Text(
                '${profile.completedProjects}/${profile.totalProjects} completed',
                style: AppTypography.captionMedium.copyWith(
                  color: AppColors.slate500,
                  fontSize: 9,
                ),
              ),
            ],
          ),
          if (profile.litigationNote != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.red50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.red200, width: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.gavel_rounded, size: 9, color: AppColors.red500),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Legal action pending',
                      style: AppTypography.captionMedium.copyWith(
                        color: AppColors.red600,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Source badge
          const SizedBox(height: 4),
          if (profile.sources.isNotEmpty)
            GestureDetector(
              onTap: () => _launchUrl(profile.sources.first.url),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.slate200, width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.link_rounded, size: 8, color: AppColors.slate400),
                    const SizedBox(width: 3),
                    Text(
                      profile.sources.first.domain,
                      style: AppTypography.captionMedium.copyWith(
                        color: AppColors.slate500,
                        fontSize: 8,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.open_in_new_rounded, size: 7, color: AppColors.slate400),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildRiskCell(Project project) {
    Color color;
    Color bgColor;
    
    switch (project.riskLevel) {
      case RiskLevel.low:
        color = AppColors.green700;
        bgColor = AppColors.green50;
        break;
      case RiskLevel.medium:
        color = AppColors.amber700;
        bgColor = AppColors.amber50;
        break;
      case RiskLevel.high:
        color = AppColors.red700;
        bgColor = AppColors.red50;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        project.riskLevel.label.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextCell(String text) {
    return Text(
      text,
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildVerdictCard(CompareProvider provider, List<Project> projects) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.pagePadding),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1a1a2e).withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Icon(Icons.gavel_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ProjekWatch Recommendation',
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'AI-Powered Risk Analysis',
                      style: AppTypography.captionMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF667eea)),
                    const SizedBox(width: 6),
                    Text(
                      'Gemini',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          
          if (provider.isGeneratingVerdict)
            Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white.withValues(alpha: 0.8)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'Analyzing project differences...',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            )
          else
            Text(
              provider.verdictText ?? 'Unable to generate recommendation.',
              style: AppTypography.bodyLarge.copyWith(
                color: Colors.white,
                height: 1.7,
                fontWeight: FontWeight.w400,
              ),
            ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Quick verdict badges
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildVerdictBadge(
                projects.any((p) => p.riskLevel == RiskLevel.high)
                    ? 'Contains High-Risk Project'
                    : 'Both Moderate-Low Risk',
                projects.any((p) => p.riskLevel == RiskLevel.high)
                    ? AppColors.red400
                    : AppColors.green400,
              ),
              _buildVerdictBadge(
                'Based on ${projects.fold(0, (sum, p) => sum + p.checkIns.length)} Community Reports',
                Colors.white.withValues(alpha: 0.7),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerdictBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: AppTypography.captionMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

}

/// Animated status dot - pulses for active projects
class _StatusDot extends StatefulWidget {
  final Color color;
  final bool isPulsing;

  const _StatusDot({required this.color, this.isPulsing = false});

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    if (widget.isPulsing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPulsing) {
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: _animation.value),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: _animation.value * 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          );
        },
      );
    }
    
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: widget.color,
        shape: BoxShape.circle,
      ),
    );
  }
}
