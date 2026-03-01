import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/project_model.dart';

/// A clickable badge that shows source attribution and opens URLs
class SourceLinkBadge extends StatelessWidget {
  final ScrapedSource source;
  final bool compact;
  final bool showIcon;

  const SourceLinkBadge({
    super.key,
    required this.source,
    this.compact = false,
    this.showIcon = true,
  });

  Future<void> _launchUrl() async {
    final uri = Uri.parse(source.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactBadge();
    }
    return _buildFullBadge();
  }

  Widget _buildCompactBadge() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _launchUrl,
        borderRadius: BorderRadius.circular(4),
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
              Icon(Icons.link_rounded, size: 10, color: AppColors.slate400),
              const SizedBox(width: 3),
              Text(
                source.domain,
                style: AppTypography.captionMedium.copyWith(
                  color: AppColors.slate500,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullBadge() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _launchUrl,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.slate50,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: AppColors.slate200, width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIcon) ...[
                Text(source.typeIcon, style: const TextStyle(fontSize: 10)),
                const SizedBox(width: 4),
              ],
              Text(
                source.domain,
                style: AppTypography.captionMedium.copyWith(
                  color: AppColors.slate600,
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.open_in_new_rounded, size: 10, color: AppColors.slate400),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows multiple source badges in a row
class SourceBadgeRow extends StatelessWidget {
  final List<ScrapedSource> sources;
  final int maxVisible;

  const SourceBadgeRow({
    super.key,
    required this.sources,
    this.maxVisible = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) return const SizedBox.shrink();

    final visibleSources = sources.take(maxVisible).toList();
    final remaining = sources.length - maxVisible;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ...visibleSources.map((s) => SourceLinkBadge(source: s, compact: true)),
        if (remaining > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '+$remaining',
              style: AppTypography.captionMedium.copyWith(
                color: AppColors.slate500,
                fontSize: 9,
              ),
            ),
          ),
      ],
    );
  }
}

/// Inline source citation for comparison rows
class SourceCitation extends StatelessWidget {
  final String text;
  final List<ScrapedSource>? sources;
  final String? sourceCount;
  final String? sourceDomains;

  const SourceCitation({
    super.key,
    required this.text,
    this.sources,
    this.sourceCount,
    this.sourceDomains,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        if (sources != null && sources!.isNotEmpty)
          SourceBadgeRow(sources: sources!)
        else if (sourceCount != null || sourceDomains != null)
          _buildSourceSummary(),
      ],
    );
  }

  Widget _buildSourceSummary() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.source_rounded, size: 10, color: AppColors.slate400),
        const SizedBox(width: 4),
        Text(
          sourceCount != null 
              ? 'Based on $sourceCount from ${sourceDomains ?? "multiple sources"}'
              : 'Source: ${sourceDomains ?? "verified data"}',
          style: AppTypography.captionMedium.copyWith(
            color: AppColors.slate400,
            fontSize: 9,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

/// Check-in reference badge showing community verification
class CheckInReference extends StatelessWidget {
  final String checkInId;
  final DateTime timestamp;
  final String? reporterName;

  const CheckInReference({
    super.key,
    required this.checkInId,
    required this.timestamp,
    this.reporterName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.blue50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.blue100, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user_rounded, size: 10, color: AppColors.blue500),
          const SizedBox(width: 4),
          Text(
            'ID: ${checkInId.substring(0, checkInId.length.clamp(0, 6))}',
            style: AppTypography.captionMedium.copyWith(
              color: AppColors.blue600,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (reporterName != null) ...[
            const SizedBox(width: 4),
            Text(
              '• $reporterName',
              style: AppTypography.captionMedium.copyWith(
                color: AppColors.blue500,
                fontSize: 9,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
