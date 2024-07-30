import 'dart:math';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/widgets/app_bar.dart';

import '../../../../domain/ssh/SSH.dart';

class GoogleMapsPage extends ConsumerStatefulWidget {
  const GoogleMapsPage({super.key});

  @override
  _GoogleMapsPageState createState() => _GoogleMapsPageState();
}

class _GoogleMapsPageState extends ConsumerState<GoogleMapsPage> {
  double zoomvalue = 591657550.500000 / pow(2, 13.15393352508545);
  double latvalue = 41.6177;
  double longvalue =  0.6200;
  double tiltvalue = 41.82725143432617;
  double bearingvalue = 61.403038024902344; // 2D angle
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
        onCameraIdle: _onCameraIdle,
        onCameraMove: _onCameraMove,
      ),
    );
  }

  void _onCameraIdle() {
    _handleMapLgMotion();
  }

  Future<void> _handleMapLgMotion() async{
    SSHSession? session = await SSH(ref: ref).motionControls(latvalue, longvalue, zoomvalue / 3, tiltvalue, bearingvalue);
    if (session != null) {
      print(session.stdout);
    }
  }

  void _onCameraMove(CameraPosition position) {
    bearingvalue = position.bearing; // 2D angle
    longvalue = position.target.longitude; // lat lng
    latvalue = position.target.latitude;
    tiltvalue = position.tilt; // 3D angle
    zoomvalue = 591657550.500000 / pow(2, position.zoom);
  }
}