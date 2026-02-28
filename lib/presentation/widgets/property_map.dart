import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/services/map_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// PropertyMap - Google Maps widget with Silver styling
/// Features:
/// - Real GoogleMap with Silver/Minimal style
/// - Custom Slate-themed marker
/// - Full-screen toggle button
/// - ClipRRect with 20px border radius
/// - Fallback for web without API key
class PropertyMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String? projectName;
  final double height;
  final bool showFullScreenButton;
  final VoidCallback? onFullScreenTap;

  const PropertyMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.projectName,
    this.height = 200,
    this.showFullScreenButton = true,
    this.onFullScreenTap,
  });

  @override
  State<PropertyMap> createState() => _PropertyMapState();
}

class _PropertyMapState extends State<PropertyMap> {
  GoogleMapController? _mapController;
  bool _mapReady = false;
  bool _mapError = false;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    // Apply Silver map style
    controller.setMapStyle(MapService.silverMapStyle).catchError((e) {
      debugPrint('Error setting map style: $e');
    });
    
    setState(() => _mapReady = true);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            // Google Map or Fallback
            _buildMapContent(),
            
            // Loading overlay
            if (!_mapReady && !_mapError)
              _buildLoadingOverlay(),
            
            // Full-screen button
            if (widget.showFullScreenButton)
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: _buildFullScreenButton(),
              ),
            
            // Coordinates badge
            Positioned(
              bottom: AppSpacing.sm,
              left: AppSpacing.sm,
              child: _buildCoordinatesBadge(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapContent() {
    // Use fallback on web if there's likely no API key configured
    if (kIsWeb || _mapError) {
      return _buildMinimalMapFallback();
    }

    return GoogleMap(
      initialCameraPosition: MapService.getCameraPosition(
        latitude: widget.latitude,
        longitude: widget.longitude,
        zoom: 15,
      ),
      onMapCreated: _onMapCreated,
      markers: MapService.createProjectMarker(
        markerId: 'project_location',
        latitude: widget.latitude,
        longitude: widget.longitude,
        title: widget.projectName,
        snippet: '${widget.latitude.toStringAsFixed(4)}, ${widget.longitude.toStringAsFixed(4)}',
      ),
      mapType: MapType.normal,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      buildingsEnabled: true,
      trafficEnabled: false,
      onTap: (_) {},
    );
  }

  Widget _buildMinimalMapFallback() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.slate100,
      ),
      child: Stack(
        children: [
          // Minimal map grid simulation (Silver style)
          CustomPaint(
            size: Size(double.infinity, widget.height),
            painter: _SilverMapPainter(),
          ),
          
          // Center marker
          Center(
            child: _buildCustomMarker(),
          ),
          
          // "Open in Maps" hint
          Positioned(
            bottom: AppSpacing.xl + 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.map_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tap to open in Maps',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomMarker() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.slate900,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate900.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.location_on_rounded,
        color: Colors.white,
        size: 22,
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: AppColors.slate100,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.slate500),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Loading map...',
              style: AppTypography.captionMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullScreenButton() {
    return GestureDetector(
      onTap: widget.onFullScreenTap ?? () => _showFullScreenMap(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.open_in_full_rounded,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoordinatesBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.pin_drop_outlined,
            size: 12,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.latitude.toStringAsFixed(4)}, ${widget.longitude.toStringAsFixed(4)}',
            style: AppTypography.captionMedium.copyWith(
              fontFamily: 'monospace',
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenMap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenMapPage(
          latitude: widget.latitude,
          longitude: widget.longitude,
          projectName: widget.projectName,
        ),
      ),
    );
  }
}

/// Full-screen map page
class FullScreenMapPage extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String? projectName;

  const FullScreenMapPage({
    super.key,
    required this.latitude,
    required this.longitude,
    this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          projectName ?? 'Location',
          style: AppTypography.headlineSmall,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PropertyMap(
        latitude: latitude,
        longitude: longitude,
        projectName: projectName,
        height: MediaQuery.of(context).size.height,
        showFullScreenButton: false,
      ),
    );
  }
}

/// Silver-style minimal map painter
class _SilverMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bgPaint = Paint()..color = const Color(0xFFF5F5F5);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Grid lines (roads)
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    final secondaryRoadPaint = Paint()
      ..color = const Color(0xFFE8E8E8)
      ..strokeWidth = 1;

    // Main roads (horizontal)
    for (var i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
    }

    // Main roads (vertical)
    for (var i = 1; i < 6; i++) {
      final x = size.width * i / 6;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadPaint);
    }

    // Secondary roads (grid)
    const spacing = 30.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), secondaryRoadPaint);
    }
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), secondaryRoadPaint);
    }

    // Building blocks (subtle gray rectangles)
    final buildingPaint = Paint()..color = const Color(0xFFEEEEEE);
    final random = [0.2, 0.4, 0.6, 0.8];
    for (var i = 0; i < 4; i++) {
      for (var j = 0; j < 3; j++) {
        final rect = Rect.fromLTWH(
          size.width * random[i] - 20,
          size.height * (j + 1) / 4 - 15,
          40 + (i * 5),
          30 + (j * 3),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(2)),
          buildingPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
