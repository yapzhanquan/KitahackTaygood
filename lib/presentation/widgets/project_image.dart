import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/project_model.dart';

/// Shared project image renderer so all surfaces use the same source.
class ProjectImage extends StatelessWidget {
  final Project project;
  final BoxFit fit;
  final double radius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ProjectImage({
    super.key,
    required this.project,
    this.fit = BoxFit.cover,
    this.radius = 0,
    this.placeholder,
    this.errorWidget,
  });

  static bool _isAssetPath(String path) => path.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    final imagePath = project.imageUrl;

    Widget image;
    if (_isAssetPath(imagePath)) {
      image = Image.asset(
        imagePath,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? const SizedBox.shrink(),
      );
    } else {
      image = CachedNetworkImage(
        imageUrl: imagePath,
        fit: fit,
        placeholder: (context, url) => placeholder ?? const SizedBox.shrink(),
        errorWidget: (context, url, error) =>
            errorWidget ?? const SizedBox.shrink(),
      );
    }

    if (radius <= 0) {
      return image;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: image,
    );
  }
}
