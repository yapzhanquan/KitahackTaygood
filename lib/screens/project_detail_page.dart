import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/project_provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../models/project_model.dart';
import '../models/checkin_model.dart';
import '../widgets/status_badge.dart';
import '../widgets/confidence_badge.dart';
import '../widgets/project_map.dart';
import 'add_checkin_page.dart';
import 'sign_in_page.dart';

class ProjectDetailPage extends StatelessWidget {
  final String projectId;

  const ProjectDetailPage({super.key, required this.projectId});

  Color _categoryColor(ProjectCategory cat) {
    switch (cat) {
      case ProjectCategory.housing:
        return const Color(0xFF6366F1);
      case ProjectCategory.road:
        return const Color(0xFFF59E0B);
      case ProjectCategory.drainage:
        return const Color(0xFF06B6D4);
      case ProjectCategory.school:
        return const Color(0xFFEC4899);
    }
  }

  IconData _categoryIcon(ProjectCategory cat) {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, provider, _) {
        final project = provider.getProjectById(projectId);
        final color = _categoryColor(project.category);

        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // Hero image
                  SliverAppBar(
                    expandedHeight: 280,
                    pinned: true,
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1A1A2E),
                    actions: [
                      // ── Share button ──
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.share_outlined, size: 18),
                        ),
                        onPressed: () => _shareProject(project),
                      ),
                      // ── Bookmark button ──
                      Consumer<app_auth.AuthProvider>(
                        builder: (context, auth, _) {
                          final isBookmarked =
                              auth.isBookmarked(project.id);
                          return IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isBookmarked
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                size: 18,
                                color: isBookmarked
                                    ? const Color(0xFF6366F1)
                                    : null,
                              ),
                            ),
                            onPressed: () =>
                                _toggleBookmark(context, auth, project.id),
                          );
                        },
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withValues(alpha: 0.12),
                              color.withValues(alpha: 0.3),
                              color.withValues(alpha: 0.18),
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                _categoryIcon(project.category),
                                size: 80,
                                color: color.withValues(alpha: 0.4),
                              ),
                            ),
                            // Photo grid overlay hint
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFE5E7EB)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.grid_view_rounded,
                                        size: 16, color: Color(0xFF1A1A2E)),
                                    SizedBox(width: 6),
                                    Text(
                                      'Show all photos',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A1A2E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title section
                          _buildTitleSection(project, color),
                          const _Divider(),

                          // Agency section (like Hosted by)
                          _buildAgencySection(project),
                          const _Divider(),

                          // Highlights
                          _buildHighlights(project),
                          const _Divider(),

                          // Description
                          _buildDescription(project),
                          const _Divider(),

                          // Project Details grid (like Amenities)
                          _buildDetailsGrid(project),
                          const _Divider(),

                          // Check-in Timeline
                          _buildCheckInTimeline(project),
                          const _Divider(),

                          // Community Check-ins (like Reviews)
                          _buildReviewsSection(project),
                          const _Divider(),

                          // Location
                          _buildLocationSection(project),
                          const _Divider(),

                          // Disclaimer
                          _buildDisclaimer(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Sticky bottom bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomBar(context, project),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Action handlers ────────────────────────────────────────

  void _shareProject(Project project) {
    final shareText = '📍 ${project.name}\n'
        '📌 ${project.location}\n'
        '🏗 Status: ${project.status.label}\n'
        '🔍 Confidence: ${project.confidence.label}\n\n'
        '${project.description}\n\n'
        'Tracked on ProjekWatch — community progress tracking';
    Share.share(shareText);
  }

  void _toggleBookmark(
      BuildContext context, app_auth.AuthProvider auth, String projectId) async {
    if (!auth.isSignedIn) {
      final signedIn = await SignInPage.show(context);
      if (!signedIn) return;
    }
    auth.toggleBookmark(projectId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.isBookmarked(projectId)
                ? 'Project bookmarked'
                : 'Bookmark removed',
          ),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToCheckin(BuildContext context, Project project) async {
    final auth = context.read<app_auth.AuthProvider>();
    if (!auth.isSignedIn) {
      final signedIn = await SignInPage.show(context);
      if (!signedIn) return;
    }
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddCheckinPage(projectId: project.id),
        ),
      );
    }
  }

  // ── Section builders (unchanged layout) ────────────────────

  Widget _buildTitleSection(Project project, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_categoryIcon(project.category),
                        size: 14, color: color),
                    const SizedBox(width: 4),
                    Text(
                      project.category.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.location_on_outlined,
                  size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  project.location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              StatusBadge(status: project.status, fontSize: 12),
              const SizedBox(width: 8),
              ConfidenceBadge(confidence: project.confidence, fontSize: 11),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgencySection(Project project) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.business_rounded,
              color: Color(0xFF1A1A2E),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Managed by ${project.agencyOrDeveloper}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${project.checkIns.length} community check-ins',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlights(Project project) {
    final df = DateFormat('MMM d, y');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          _HighlightRow(
            icon: Icons.calendar_today_rounded,
            title: 'Expected Completion',
            subtitle: project.expectedCompletion != null
                ? df.format(project.expectedCompletion!)
                : 'Not specified',
          ),
          const SizedBox(height: 18),
          _HighlightRow(
            icon: Icons.update_rounded,
            title: 'Last Activity',
            subtitle: df.format(project.lastActivity),
          ),
          const SizedBox(height: 18),
          _HighlightRow(
            icon: Icons.verified_user_outlined,
            title: 'Last Verified',
            subtitle: df.format(project.lastVerified),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(Project project) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About this project',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            project.description,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF374151),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid(Project project) {
    final df = DateFormat('MMM d, y');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _DetailChip(
                  icon: Icons.category_rounded,
                  label: project.category.label),
              _DetailChip(
                  icon: Icons.public_rounded,
                  label: project.isPublic ? 'Public' : 'Private'),
              _DetailChip(
                  icon: Icons.business_rounded,
                  label: project.agencyOrDeveloper),
              _DetailChip(
                  icon: Icons.event_rounded,
                  label: project.expectedCompletion != null
                      ? 'Due ${df.format(project.expectedCompletion!)}'
                      : 'No deadline'),
              _DetailChip(
                  icon: Icons.people_rounded,
                  label: '${project.checkIns.length} check-ins'),
              _DetailChip(
                  icon: Icons.shield_outlined,
                  label: '${project.confidence.label} confidence'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInTimeline(Project project) {
    final df = DateFormat('MMM d, y');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline (${project.checkIns.length} check-ins)',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          ...project.checkIns.asMap().entries.map((entry) {
            final idx = entry.key;
            final ci = entry.value;
            final isLast = idx == project.checkIns.length - 1;

            return _TimelineItem(
              checkIn: ci,
              dateStr: df.format(ci.timestamp),
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(Project project) {
    final df = DateFormat('MMM d, y');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rate_review_outlined,
                  size: 22, color: Color(0xFF1A1A2E)),
              const SizedBox(width: 8),
              Text(
                '${project.checkIns.length} Community Reports',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...project.checkIns.take(5).map((ci) {
            return _ReviewCard(checkIn: ci, dateStr: df.format(ci.timestamp));
          }),
        ],
      ),
    );
  }

  Widget _buildLocationSection(Project project) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Where you'll find it",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            project.location,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 14),
          // ── Real map widget (falls back to styled placeholder) ──
          ProjectMap(
            latitude: project.latitude,
            longitude: project.longitude,
            projectName: project.name,
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Color(0xFFF59E0B), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Community-reported data. Not a legal finding. Information is provided as-is and may not reflect the official project status.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF92400E),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Project project) {
    final df = DateFormat('MMM d, y');
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusBadge(
                        status: project.status,
                        fontSize: 11,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                      ),
                      const SizedBox(width: 6),
                      ConfidenceBadge(
                          confidence: project.confidence, fontSize: 10),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Verified ${df.format(project.lastVerified)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _navigateToCheckin(context, project),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A2E),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Add Check-in',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper Widgets ──

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: const Color(0xFFF3F4F6),
    );
  }
}

class _HighlightRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HighlightRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 22, color: const Color(0xFF1A1A2E)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6B7280)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final CheckIn checkIn;
  final String dateStr;
  final bool isLast;

  const _TimelineItem({
    required this.checkIn,
    required this.dateStr,
    required this.isLast,
  });

  Color get _dotColor {
    switch (checkIn.status) {
      case ProjectStatus.active:
        return const Color(0xFF22C55E);
      case ProjectStatus.slowing:
        return const Color(0xFFEAB308);
      case ProjectStatus.stalled:
        return const Color(0xFFEF4444);
      case ProjectStatus.unverified:
        return const Color(0xFF9CA3AF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: _dotColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusBadge(
                        status: checkIn.status,
                        fontSize: 10,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    checkIn.note,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '— ${checkIn.reporterName}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                      fontStyle: FontStyle.italic,
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
}

class _ReviewCard extends StatelessWidget {
  final CheckIn checkIn;
  final String dateStr;

  const _ReviewCard({required this.checkIn, required this.dateStr});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    checkIn.reporterName.isNotEmpty
                        ? checkIn.reporterName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      checkIn.reporterName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                status: checkIn.status,
                fontSize: 10,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            checkIn.note,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
