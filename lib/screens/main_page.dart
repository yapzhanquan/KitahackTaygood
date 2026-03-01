import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/project_model.dart';
import '../widgets/hero_search_bar.dart';
import '../widgets/section_header.dart';
import '../widgets/project_card.dart';
import 'project_detail_page.dart';
import '../auth/login_guard.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedTab = 0;

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
          const Spacer(),
          // Center tabs
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
          const Spacer(),
          // Contribute button
          GestureDetector(
            onTap: () async {
              if (!await requireLogin(context)) return;
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Open a project to add a check-in.'),
                ),
              );
            },
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
          Container(
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
          ),
        ],
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
