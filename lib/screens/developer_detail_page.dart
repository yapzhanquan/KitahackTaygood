import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/developer_enrichment_model.dart';
import '../models/project_model.dart';
import '../providers/project_provider.dart';

/// Full-page developer background view.
/// Shows all enrichment sources organized by type, risk flags, and action buttons.
///
/// Limits & Compliance:
/// • Display-only — no scraping or data fetching in this widget.
/// • All source links open externally; no embedded content.
class DeveloperDetailPage extends StatelessWidget {
  final String projectId;

  const DeveloperDetailPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, provider, _) {
        final project = provider.getProjectById(projectId);
        final enrichment = project.developerEnrichment;
        final df = DateFormat('MMM d, y');

        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          appBar: AppBar(
            title: const Text(
              'Developer Background',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xFF1A1A2E),
              ),
            ),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1A1A2E),
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh enrichment data',
                onPressed: () {
                  provider.enrichDeveloperForProject(projectId,
                      forceRefresh: true);
                },
              ),
            ],
          ),
          body: enrichment == null || enrichment.status == EnrichmentStatus.idle
              ? _buildEmptyState(context, provider, projectId)
              : enrichment.status == EnrichmentStatus.loading
                  ? _buildLoadingState()
                  : _buildContent(context, project, enrichment, df),
        );
      },
    );
  }

  Widget _buildEmptyState(
      BuildContext context, ProjectProvider provider, String pid) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.person_search_rounded,
                size: 40,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Developer data not loaded',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap below to generate developer background information from public sources.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.enrichDeveloperForProject(pid),
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              label: const Text('Load Developer Info'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1)),
          ),
          SizedBox(height: 16),
          Text(
            'Generating developer background…',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Project project,
      DeveloperEnrichment enrichment, DateFormat df) {
    // Group sources by type.
    final officialSources =
        enrichment.sources.where((s) => s.type == SourceType.official).toList();
    final filingSources =
        enrichment.sources.where((s) => s.type == SourceType.filing).toList();
    final newsSources =
        enrichment.sources.where((s) => s.type == SourceType.news).toList();
    final reviewSources =
        enrichment.sources.where((s) => s.type == SourceType.review).toList();
    final socialSources = enrichment.sources
        .where((s) => s.type == SourceType.socialLink)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Developer header ──
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6366F1).withValues(alpha: 0.08),
                  const Color(0xFF6366F1).withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.business_rounded,
                        color: Color(0xFF6366F1),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.agencyOrDeveloper,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          if (project.developerWebsite != null &&
                              project.developerWebsite!.isNotEmpty)
                            GestureDetector(
                              onTap: () =>
                                  _openUrl(project.developerWebsite!),
                              child: Text(
                                project.developerWebsite!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6366F1),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Status + last updated row
                Row(
                  children: [
                    _StatusChipLarge(status: enrichment.status),
                    const Spacer(),
                    if (enrichment.lastUpdated != null)
                      Text(
                        'Updated ${df.format(enrichment.lastUpdated!)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                  ],
                ),
                if (enrichment.summary.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    enrichment.summary,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151),
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Risk Flags ──
          if (enrichment.riskFlags.isNotEmpty)
            _SectionCard(
              title: 'Risk Flags',
              icon: Icons.warning_amber_rounded,
              iconColor: const Color(0xFFEF4444),
              child: Column(
                children: enrichment.riskFlags.map((flag) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 6, right: 10),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            flag,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF374151),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          // ── Official Sources ──
          if (officialSources.isNotEmpty)
            _SourceSection(
              title: 'Official Sources',
              icon: Icons.language_rounded,
              iconColor: const Color(0xFF6366F1),
              sources: officialSources,
            ),

          // ── Filings & Reports ──
          if (filingSources.isNotEmpty)
            _SourceSection(
              title: 'Filings & Reports',
              icon: Icons.description_rounded,
              iconColor: const Color(0xFF06B6D4),
              sources: filingSources,
            ),

          // ── News ──
          if (newsSources.isNotEmpty)
            _SourceSection(
              title: 'News Coverage',
              icon: Icons.newspaper_rounded,
              iconColor: const Color(0xFFF59E0B),
              sources: newsSources,
            ),

          // ── Reviews ──
          if (reviewSources.isNotEmpty)
            _SourceSection(
              title: 'Public Reviews',
              icon: Icons.rate_review_rounded,
              iconColor: const Color(0xFF10B981),
              sources: reviewSources,
            ),

          // ── Social Links ──
          if (socialSources.isNotEmpty)
            _SourceSection(
              title: 'Social Links',
              icon: Icons.link_rounded,
              iconColor: const Color(0xFFEC4899),
              sources: socialSources,
            ),

          // ── Compliance disclaimer ──
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: Color(0xFFF59E0B)),
                    SizedBox(width: 8),
                    Text(
                      'Compliance Notice',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'This information is generated from public sources only. '
                  'No login scraping, CAPTCHA bypass, or paywall bypass is used. '
                  'Data may be incomplete — always verify via official channels.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF92400E),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ── Helper widgets ──────────────────────────────────────────────

class _StatusChipLarge extends StatelessWidget {
  final EnrichmentStatus status;

  const _StatusChipLarge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    IconData icon;
    switch (status) {
      case EnrichmentStatus.ready:
        chipColor = const Color(0xFF10B981);
        icon = Icons.check_circle_rounded;
        break;
      case EnrichmentStatus.loading:
        chipColor = const Color(0xFF6366F1);
        icon = Icons.hourglass_top_rounded;
        break;
      case EnrichmentStatus.limited:
        chipColor = const Color(0xFFF59E0B);
        icon = Icons.warning_rounded;
        break;
      case EnrichmentStatus.error:
        chipColor = const Color(0xFFEF4444);
        icon = Icons.error_rounded;
        break;
      case EnrichmentStatus.idle:
        chipColor = const Color(0xFF9CA3AF);
        icon = Icons.circle_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
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
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SourceSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<DeveloperSourceItem> sources;

  const _SourceSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.sources,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      icon: icon,
      iconColor: iconColor,
      child: Column(
        children: sources.map((src) {
          return _DetailedSourceTile(source: src);
        }).toList(),
      ),
    );
  }
}

class _DetailedSourceTile extends StatelessWidget {
  final DeveloperSourceItem source;

  const _DetailedSourceTile({required this.source});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openUrl(source.url),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (source.snippet != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        source.snippet!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Row(
                    children: [
                      // Confidence badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: _confidenceColor(source.confidence)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Confidence: ${(source.confidence * 100).round()}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _confidenceColor(source.confidence),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Sentiment badge
                      if (source.sentiment != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: _sentimentColor(source.sentiment!)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            source.sentiment!.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _sentimentColor(source.sentiment!),
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      // Type badge
                      Text(
                        source.type.label,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                  if (source.notes != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        source.notes!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.open_in_new_rounded,
                size: 16,
                color: Color(0xFF6366F1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _confidenceColor(double c) {
    if (c >= 0.7) return const Color(0xFF10B981);
    if (c >= 0.4) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Color _sentimentColor(SourceSentiment s) {
    switch (s) {
      case SourceSentiment.pos:
        return const Color(0xFF10B981);
      case SourceSentiment.neu:
        return const Color(0xFF6B7280);
      case SourceSentiment.neg:
        return const Color(0xFFEF4444);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
