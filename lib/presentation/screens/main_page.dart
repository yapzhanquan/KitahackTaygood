import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/project_provider.dart';
import '../../providers/compare_provider.dart';
import '../../models/project_model.dart';
import '../widgets/segmented_search_bar.dart';
import '../widgets/section_header.dart';
import '../widgets/project_card.dart';
import '../widgets/compare_bar.dart';
import 'project_detail_page.dart';
import 'add_checkin_page.dart';
import '../../auth/login_guard.dart';
import '../../auth/auth_service.dart';
import '../../screens/login_screen.dart';
import '../../screens/register_screen.dart';

/// Premium Airbnb-style Main Page
/// Features:
/// - Segmented search bar (Location | Category | Status)
/// - Tabs with icons and sliding indicator
/// - Responsive layout with smooth interactions
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  bool? _lastIsTablet;

  static const _tabs = [
    _TabInfo(icon: Icons.grid_view_rounded, label: 'Projects'),
    _TabInfo(icon: Icons.category_outlined, label: 'Categories'),
    _TabInfo(icon: Icons.insights_rounded, label: 'Insights'),
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isTablet = MediaQuery.sizeOf(context).width > 600;
    if (_lastIsTablet != isTablet) {
      _lastIsTablet = isTablet;
      context.read<CompareProvider>().setMaxSelection(isTablet);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    if (index == _selectedTab) return;
    
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildAppBar(),
                _buildTabBar(),
                Expanded(
                  child: IndexedStack(
                    index: _selectedTab,
                    children: [
                      _ProjectsView(),
                      _CategoriesView(),
                      _InsightsView(),
                    ],
                  ),
                ),
              ],
            ),
            // Floating Compare Bar at bottom
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CompareBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
      ),
      child: Row(
        children: [
          // Logo
          Text(
            AppStrings.appName,
            style: AppTypography.logo,
          ),
          const Spacer(),
          
          // Contribute button
          _buildContributeButton(),
          
          const SizedBox(width: AppSpacing.sm),
          
          // Profile avatar
          _buildProfileAvatar(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / _tabs.length;
          
          return Stack(
            children: [
              // Sliding indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                left: _selectedTab * tabWidth + (tabWidth - 60) / 2,
                bottom: 0,
                child: Container(
                  width: 60,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.slate900,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              
              // Tab buttons
              Row(
                children: List.generate(_tabs.length, (index) {
                  final tab = _tabs[index];
                  final isSelected = _selectedTab == index;
                  
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTab(index),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              tab.icon,
                              size: 20,
                              color: isSelected 
                                  ? AppColors.slate900 
                                  : AppColors.textTertiary,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tab.label,
                              style: AppTypography.labelMedium.copyWith(
                                color: isSelected 
                                    ? AppColors.textPrimary 
                                    : AppColors.textTertiary,
                                fontWeight: isSelected 
                                    ? FontWeight.w700 
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContributeButton() {
    return GestureDetector(
      onTap: () async {
        if (!await requireLogin(context)) return;
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddCheckinPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.slate900,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Text(
          AppStrings.contribute,
          style: AppTypography.buttonSmall.copyWith(
            color: AppColors.textInverse,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (user == null) {
          return PopupMenuButton<String>(
            tooltip: 'Account',
            onSelected: (value) {
              if (value == 'login') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
              if (value == 'register') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: SizedBox(
                  width: 220,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Guest mode',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Login to contribute and submit check-ins.',
                        style: AppTypography.captionMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'login',
                child: Text(
                  'Login',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: 'register',
                child: Text(
                  'Create account',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        final userName = (user.displayName?.trim().isNotEmpty ?? false)
            ? user.displayName!.trim()
            : 'User';
        final userEmail = user.email?.trim().isNotEmpty == true
            ? user.email!.trim()
            : 'No email';
        final avatarLetter =
            userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

        return PopupMenuButton<String>(
          tooltip: 'Profile',
          onSelected: (value) async {
            if (value == 'logout') {
              await AuthService.logout();
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              enabled: false,
              child: SizedBox(
                width: 220,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.captionMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Logout',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: Text(
              avatarLetter,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TabInfo {
  final IconData icon;
  final String label;
  
  const _TabInfo({required this.icon, required this.label});
}

// ─────────────────────────────────────────────────────────────────────────────
// PROJECTS VIEW
// ─────────────────────────────────────────────────────────────────────────────

class _ProjectsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, provider, _) {
        final active = provider.activeProjects;
        final stalled = provider.stalledProjects;
        final publicP = provider.publicProjects;
        final privateP = provider.privateProjects;
        final hasFilters = provider.searchQuery.isNotEmpty ||
            provider.categoryFilter != null ||
            provider.statusFilter != null;

        return ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          children: [
            // Premium segmented search bar
            SegmentedSearchBar(
              onLocationChanged: (q) => provider.setSearchQuery(q),
              onCategoryChanged: (c) => provider.setCategoryFilter(c),
              onStatusChanged: (s) => provider.setStatusFilter(s),
              onSearchTap: () {},
            ),

            if (hasFilters) ...[
              SectionHeader(
                title: AppStrings.searchResults,
                count: provider.filteredProjects.length,
              ),
              _HorizontalProjectList(projects: provider.filteredProjects),
              const SizedBox(height: AppSpacing.sectionMargin),
            ] else ...[
              SectionHeader(title: AppStrings.activeProjectsNearYou),
              _HorizontalProjectList(projects: active),
              const SizedBox(height: AppSpacing.sectionMargin),
              
              SectionHeader(title: AppStrings.recentlyFlaggedAsStalled),
              _HorizontalProjectList(projects: stalled),
              const SizedBox(height: AppSpacing.sectionMargin),
              
              SectionHeader(title: AppStrings.publicInfrastructure),
              _HorizontalProjectList(projects: publicP),
              const SizedBox(height: AppSpacing.sectionMargin),
              
              SectionHeader(title: AppStrings.privateDevelopments),
              _HorizontalProjectList(projects: privateP),
            ],
          ],
        );
      },
    );
  }
}

class _HorizontalProjectList extends StatelessWidget {
  final List<Project> projects;

  const _HorizontalProjectList({required this.projects});

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();

    if (projects.isEmpty) {
      return _buildEmptyState();
    }

    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: AppSpacing.pagePadding),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return ProjectCard(
            project: project,
            isBookmarked: projectProvider.isProjectSaved(project.id),
            onBookmarkTap: () => projectProvider.toggleSavedProject(project.id),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectDetailPage(
                    projectId: project.id,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 160,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 40,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.noProjectsFound,
              style: AppTypography.subtitle,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORIES VIEW
// ─────────────────────────────────────────────────────────────────────────────

class _CategoriesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, provider, _) {
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            _buildCategorySection(
              context,
              AppStrings.housing,
              Icons.apartment_rounded,
              AppColors.indigo500,
              provider.filteredProjects
                  .where((p) => p.category == ProjectCategory.housing)
                  .toList(),
            ),
            _buildCategorySection(
              context,
              AppStrings.road,
              Icons.route_rounded,
              AppColors.amber500,
              provider.filteredProjects
                  .where((p) => p.category == ProjectCategory.road)
                  .toList(),
            ),
            _buildCategorySection(
              context,
              AppStrings.drainage,
              Icons.water_rounded,
              AppColors.cyan500,
              provider.filteredProjects
                  .where((p) => p.category == ProjectCategory.drainage)
                  .toList(),
            ),
            _buildCategorySection(
              context,
              AppStrings.school,
              Icons.school_rounded,
              AppColors.pink500,
              provider.filteredProjects
                  .where((p) => p.category == ProjectCategory.school)
                  .toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<Project> projects,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
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
              Text(
                '$title (${projects.length})',
                style: AppTypography.headlineSmall,
              ),
            ],
          ),
        ),
        _HorizontalProjectList(projects: projects),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INSIGHTS VIEW
// ─────────────────────────────────────────────────────────────────────────────

class _InsightsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, provider, _) {
        final all = provider.filteredProjects;
        final activeCount =
            all.where((p) => p.status == ProjectStatus.active).length;
        final slowingCount =
            all.where((p) => p.status == ProjectStatus.slowing).length;
        final stalledCount =
            all.where((p) => p.status == ProjectStatus.stalled).length;
        final unverifiedCount =
            all.where((p) => p.status == ProjectStatus.unverified).length;
        final highConf =
            all.where((p) => p.confidence == ConfidenceLevel.high).length;
        final medConf =
            all.where((p) => p.confidence == ConfidenceLevel.medium).length;
        final lowConf =
            all.where((p) => p.confidence == ConfidenceLevel.low).length;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            Text(
              AppStrings.projectInsights,
              style: AppTypography.displaySmall,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              AppStrings.overviewOfProjects(all.length),
              style: AppTypography.subtitle,
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            Text(
              AppStrings.statusBreakdown,
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            
            Row(
              children: [
                Expanded(
                  child: _InsightCard(
                    label: AppStrings.active,
                    count: activeCount,
                    color: AppColors.green500,
                    icon: Icons.play_circle_filled_rounded,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _InsightCard(
                    label: AppStrings.slowing,
                    count: slowingCount,
                    color: AppColors.amber500,
                    icon: Icons.slow_motion_video_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _InsightCard(
                    label: AppStrings.stalled,
                    count: stalledCount,
                    color: AppColors.red500,
                    icon: Icons.pause_circle_filled_rounded,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _InsightCard(
                    label: AppStrings.unverified,
                    count: unverifiedCount,
                    color: AppColors.gray500,
                    icon: Icons.help_rounded,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            Text(
              AppStrings.confidenceLevels,
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            
            _ConfidenceBar(
              label: AppStrings.highConfidence,
              count: highConf,
              total: all.length,
              color: AppColors.green500,
            ),
            const SizedBox(height: AppSpacing.sm),
            _ConfidenceBar(
              label: AppStrings.mediumConfidence,
              count: medConf,
              total: all.length,
              color: AppColors.amber500,
            ),
            const SizedBox(height: AppSpacing.sm),
            _ConfidenceBar(
              label: AppStrings.lowConfidence,
              count: lowConf,
              total: all.length,
              color: AppColors.red500,
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Info disclaimer
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.blue50,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.blue100),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.blue600,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      AppStrings.insightsDisclaimer,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.blue700,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _InsightCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                count.toString(),
                style: AppTypography.displaySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _ConfidenceBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _ConfidenceBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? count / total : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(label, style: AppTypography.labelLarge),
              const Spacer(),
              Text(
                '$count / $total',
                style: AppTypography.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
