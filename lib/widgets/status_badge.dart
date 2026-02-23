import 'package:flutter/material.dart';
import '../models/project_model.dart';

class StatusBadge extends StatelessWidget {
  final ProjectStatus status;
  final double fontSize;
  final EdgeInsets padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  Color get _backgroundColor {
    switch (status) {
      case ProjectStatus.active:
        return const Color(0xFF22C55E);
      case ProjectStatus.slowing:
        return const Color(0xFFEAB308);
      case ProjectStatus.stalled:
        return const Color(0xFFEF4444);
      case ProjectStatus.unverified:
        return const Color(0xFF9CA3AF);
    }
  }

  Color get _textColor {
    switch (status) {
      case ProjectStatus.active:
      case ProjectStatus.stalled:
        return Colors.white;
      case ProjectStatus.slowing:
        return const Color(0xFF713F12);
      case ProjectStatus.unverified:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: _textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
