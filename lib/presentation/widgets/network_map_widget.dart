import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/developer_network_model.dart';

/// Interactive network map showing director connections and risk associations
class NetworkMapWidget extends StatefulWidget {
  final DeveloperNetwork network;

  const NetworkMapWidget({super.key, required this.network});

  @override
  State<NetworkMapWidget> createState() => _NetworkMapWidgetState();
}

class _NetworkMapWidgetState extends State<NetworkMapWidget> {
  Director? _selectedDirector;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Risk Summary Alert
        if (widget.network.hasHighRiskDirectors) _buildCriticalAlert(),
        
        const SizedBox(height: AppSpacing.lg),
        
        // Company Info Card
        _buildCompanyInfoCard(),
        
        const SizedBox(height: AppSpacing.lg),
        
        // Directors Network
        _buildDirectorsSection(),
        
        const SizedBox(height: AppSpacing.lg),
        
        // AI Analysis
        _buildAIAnalysisCard(),
        
        const SizedBox(height: AppSpacing.lg),
        
        // Source Links
        _buildSourceLinks(),
      ],
    );
  }

  Widget _buildCriticalAlert() {
    final highRiskCount = widget.network.directors.where((d) => d.hasHighRisk).length;
    final failedCount = widget.network.totalFailedAssociations;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.red600.withOpacity(0.15),
            AppColors.red600.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.red600.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.red600,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
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
                  '⚠️ DIRECTORSHIP ALERT',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.red600,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$highRiskCount director(s) linked to $failedCount failed/blacklisted companies',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.slate700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate900.withOpacity(0.04),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.indigo50,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  Icons.business_rounded,
                  color: AppColors.indigo600,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.network.companyName,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.network.registrationNumber,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.slate500,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.slate100),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow('Status', widget.network.companyStatus, 
              widget.network.companyStatus.contains('Scrutiny') ? AppColors.amber600 : AppColors.green600),
          _buildInfoRow('Incorporated', _formatDate(widget.network.incorporationDate), AppColors.slate600),
          _buildInfoRow('Paid-up Capital', 'RM ${_formatCurrency(widget.network.paidUpCapital)}', AppColors.slate600),
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.network.businessAddress,
            style: AppTypography.bodySmall.copyWith(color: AppColors.slate500),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: AppColors.slate500),
          ),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.people_alt_rounded, size: 18, color: AppColors.slate700),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Director Network',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.slate900,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                '${widget.network.directors.length} Directors',
                style: AppTypography.captionMedium.copyWith(
                  color: AppColors.slate600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...widget.network.directors.map((director) => _buildDirectorCard(director)),
      ],
    );
  }

  Widget _buildDirectorCard(Director director) {
    final isExpanded = _selectedDirector?.id == director.id;
    final hasRisk = director.hasHighRisk;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: hasRisk ? AppColors.red50 : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: hasRisk ? AppColors.red200 : AppColors.slate200,
          width: hasRisk ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (hasRisk ? AppColors.red600 : AppColors.slate900).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _selectedDirector = isExpanded ? null : director;
              });
            },
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // Avatar with risk indicator
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: hasRisk ? AppColors.red100 : AppColors.slate100,
                        child: Text(
                          director.name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join(),
                          style: AppTypography.labelMedium.copyWith(
                            color: hasRisk ? AppColors.red700 : AppColors.slate600,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (hasRisk)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.red600,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.warning_rounded,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          director.name,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              director.position,
                              style: AppTypography.captionMedium.copyWith(
                                color: AppColors.slate500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: director.riskLevel.backgroundColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                director.riskLevel.label,
                                style: AppTypography.captionMedium.copyWith(
                                  color: director.riskLevel.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (director.alertMessage != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            director.alertMessage!,
                            style: AppTypography.captionMedium.copyWith(
                              color: AppColors.red600,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${director.associations.length}',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: hasRisk ? AppColors.red600 : AppColors.slate700,
                        ),
                      ),
                      Text(
                        'Links',
                        style: AppTypography.captionMedium.copyWith(
                          color: AppColors.slate400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.slate400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded associations
          if (isExpanded) ...[
            const Divider(height: 1, color: AppColors.slate200),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Company Associations',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.slate500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...director.associations.map((assoc) => _buildAssociationItem(assoc)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAssociationItem(CompanyAssociation association) {
    final isBad = association.status == CompanyStatus.failed || 
                  association.status == CompanyStatus.blacklisted ||
                  association.status == CompanyStatus.underInvestigation;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isBad ? AppColors.red50 : AppColors.slate50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isBad ? AppColors.red200 : AppColors.slate200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                association.status.icon,
                size: 16,
                color: association.status.color,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  association.companyName,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: association.status.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  association.status.label,
                  style: AppTypography.captionMedium.copyWith(
                    color: association.status.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${association.registrationNumber} • ${association.role ?? "Director"}',
            style: AppTypography.captionMedium.copyWith(
              color: AppColors.slate500,
              fontFamily: 'monospace',
              fontSize: 10,
            ),
          ),
          if (association.failureReason != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.red100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.report_problem_rounded, size: 14, color: AppColors.red600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      association.failureReason!,
                      style: AppTypography.captionMedium.copyWith(
                        color: AppColors.red700,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _launchUrl(association.sourceUrl),
            child: Row(
              children: [
                Icon(Icons.link_rounded, size: 12, color: AppColors.blue500),
                const SizedBox(width: 4),
                Text(
                  'View SSM Record',
                  style: AppTypography.captionMedium.copyWith(
                    color: AppColors.blue500,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysisCard() {
    final summary = widget.network.riskSummary;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            summary.overallRisk.backgroundColor,
            summary.overallRisk.backgroundColor.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: summary.overallRisk.color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: summary.overallRisk.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  Icons.psychology_rounded,
                  color: summary.overallRisk.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Risk Analysis',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate900,
                      ),
                    ),
                    Text(
                      'Powered by Gemini',
                      style: AppTypography.captionMedium.copyWith(
                        color: AppColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: summary.overallRisk.color,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Text(
                  summary.overallRisk.label.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            summary.aiAnalysis,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.slate700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.slate200),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Key Findings',
            style: AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.slate700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...summary.keyFindings.map((finding) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              finding,
              style: AppTypography.bodySmall.copyWith(
                color: finding.startsWith('✓') ? AppColors.green700 : 
                       finding.startsWith('⚠️') ? AppColors.red700 : AppColors.slate600,
                fontWeight: FontWeight.w500,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSourceLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.source_rounded, size: 16, color: AppColors.slate500),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Data Sources',
              style: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.slate500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.network.sourceUrls.map((url) {
            final domain = Uri.tryParse(url)?.host ?? url;
            return InkWell(
              onTap: () => _launchUrl(url),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.link_rounded, size: 12, color: AppColors.blue500),
                    const SizedBox(width: 4),
                    Text(
                      domain,
                      style: AppTypography.captionMedium.copyWith(
                        color: AppColors.blue600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Last updated: ${_formatDateTime(widget.network.lastUpdated)}',
          style: AppTypography.captionMedium.copyWith(
            color: AppColors.slate400,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
