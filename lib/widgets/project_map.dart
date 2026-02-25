import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// A Google Map widget that displays a project location marker.
/// Falls back to a styled placeholder if Google Maps is not configured.
class ProjectMap extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String projectName;
  final double height;
  final VoidCallback? onExpand;

  const ProjectMap({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.projectName,
    this.height = 200,
    this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    // If Google Maps is not enabled, show the styled placeholder
    if (!AppConfig.googleMapsEnabled) {
      return _buildPlaceholder();
    }

    // Google Maps integration
    // NOTE: google_maps_flutter requires platform-specific setup:
    // - Android: API key in AndroidManifest.xml
    // - iOS: API key in AppDelegate.swift
    // When those are configured, set AppConfig.googleMapsEnabled = true
    // and uncomment the GoogleMap widget below.
    //
    // return SizedBox(
    //   height: height,
    //   child: ClipRRect(
    //     borderRadius: BorderRadius.circular(16),
    //     child: GoogleMap(
    //       initialCameraPosition: CameraPosition(
    //         target: LatLng(latitude, longitude),
    //         zoom: 15,
    //       ),
    //       markers: {
    //         Marker(
    //           markerId: MarkerId(projectName),
    //           position: LatLng(latitude, longitude),
    //           infoWindow: InfoWindow(title: projectName),
    //         ),
    //       },
    //       myLocationButtonEnabled: false,
    //       zoomControlsEnabled: false,
    //       mapToolbarEnabled: false,
    //     ),
    //   ),
    // );

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Map grid pattern background
          Positioned.fill(
            child: CustomPaint(
              painter: _MapGridPainter(),
            ),
          ),
          // Center pin
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A1A2E).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Expand button
          if (onExpand != null)
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: onExpand,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.open_in_full_rounded,
                      size: 18, color: Color(0xFF1A1A2E)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Subtle grid lines to make the placeholder look map-like.
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD1D5DB).withValues(alpha: 0.5)
      ..strokeWidth = 0.5;

    // Horizontal lines
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical lines
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
