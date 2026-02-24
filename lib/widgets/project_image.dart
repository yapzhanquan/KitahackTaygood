import 'package:flutter/material.dart';

class ProjectImage extends StatelessWidget {
  final String path; // can be asset path or  url
  final double height;
  final BorderRadius borderRadius;

  const ProjectImage({
    super.key,
    required this.path,
    this.height = 170,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(18)),
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = path.trim();
    final hasImage = trimmed.isNotEmpty;
    final isNetwork = trimmed.startsWith('http');

    if (!hasImage) {
      return SizedBox(height: height, width: double.infinity);
    }

    final image = isNetwork
        ? Image.network(
            trimmed,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                SizedBox(height: height, width: double.infinity),
          )
        : Image.asset(
            trimmed,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                SizedBox(height: height, width: double.infinity),
          );

    return ClipRRect(
      borderRadius: borderRadius,
      child: image,
    );
  }
}