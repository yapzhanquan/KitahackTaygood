import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../models/project_model.dart';
import '../widgets/hero_search_bar.dart';
import '../widgets/section_header.dart';
import '../widgets/project_card.dart';
import 'project_detail_page.dart';
import 'add_checkin_page.dart';
import 'sign_in_page.dart';
import '../widgets/status_badge.dart';
import '../services/ai_insight_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedTab = 0;
  final AiInsightService _aiInsightService = AiInsightService();
  String? _aiInsightText;
  String? _aiInsightNote;
  bool _isGeneratingAiInsight = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _selectedTab == 0
                  ? _buildProjectsView()
                  : _selectedTab == 1
                      ? _buildCategoriesView()
                      : _buildInsightsView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo
          const Text(
            'ProjekWatch',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 10),
          // Tabs can scroll horizontally when space is tight.
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TabButton(
                    label: 'Projects',
                    isSelected: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                  _TabButton(
                    label: 'Categories',
                    isSelected: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                  _TabButton(
                    label: 'Insights',
                    isSelected: _selectedTab == 2,
                    onTap: () => setState(() => _selectedTab = 2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Contribute button
          GestureDetector(
            onTap: () => _onContributeTap(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Contribute',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Profile icon
          GestureDetector(
            onTap: () => _onProfileTap(context),
            child: Consumer<app_auth.AuthProvider>(
              builder: (context, auth, _) {
                if (auth.isSignedIn && auth.currentUser?.avatarUrl != null) {
                  return CircleAvatar(
                    radius: 18,
                    backgroundImage:
                        NetworkImage(auth.currentUser!.avatarUrl!),
                    backgroundColor: const Color(0xFFF3F4F6),
                  );
                }
                return Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 20,
                    color: Color(0xFF6B7280),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onContributeTap(BuildContext context) async {
    final auth = context.read<app_auth.AuthProvider>();
    if (!auth.isSignedIn) {
      final signedIn = await SignInPage.show(context);
      if (!signedIn) return;
    }
    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => _ContributeSheet(),
      );
    }
  }

  void _onProfileTap(BuildContext context) {
    final auth = context.read<app_auth.AuthProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                if (auth.isSignedIn) ...[
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: auth.currentUser?.avatarUrl != null
                        ? NetworkImage(auth.currentUser!.avatarUrl!)
                        : null,
                    backgroundColor: const Color(0xFFF3F4F6),
                    child: auth.currentUser?.avatarUrl == null
                        ? const Icon(Icons.person, size: 32)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    auth.currentUser?.name ?? 'User',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  if (auth.currentUser?.email != null)
                    Text(
                      auth.currentUser!.email!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        auth.signOut();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const Icon(Icons.person_outline_rounded,
                      size: 48, color: Color(0xFF9CA3AF)),
                  const SizedBox(height: 12),
                  const Text(
                    'Not signed in',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sign in to contribute check-ins and bookmark projects.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await SignInPage.show(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A2E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectsView() {
    return Consumer<ProjectProvider>(
      builder: (context, provider, _) {
        final active = provider.activeProjects;
        final stalled = provider.stalledProjects;
        final publicP = provider.publicProjects;
        final privateP = provider.privateProjects;

        return ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            HeroSearchBar(
              onSearchTap: () {},
              onQueryChanged: (q) => provider.setSearchQuery(q),
              onCategoryChanged: (c) => provider.setCategoryFilter(c),
              onStatusChanged: (s) => provider.setStatusFilter(s),
            ),

            // Show filtered results if filters are active
            if (provider.searchQuery.isNotEmpty ||
                provider.categoryFilter != null ||
                provider.statusFilter != null) ...[
              const SizedBox(height: 8),
              SectionHeader(title: 'Search Results (${provider.filteredProjects.length})'),
              _buildHorizontalList(provider.filteredProjects),
              const SizedBox(height: 16),
            ] else ...[
              const SizedBox(height: 8),
              SectionHeader(title: 'Active Projects Near You'),
              _buildHorizontalList(active),
              const SizedBox(height: 20),
              SectionHeader(title: 'Recently Flagged as Stalled'),
              _buildHorizontalList(stalled),
              const SizedBox(height: 20),
              SectionHeader(title: 'Public Infrastructure'),
              _buildHorizontalList(publicP),
              const SizedBox(height: 20),
              SectionHeader(title: 'Private Developments'),
              _buildHorizontalList(privateP),
            ],
          ],
        );
      },
    );
  }

  Widget _buildHorizontalList(List<Project> projects) {
    if (projects.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 40,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 8),
              Text(
                'No projects found',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 268,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 20),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          return ProjectCard(
            project: projects[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProjectDetailPage(projectId: projects[index].id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoriesView() {
    return Consumer<ProjectProvider>(
      builder: (context, provider, _) {
        return ListView(
          padding: const EdgeInsets.only(bottom: 32, top: 16),
          children: [
            _buildCategorySection(
              'Housing',
              Icons.apartment_rounded,
              const Color(0xFF6366F1),
              provider.filteredProjects
                  .where((p) => p.category == ProjectCategory.housing)
                  .toList(),
            ),
            _buildCategorySection(
              'Road',
              Icons.route_rounded,
              const Color(0xFFF59E0B),
              provider.filteredProjects
                  .where((p) => p.category == ProjectCategory.road)
                  .toList(),
            ),
            _buildCategorySection(
              'Drainage',
              Icons.water_rounded,
              const Color(0xFF06B6D4),
              provider.filteredProjects
                  .where((p) => p.category == ProjectCategory.drainage)
                  .toList(),
            ),
            _buildCategorySection(
              'School',
              Icons.school_rounded,
              const Color(0xFFEC4899),
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
      String title, IconData icon, Color color, List<Project> projects) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                '$title (${projects.length})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ),
        _buildHorizontalList(projects),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildInsightsView() {
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
        final totalCheckIns =
            all.fold<int>(0, (sum, project) => sum + project.checkIns.length);
        final stalledSlowing = stalledCount + slowingCount;
        final stalledSlowingPct = all.isEmpty
            ? 0.0
            : ((stalledSlowing / all.length) * 100).clamp(0.0, 100.0);
        final avgCheckIns =
            all.isEmpty ? 0.0 : totalCheckIns / all.length;
        final highConfidencePct =
            all.isEmpty ? 0.0 : ((highConf / all.length) * 100).clamp(0.0, 100.0);

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Project Insights',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Overview of ${all.length} tracked projects',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          size: 18, color: Color(0xFF4F46E5)),
                      const SizedBox(width: 8),
                      const Text(
                        'AI Portfolio Summary',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _isGeneratingAiInsight
                            ? null
                            : () => _generateAiInsights(all),
                        child: _isGeneratingAiInsight
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Generate'),
                      ),
                    ],
                  ),
                  if (_aiInsightText != null) ...[
                    Text(
                      _aiInsightText!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF374151),
                        height: 1.4,
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Generate an AI-backed summary to highlight portfolio health, risks, and immediate actions.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (_aiInsightNote != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _aiInsightNote!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Impact Metrics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MetricTile(
                  label: 'Total Check-ins',
                  value: totalCheckIns.toString(),
                ),
                const SizedBox(width: 12),
                _MetricTile(
                  label: 'Avg Check-ins/Project',
                  value: avgCheckIns.toStringAsFixed(1),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MetricTile(
                  label: 'Stalled+Slowing Rate',
                  value: '${stalledSlowingPct.toStringAsFixed(1)}%',
                ),
                const SizedBox(width: 12),
                _MetricTile(
                  label: 'High Confidence Rate',
                  value: '${highConfidencePct.toStringAsFixed(1)}%',
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Status Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InsightCard(
                  label: 'Active',
                  count: activeCount,
                  color: const Color(0xFF22C55E),
                  icon: Icons.play_circle_filled_rounded,
                ),
                const SizedBox(width: 12),
                _InsightCard(
                  label: 'Slowing',
                  count: slowingCount,
                  color: const Color(0xFFEAB308),
                  icon: Icons.slow_motion_video_rounded,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InsightCard(
                  label: 'Stalled',
                  count: stalledCount,
                  color: const Color(0xFFEF4444),
                  icon: Icons.pause_circle_filled_rounded,
                ),
                const SizedBox(width: 12),
                _InsightCard(
                  label: 'Unverified',
                  count: unverifiedCount,
                  color: const Color(0xFF9CA3AF),
                  icon: Icons.help_rounded,
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'Confidence Levels',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            _ConfidenceBar(label: 'High', count: highConf, total: all.length, color: const Color(0xFF22C55E)),
            const SizedBox(height: 8),
            _ConfidenceBar(label: 'Medium', count: medConf, total: all.length, color: const Color(0xFFEAB308)),
            const SizedBox(height: 8),
            _ConfidenceBar(label: 'Low', count: lowConf, total: all.length, color: const Color(0xFFEF4444)),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF0284C7), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Community-reported data. Not a legal finding. Help improve accuracy by contributing check-ins.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blueGrey.shade700,
                        height: 1.4,
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

  Future<void> _generateAiInsights(List<Project> projects) async {
    setState(() {
      _isGeneratingAiInsight = true;
      _aiInsightNote = null;
    });

    final result = await _aiInsightService.generatePortfolioInsights(projects);
    if (!mounted) return;

    setState(() {
      _aiInsightText = result.summary;
      _aiInsightNote = result.note ??
          (result.usedAi
              ? 'Generated using ${result.modelUsed ?? 'Gemini'}.'
              : null);
      _isGeneratingAiInsight = false;
    });
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? const Color(0xFF1A1A2E)
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? const Color(0xFF1A1A2E)
                : const Color(0xFF9CA3AF),
          ),
        ),
      ),
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;

  const _MetricTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const Spacer(),
              Text(
                '$count / $total',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet shown when user taps "Contribute" (after auth).
class _ContributeSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProjectProvider>();
    final projects = provider.allProjects;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Contribute a Check-in',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select a project to add your observation.',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: ListView.separated(
                  itemCount: projects.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final p = projects[i];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _categoryIconFor(p.category),
                          size: 20,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      title: Text(
                        p.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      subtitle: Text(
                        p.location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      trailing: StatusBadge(
                          status: p.status,
                          fontSize: 10,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2)),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddCheckinPage(projectId: p.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIconFor(ProjectCategory cat) {
    switch (cat) {
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
}
