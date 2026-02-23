import 'package:flutter/material.dart';
import '../models/project_model.dart';

class ConfidenceBadge extends StatelessWidget {
  final ConfidenceLevel confidence;
  final double fontSize;

  const ConfidenceBadge({
    super.key,
    required this.confidence,
    this.fontSize = 10,
  });

  Color get _backgroundColor {
    switch (confidence) {
      case ConfidenceLevel.high:
        return const Color(0xFF1A1A2E).withValues(alpha: 0.85);
      case ConfidenceLevel.medium:
        return const Color(0xFF475569).withValues(alpha: 0.85);
      case ConfidenceLevel.low:
        return const Color(0xFF94A3B8).withValues(alpha: 0.85);
    }
  }

  IconData get _icon {
    switch (confidence) {
      case ConfidenceLevel.high:
        return Icons.verified_rounded;
      case ConfidenceLevel.medium:
        return Icons.info_outline_rounded;
      case ConfidenceLevel.low:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            confidence.label,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
