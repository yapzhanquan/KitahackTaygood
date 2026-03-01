import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/services/developer_network_service.dart';
import '../../models/developer_network_model.dart';
import '../../models/project_model.dart';
import '../widgets/network_map_widget.dart';
import '../widgets/past_projects_gallery.dart';

/// Full-page investigative view for developer corporate network and legacy
class DeveloperProfilePage extends StatefulWidget {
  final Project project;

  const DeveloperProfilePage({super.key, required this.project});

  @override
  State<DeveloperProfilePage> createState() => _DeveloperProfilePageState();
}

class _DeveloperProfilePageState extends State<DeveloperProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _networkService = DeveloperNetworkService();
  
  DeveloperNetwork? _network;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDeveloperNetwork();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDeveloperNetwork() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final network = await _networkService.getDeveloperNetwork(
        widget.project.agencyOrDeveloper,
      );
      
      setState(() {
        _network = network;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(innerBoxIsScrolled),
          ];
        },
        body: _isLoading
            ? _buildLoadingState()
            : _error != null
                ? _buildErrorState()
                : _buildContent(),
      ),
    );
  }

  Widget _buildSliverAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      floating: false,
      backgroundColor: AppColors.slate900,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: const Icon(Icons.arrow_back_rounded, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(Icons.refresh_rounded, size: 20),
          ),
          onPressed: _loadDeveloperNetwork,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.slate900,
                AppColors.indigo900,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        ),
                        child: const Icon(
                          Icons.domain_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Developer Profile',
                              style: AppTypography.captionMedium.copyWith(
                                color: Colors.white60,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.project.agencyOrDeveloper,
                              style: AppTypography.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Risk badge if network loaded
                  if (_network != null)
                    _buildRiskBadge(_network!.riskSummary.overallRisk),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: AppColors.slate900,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            labelStyle: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.hub_rounded, size: 18),
                text: 'Network & Risks',
              ),
              Tab(
                icon: Icon(Icons.history_rounded, size: 18),
                text: 'Project Legacy',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskBadge(DirectorRiskLevel risk) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: risk.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: risk.color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            risk == DirectorRiskLevel.low
                ? Icons.verified_rounded
                : risk == DirectorRiskLevel.medium
                    ? Icons.info_rounded
                    : Icons.warning_rounded,
            size: 16,
            color: risk.color,
          ),
          const SizedBox(width: 6),
          Text(
            risk.label.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: risk.color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.indigo600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Scanning SSM Records...',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.slate600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Checking director histories & associations',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.slate400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.red400,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Failed to Load Developer Data',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.slate700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _error ?? 'Unknown error occurred',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.slate500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: _loadDeveloperNetwork,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.indigo600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildNetworkTab(),
        _buildLegacyTab(),
      ],
    );
  }

  Widget _buildNetworkTab() {
    if (_network == null) return const SizedBox.shrink();
    
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 2.5,
      boundaryMargin: const EdgeInsets.all(100),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: NetworkMapWidget(network: _network!),
      ),
    );
  }

  Widget _buildLegacyTab() {
    if (_network == null) return const SizedBox.shrink();
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          PastProjectsGallery(
            projects: _network!.pastProjects,
            developerName: _network!.companyName,
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // Community Photos Section if available
          if (_network!.pastProjects.any((p) => p.communityPhotos.isNotEmpty))
            _buildCommunityPhotosSection(),
          
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildCommunityPhotosSection() {
    final allPhotos = _network!.pastProjects
        .expand((p) => p.communityPhotos.map((photo) => _PhotoWithProject(photo: photo, project: p)))
        .toList();
    
    if (allPhotos.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.blue50,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  Icons.photo_library_rounded,
                  color: AppColors.blue600,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Community Evidence',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate900,
                      ),
                    ),
                    Text(
                      'Real photos from past buyers',
                      style: AppTypography.captionMedium.copyWith(
                        color: AppColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: allPhotos.length,
            itemBuilder: (context, index) {
              final item = allPhotos[index];
              return _CommunityPhotoCard(
                photo: item.photo,
                projectName: item.project.name,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PhotoWithProject {
  final CommunityPhoto photo;
  final PastProject project;
  
  _PhotoWithProject({required this.photo, required this.project});
}

class _CommunityPhotoCard extends StatelessWidget {
  final CommunityPhoto photo;
  final String projectName;

  const _CommunityPhotoCard({
    required this.photo,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusMd - 1),
              ),
              child: Image.network(
                photo.url,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.slate100,
                  child: Icon(Icons.broken_image_rounded, color: AppColors.slate300),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  photo.caption,
                  style: AppTypography.captionMedium.copyWith(
                    color: AppColors.slate700,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'by ${photo.uploaderName}',
                  style: AppTypography.captionMedium.copyWith(
                    color: AppColors.slate400,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
