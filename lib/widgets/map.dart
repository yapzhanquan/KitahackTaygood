import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ProjekWatch Map")),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(3.1390, 101.6869), // KL coordinates
          zoom: 14,
        ),
        myLocationEnabled: true,
      ),
    );
  }
}