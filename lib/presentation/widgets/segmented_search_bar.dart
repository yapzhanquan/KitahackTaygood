import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/project_model.dart';

/// Premium Airbnb-style Segmented Search Bar
/// Three sections: Location, Category, Status with vertical dividers
/// Floating design with glassmorphism search button
class SegmentedSearchBar extends StatefulWidget {
  final ValueChanged<String>? onLocationChanged;
  final ValueChanged<ProjectCategory?>? onCategoryChanged;
  final ValueChanged<ProjectStatus?>? onStatusChanged;
  final VoidCallback? onSearchTap;

  const SegmentedSearchBar({
    super.key,
    this.onLocationChanged,
    this.onCategoryChanged,
    this.onStatusChanged,
    this.onSearchTap,
  });

  @override
  State<SegmentedSearchBar> createState() => _SegmentedSearchBarState();
}

class _SegmentedSearchBarState extends State<SegmentedSearchBar> {
  String _location = '';
  ProjectCategory? _selectedCategory;
  ProjectStatus? _selectedStatus;
  int? _expandedSection;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          // Main search bar
          _buildMainBar(),
          
          // Expanded section content
          if (_expandedSection != null)
            _buildExpandedContent(),
        ],
      ),
    );
  }

  Widget _buildMainBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Location section
          Expanded(
            flex: 3,
            child: _SearchSection(
              label: 'Location',
              value: _location.isEmpty ? 'Search location' : _location,
              isExpanded: _expandedSection == 0,
              onTap: () => _toggleSection(0),
            ),
          ),
          
          _buildDivider(),
          
          // Project Type section (renamed from Category)
          Expanded(
            flex: 2,
            child: _SearchSection(
              label: 'Project Type',
              value: _selectedCategory?.label ?? 'Any',
              isExpanded: _expandedSection == 1,
              onTap: () => _toggleSection(1),
            ),
          ),
          
          _buildDivider(),
          
          // Status section
          Expanded(
            flex: 2,
            child: _SearchSection(
              label: 'Status',
              value: _selectedStatus?.label ?? 'Any',
              isExpanded: _expandedSection == 2,
              onTap: () => _toggleSection(2),
            ),
          ),
          
          const SizedBox(width: AppSpacing.xs),
          
          // Search button
          _buildSearchButton(),
          
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 28,
      width: 1,
      color: AppColors.border,
    );
  }

  Widget _buildSearchButton() {
    return GestureDetector(
      onTap: () {
        setState(() => _expandedSection = null);
        widget.onSearchTap?.call();
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.slate800,
              AppColors.slate900,
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.slate900.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.search_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _expandedSection == 0
          ? _buildLocationInput()
          : _expandedSection == 1
              ? _buildCategoryOptions()
              : _buildStatusOptions(),
    );
  }

  Widget _buildLocationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search by location',
          style: AppTypography.labelMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          onChanged: (value) {
            setState(() => _location = value);
            widget.onLocationChanged?.call(value);
          },
          style: AppTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Enter city, district, or area...',
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            prefixIcon: Icon(
              Icons.location_on_outlined,
              color: AppColors.textTertiary,
              size: 20,
            ),
            filled: true,
            fillColor: AppColors.slate50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Popular locations',
          style: AppTypography.captionMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            _buildQuickOption('Kuala Lumpur', () {
              setState(() => _location = 'Kuala Lumpur');
              widget.onLocationChanged?.call('Kuala Lumpur');
            }),
            _buildQuickOption('Petaling Jaya', () {
              setState(() => _location = 'Petaling Jaya');
              widget.onLocationChanged?.call('Petaling Jaya');
            }),
            _buildQuickOption('Shah Alam', () {
              setState(() => _location = 'Shah Alam');
              widget.onLocationChanged?.call('Shah Alam');
            }),
            _buildQuickOption('Subang Jaya', () {
              setState(() => _location = 'Subang Jaya');
              widget.onLocationChanged?.call('Subang Jaya');
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by category',
          style: AppTypography.labelMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _buildCategoryChip(null, 'All', Icons.apps_rounded),
            _buildCategoryChip(
              ProjectCategory.housing,
              'Housing',
              Icons.apartment_rounded,
            ),
            _buildCategoryChip(
              ProjectCategory.road,
              'Road',
              Icons.route_rounded,
            ),
            _buildCategoryChip(
              ProjectCategory.drainage,
              'Drainage',
              Icons.water_rounded,
            ),
            _buildCategoryChip(
              ProjectCategory.school,
              'School',
              Icons.school_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by status',
          style: AppTypography.labelMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _buildStatusChip(null, 'All', AppColors.slate500),
            _buildStatusChip(
              ProjectStatus.active,
              'Active',
              AppColors.green500,
            ),
            _buildStatusChip(
              ProjectStatus.slowing,
              'Slowing',
              AppColors.amber500,
            ),
            _buildStatusChip(
              ProjectStatus.stalled,
              'Stalled',
              AppColors.red500,
            ),
            _buildStatusChip(
              ProjectStatus.unverified,
              'Unverified',
              AppColors.gray500,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickOption(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.slate50,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    ProjectCategory? category,
    String label,
    IconData icon,
  ) {
    final isSelected = _selectedCategory == category;
    final color = _getCategoryColor(category);

    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = category);
        widget.onCategoryChanged?.call(category);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? color : AppColors.textTertiary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(
    ProjectStatus? status,
    String label,
    Color color,
  ) {
    final isSelected = _selectedStatus == status;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedStatus = status);
        widget.onStatusChanged?.call(status);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSection(int section) {
    setState(() {
      _expandedSection = _expandedSection == section ? null : section;
    });
  }

  Color _getCategoryColor(ProjectCategory? category) {
    if (category == null) return AppColors.slate500;
    switch (category) {
      case ProjectCategory.housing:
        return AppColors.indigo500;
      case ProjectCategory.road:
        return AppColors.amber500;
      case ProjectCategory.drainage:
        return AppColors.cyan500;
      case ProjectCategory.school:
        return AppColors.pink500;
    }
  }
}

class _SearchSection extends StatelessWidget {
  final String label;
  final String value;
  final bool isExpanded;
  final VoidCallback onTap;

  const _SearchSection({
    required this.label,
    required this.value,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isExpanded 
              ? AppColors.slate50 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.captionMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
