import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/project_model.dart';
import 'status_badge.dart';
import 'confidence_badge.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
  });

  Color get _categoryColor {
    switch (project.category) {
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

  IconData get _categoryIcon {
    switch (project.category) {
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: SizedBox(
                height: 170,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Placeholder gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _categoryColor.withValues(alpha: 0.15),
                            _categoryColor.withValues(alpha: 0.35),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _categoryIcon,
                          size: 56,
                          color: _categoryColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    // Bottom gradient overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.25),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Status badge top-left
                    Positioned(
                      top: 10,
                      left: 10,
                      child: StatusBadge(status: project.status),
                    ),
                    // Confidence badge top-right
                    Positioned(
                      top: 10,
                      right: 10,
                      child: ConfidenceBadge(confidence: project.confidence),
                    ),
                    // Bookmark icon
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bookmark_border_rounded,
                          size: 18,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info area
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          project.category.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _categoryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          project.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Verified ${DateFormat('MMM d, y').format(project.lastVerified)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
