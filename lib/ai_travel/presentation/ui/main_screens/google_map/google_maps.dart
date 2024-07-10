import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/widgets/app_bar.dart';

class GoogleMapsPage extends StatelessWidget {
  const GoogleMapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(41.6177, 0.6200),
          zoom: 12,
        ),
        mapType: MapType.hybrid,
        markers: {
          const Marker(
            markerId: MarkerId('1'),
            position: LatLng(41.6177, 0.6200),
          ),
        },
      ),
    );
  }
}