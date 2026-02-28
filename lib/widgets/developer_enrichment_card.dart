import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/developer_enrichment_model.dart';
import '../models/project_model.dart';

/// A collapsible card showing developer enrichment data within the project
/// detail page. Displays status, risk flags, source links, and a refresh button.
///
/// Limits & Compliance: This widget only displays pre-generated data.
/// No scraping or data fetching happens in this widget.
class DeveloperEnrichmentCard extends StatefulWidget {
  final Project project;
  final VoidCallback onRefresh;
  final VoidCallback onViewDetails;

  const DeveloperEnrichmentCard({
    super.key,
    required this.project,
    required this.onRefresh,
    required this.onViewDetails,
  });

  @override
  State<DeveloperEnrichmentCard> createState() =>
      _DeveloperEnrichmentCardState();
}

class _DeveloperEnrichmentCardState extends State<DeveloperEnrichmentCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final enrichment = widget.project.developerEnrichment;
    final isLoading =
        enrichment != null && enrichment.status == EnrichmentStatus.loading;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header (always visible) ──
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_search_rounded,
                      color: Color(0xFF6366F1),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Developer Background (Auto)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (enrichment != null) _buildStatusChip(enrichment),
                        if (enrichment == null)
                          const Text(
                            'Tap to load developer info',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1)),
                      ),
                    )
                  else
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF9CA3AF),
                    ),
                ],
              ),
            ),
          ),

          // ── Expanded content ──
          if (_isExpanded && enrichment != null) ...[
            Container(height: 1, color: const Color(0xFFF3F4F6)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Last updated
                  if (enrichment.lastUpdated != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule,
                              size: 14, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Text(
                            'Updated ${DateFormat('MMM d, y – h:mm a').format(enrichment.lastUpdated!)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Summary
                  if (enrichment.summary.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        enrichment.summary,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF374151),
                          height: 1.5,
                        ),
                      ),
                    ),

                  // Risk flags
                  if (enrichment.riskFlags.isNotEmpty) ...[
                    const Text(
                      'Risk Flags',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...enrichment.riskFlags.take(5).map((flag) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFFEF4444))),
                              Expanded(
                                child: Text(
                                  flag,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF374151),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 8),
                  ],

                  // Top sources (show first 3)
                  if (enrichment.sources.isNotEmpty) ...[
                    const Text(
                      'Sources',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...enrichment.sources.take(3).map(
                          (src) => _SourceTile(source: src),
                        ),
                    if (enrichment.sources.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '+${enrichment.sources.length - 3} more sources',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],

                  const SizedBox(height: 12),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onRefresh,
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Refresh'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF6366F1),
                            side: const BorderSide(color: Color(0xFF6366F1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.onViewDetails,
                          icon: const Icon(Icons.open_in_new_rounded, size: 16),
                          label: const Text('View All'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Disclaimer
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 14, color: Color(0xFF9CA3AF)),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Public sources; may be incomplete.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9CA3AF),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(DeveloperEnrichment enrichment) {
    Color chipColor;
    switch (enrichment.status) {
      case EnrichmentStatus.ready:
        chipColor = const Color(0xFF10B981);
        break;
      case EnrichmentStatus.loading:
        chipColor = const Color(0xFF6366F1);
        break;
      case EnrichmentStatus.limited:
        chipColor = const Color(0xFFF59E0B);
        break;
      case EnrichmentStatus.error:
        chipColor = const Color(0xFFEF4444);
        break;
      case EnrichmentStatus.idle:
        chipColor = const Color(0xFF9CA3AF);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        enrichment.status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: chipColor,
        ),
      ),
    );
  }
}

// ── Source tile (tappable link) ──────────────────────────────────

class _SourceTile extends StatelessWidget {
  final DeveloperSourceItem source;

  const _SourceTile({required this.source});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;
    switch (source.type) {
      case SourceType.official:
        icon = Icons.language_rounded;
        iconColor = const Color(0xFF6366F1);
        break;
      case SourceType.filing:
        icon = Icons.description_rounded;
        iconColor = const Color(0xFF06B6D4);
        break;
      case SourceType.news:
        icon = Icons.newspaper_rounded;
        iconColor = const Color(0xFFF59E0B);
        break;
      case SourceType.review:
        icon = Icons.rate_review_rounded;
        iconColor = const Color(0xFF10B981);
        break;
      case SourceType.socialLink:
        icon = Icons.link_rounded;
        iconColor = const Color(0xFFEC4899);
        break;
    }

    return InkWell(
      onTap: () => _openUrl(source.url),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (source.notes != null)
                    Text(
                      source.notes!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            // Confidence indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _confidenceColor(source.confidence)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${(source.confidence * 100).round()}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _confidenceColor(source.confidence),
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.open_in_new, size: 14, color: Color(0xFF9CA3AF)),
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

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
