import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_colors.dart';

/// MapService - Centralized Google Maps configuration
/// Provides Silver/Minimal style to match Slate/Blue-grey palette
class MapService {
  MapService._();

  /// Silver map style JSON - removes colorful default styling
  /// Matches the Slate/Blue-grey design system
  static const String silverMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#f5f5f5"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#616161"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#f5f5f5"}]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#bdbdbd"}]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [{"color": "#eeeeee"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [{"color": "#e5e5e5"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#9e9e9e"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#ffffff"}]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#dadada"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#616161"}]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#9e9e9e"}]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [{"color": "#e5e5e5"}]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [{"color": "#eeeeee"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#c9c9c9"}]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#9e9e9e"}]
  }
]
''';

  /// Default camera position for Malaysia (KL)
  static const CameraPosition defaultMalaysiaPosition = CameraPosition(
    target: LatLng(3.1390, 101.6869),
    zoom: 12,
  );

  /// Create camera position from coordinates
  static CameraPosition getCameraPosition({
    required double latitude,
    required double longitude,
    double zoom = 15,
  }) {
    return CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: zoom,
    );
  }

  /// Create custom marker with Slate-900 styling
  static Future<BitmapDescriptor> getCustomMarker() async {
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
  }

  /// Create a set of markers for a project location
  static Set<Marker> createProjectMarker({
    required String markerId,
    required double latitude,
    required double longitude,
    String? title,
    String? snippet,
    VoidCallback? onTap,
  }) {
    return {
      Marker(
        markerId: MarkerId(markerId),
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(
          title: title ?? 'Project Location',
          snippet: snippet,
        ),
        onTap: onTap,
      ),
    };
  }
}

/// Map style presets
enum MapStylePreset {
  silver,
  dark,
  retro,
  standard,
}

extension MapStylePresetExtension on MapStylePreset {
  String? get styleJson {
    switch (this) {
      case MapStylePreset.silver:
        return MapService.silverMapStyle;
      case MapStylePreset.dark:
        return _darkMapStyle;
      case MapStylePreset.retro:
        return _retroMapStyle;
      case MapStylePreset.standard:
        return null;
    }
  }
}

const String _darkMapStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#212121"}]},
  {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#212121"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#2c2c2c"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#000000"}]}
]
''';

const String _retroMapStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#ebe3cd"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#523735"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#f5f1e6"}]},
  {"featureType": "water", "elementType": "geometry.fill", "stylers": [{"color": "#b9d3c2"}]}
]
''';
