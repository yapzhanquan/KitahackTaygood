import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../models/project_model.dart';

/// Premium Airbnb-style Hero Search Bar
/// Clean, minimal design with subtle interactions
class HeroSearchBar extends StatefulWidget {
  final VoidCallback? onSearchTap;
  final ValueChanged<String>? onQueryChanged;
  final ValueChanged<ProjectCategory?>? onCategoryChanged;
  final ValueChanged<ProjectStatus?>? onStatusChanged;
  final bool expanded;

  const HeroSearchBar({
    super.key,
    this.onSearchTap,
    this.onQueryChanged,
    this.onCategoryChanged,
    this.onStatusChanged,
    this.expanded = false,
  });

  @override
  State<HeroSearchBar> createState() => _HeroSearchBarState();
}

class _HeroSearchBarState extends State<HeroSearchBar> {
  final _searchController = TextEditingController();
  ProjectCategory? _selectedCategory;
  ProjectStatus? _selectedStatus;
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _selectedStatus = null;
    });
    widget.onQueryChanged?.call('');
    widget.onCategoryChanged?.call(null);
    widget.onStatusChanged?.call(null);
  }

  bool get _hasActiveFilters =>
      _searchController.text.isNotEmpty ||
      _selectedCategory != null ||
      _selectedStatus != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        children: [
          // Main search bar
          _buildSearchBar(),
          
          // Filter toggle
          if (_showFilters) ...[
            const SizedBox(height: AppSpacing.md),
            _buildFilterChips(),
          ],
          
          // Active filters indicator
          if (_hasActiveFilters && !_showFilters) ...[
            const SizedBox(height: AppSpacing.xs),
            _buildActiveFiltersRow(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.md),
          Icon(
            Icons.search_rounded,
            color: AppColors.textTertiary,
            size: AppSpacing.iconMd,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: widget.onQueryChanged,
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: AppStrings.searchByNameOrLocation,
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),
          
          // Filter button
          _buildFilterButton(),
          
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: () => setState(() => _showFilters = !_showFilters),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: _showFilters || _hasActiveFilters
              ? AppColors.slate900
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 18,
              color: _showFilters || _hasActiveFilters
                  ? AppColors.textInverse
                  : AppColors.textSecondary,
            ),
            if (_hasActiveFilters) ...[
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.green500,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category chips
        Text(
          AppStrings.filterByCategory,
          style: AppTypography.labelMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            _FilterChip(
              label: AppStrings.allCategories,
              isSelected: _selectedCategory == null,
              onTap: () {
                setState(() => _selectedCategory = null);
                widget.onCategoryChanged?.call(null);
              },
            ),
            ...ProjectCategory.values.map((cat) => _FilterChip(
              label: cat.label,
              isSelected: _selectedCategory == cat,
              onTap: () {
                setState(() => _selectedCategory = cat);
                widget.onCategoryChanged?.call(cat);
              },
            )),
          ],
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Status chips
        Text(
          AppStrings.filterByStatus,
          style: AppTypography.labelMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            _FilterChip(
              label: AppStrings.allStatuses,
              isSelected: _selectedStatus == null,
              onTap: () {
                setState(() => _selectedStatus = null);
                widget.onStatusChanged?.call(null);
              },
            ),
            ...ProjectStatus.values.map((status) => _FilterChip(
              label: status.label,
              isSelected: _selectedStatus == status,
              onTap: () {
                setState(() => _selectedStatus = status);
                widget.onStatusChanged?.call(status);
              },
            )),
          ],
        ),
        
        if (_hasActiveFilters) ...[
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: _clearFilters,
            child: Text(
              AppStrings.clear,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.red600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActiveFiltersRow() {
    return Row(
      children: [
        Icon(
          Icons.filter_list_rounded,
          size: 14,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: AppSpacing.xxs),
        Expanded(
          child: Text(
            _getActiveFiltersText(),
            style: AppTypography.captionMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        GestureDetector(
          onTap: _clearFilters,
          child: Icon(
            Icons.close_rounded,
            size: 16,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  String _getActiveFiltersText() {
    final parts = <String>[];
    if (_searchController.text.isNotEmpty) {
      parts.add('"${_searchController.text}"');
    }
    if (_selectedCategory != null) {
      parts.add(_selectedCategory!.label);
    }
    if (_selectedStatus != null) {
      parts.add(_selectedStatus!.label);
    }
    return parts.join(' · ');
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.slate900 : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.slate900 : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? AppColors.textInverse : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
