import 'package:flutter/material.dart';
import '../models/project_model.dart';

class HeroSearchBar extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final ValueChanged<String>? onQueryChanged;
  final ValueChanged<ProjectCategory?>? onCategoryChanged;
  final ValueChanged<ProjectStatus?>? onStatusChanged;

  const HeroSearchBar({
    super.key,
    this.onSearchTap,
    this.onQueryChanged,
    this.onCategoryChanged,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _SearchSegment(
              label: 'Where',
              hint: 'Search by area',
              showDivider: true,
              onTap: () => _showLocationSearch(context),
            ),
          ),
          Expanded(
            flex: 3,
            child: _SearchSegment(
              label: 'Category',
              hint: 'Any category',
              showDivider: true,
              onTap: () => _showCategoryPicker(context),
            ),
          ),
          Expanded(
            flex: 3,
            child: _SearchSegment(
              label: 'Status',
              hint: 'Any status',
              showDivider: false,
              onTap: () => _showStatusPicker(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: onSearchTap,
              child: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A2E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LocationSearchSheet(
        onChanged: onQueryChanged,
      ),
    );
  }

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PickerSheet<ProjectCategory?>(
        title: 'Select Category',
        items: [null, ...ProjectCategory.values],
        labelBuilder: (c) => c?.label ?? 'All Categories',
        onSelected: (c) {
          onCategoryChanged?.call(c);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showStatusPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PickerSheet<ProjectStatus?>(
        title: 'Select Status',
        items: [null, ...ProjectStatus.values],
        labelBuilder: (s) => s?.label ?? 'All Statuses',
        onSelected: (s) {
          onStatusChanged?.call(s);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _SearchSegment extends StatelessWidget {
  final String label;
  final String hint;
  final bool showDivider;
  final VoidCallback? onTap;

  const _SearchSegment({
    required this.label,
    required this.hint,
    required this.showDivider,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(
                  right: BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              hint,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationSearchSheet extends StatelessWidget {
  final ValueChanged<String>? onChanged;

  const _LocationSearchSheet({this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              'Search by area',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              autofocus: true,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'e.g. Petaling Jaya, Kuala Lumpur...',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SuggestionTile(
            icon: Icons.near_me_rounded,
            title: 'Nearby',
            subtitle: 'Find projects around you',
            onTap: () {
              onChanged?.call('');
              Navigator.pop(context);
            },
          ),
          _SuggestionTile(
            icon: Icons.location_city_rounded,
            title: 'Kuala Lumpur',
            subtitle: 'Federal capital',
            onTap: () {
              onChanged?.call('Kuala Lumpur');
              Navigator.pop(context);
            },
          ),
          _SuggestionTile(
            icon: Icons.location_city_rounded,
            title: 'Petaling Jaya',
            subtitle: 'Selangor',
            onTap: () {
              onChanged?.call('Petaling Jaya');
              Navigator.pop(context);
            },
          ),
          _SuggestionTile(
            icon: Icons.location_city_rounded,
            title: 'Johor Bahru',
            subtitle: 'Johor',
            onTap: () {
              onChanged?.call('Johor Bahru');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SuggestionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF1A1A2E), size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
      ),
      onTap: onTap,
    );
  }
}

class _PickerSheet<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onSelected;

  const _PickerSheet({
    required this.title,
    required this.items,
    required this.labelBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          ...items.map(
            (item) => ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
              title: Text(
                labelBuilder(item),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () => onSelected(item),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
