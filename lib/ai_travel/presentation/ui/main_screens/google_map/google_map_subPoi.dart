import 'dart:async';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/theme/app_theme.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/core/utils/extensions.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/model/GroqModel.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/model/MultiPlaceModel.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/providers/connection_providers.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/widgets/app_bar.dart';
import 'package:geocoding/geocoding.dart';

import '../../../../core/utils/constants.dart';
import '../../../../domain/ssh/SSH.dart';

class GoogleMapScreen extends ConsumerStatefulWidget {
  final Places place;
  const GoogleMapScreen({super.key, required this.place});

  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}


class _GoogleMapScreenState extends ConsumerState<GoogleMapScreen> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  bool isPlaying = false;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(0, 0),
    zoom: 0,
  );

  int _currentPlaceIndex = 0;
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    print('Place: ${widget.place.name}');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goToTheNextDescription() {
    if (widget.place.description != null && widget.place.description!.isNotEmpty) {
      setState(() {
        String firstDescription = widget.place.description!.removeAt(0);
        widget.place.description!.add(firstDescription);
        listKey.currentState?.removeItem(
          0,
              (context, animation) => _buildItem(context, 0, firstDescription, animation),
        );
        listKey.currentState?.insertItem(widget.place.description!.length - 1);
      });
    }
  }

  void _goToThePreviousDescription() {
    if (widget.place.description != null && widget.place.description!.isNotEmpty) {
      setState(() {
        String lastDescription = widget.place.description!.removeLast();
        widget.place.description!.insert(0, lastDescription);
        listKey.currentState?.insertItem(0);
        listKey.currentState?.removeItem(
          widget.place.description!.length - 1,
              (context, animation) => _buildItem(context, widget.place.description!.length - 1, lastDescription, animation),
        );
      });
    }
  }

  void _toggleTour() {
    setState(() {
      isPlaying = !isPlaying;
    });

    if (isPlaying) {

      _startTour();
    } else {
      _timer?.cancel();
    }
  }

  void _startTour() {
    _showChatResponse(widget.place);
    _timer = Timer.periodic(Duration(seconds: 12), (Timer timer) async {
      final GoogleMapController controller = await _controller.future;
      if (_currentPlaceIndex >= widget.place.description!.length) {
        _currentPlaceIndex = 0;
        setState(() {
          isPlaying = false;
        });
        timer.cancel();
      } else {
        /*_loadChatResponses(widget.place);*/
        LatLng target = await _getLatLngForPlace(widget.place.name![_currentPlaceIndex], widget.place.address![_currentPlaceIndex]);
        _goToTheNextDescription();
        controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: target,
            zoom: 19.151926040649414,
            tilt: 59.440717697143555,
            bearing: 192.8334901395799,
          ),
        ));
        _currentPlaceIndex++;
      }
    });
  }


  Future<LatLng> _getLatLngForPlace(String place, String address) async {
    print("thisIsPlace: $place $address");
    List<Location> latlng = await locationFromAddress("$place $address");
    if (latlng.isNotEmpty) {
      return LatLng(latlng[0].latitude!, latlng[0].longitude!);
    }
    return const LatLng(0, 0);
  }

  Widget _buildItem(BuildContext context, int index, String item, Animation<double> animation) {
    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(
          begin: Offset(1, 0),
          end: Offset(0, 0),
        ).chain(CurveTween(curve: Curves.easeInOut)),
      ),
      child: ListTile(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: CircularWidget(
                color: index == 0 ? Colors.green : Colors.white,
              ),
            ),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 16, // Responsive text size
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth * 0.3;

    return Scaffold(
      appBar: CustomAppBar(isHomePage: false,),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.satellite,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            width: containerWidth,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16, bottom: 32),
              child: Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Sub - POIs',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(Iconsax.speaker, color: Colors.white),
                        Spacer(),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _goToThePreviousDescription,
                              child: Icon(Iconsax.previous, color: Colors.white),
                            ),
                            SizedBox(width: 10),
                            Icon(Iconsax.play_circle, color: Colors.white),
                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: _goToTheNextDescription,
                              child: Icon(Iconsax.next, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(),
                    Expanded(
                      child: AnimatedList(
                        key: listKey,
                        initialItemCount: widget.place.description?.length ?? 0,
                        itemBuilder: (context, index, animation) {
                          return _buildItem(context, index, widget.place.description![index], animation);
                        },
                      ),
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: screenWidth * 0.3,
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: _goToThePreviousDescription,
                      child: Icon(Iconsax.previous, color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: _toggleTour,
                      child: isPlaying
                          ? Icon(Iconsax.pause_circle, color: Colors.white, size: 50)
                          : Icon(Iconsax.play_circle, color: Colors.white, size: 50),
                    ),
                    GestureDetector(
                      onTap: _goToTheNextDescription,
                      child: Icon(Iconsax.next, color: Colors.white),
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

  Future<void> _navigate(String location) async {
    SSHSession? session = await SSH(ref: ref).search("$location");
    if (session != null) {
      print(session.stdout);
    }
  }

  Future<void> _flyTo(double latitude, double longitude, double zoom, double tilt, double bearing) async{
    SSHSession? session = await SSH(ref: ref).flyToOrbit(context, latitude, longitude, zoom, tilt, bearing);
    if (session != null) {
      print("flyTo ${session.stdout}");
    }
  }

  //define startOrbit
  Future<void> _startOrbit(double latitude, double longitude, double zoom, double tilt, double bearing) async{
    await Future.delayed(const Duration(milliseconds: 1000));
    for (int i = 0; i <= 360; i += 10) {
      if (!mounted) {
        return;
      }
      SSH(ref: ref).flyToOrbit(
          context,
          latitude,
          longitude,
          Const.orbitZoomScale.zoomLG,
          60,
          i.toDouble());
      await Future.delayed(const Duration(milliseconds: 1000));
    }

  }



  void _showChatResponse(Places places) async {
    List<Location> latLng = [];
    for (int i = 0; i < places.name!.length; i++) {
      latLng = await locationFromAddress("${places.name![i]}, ${places.address![i]}");
      if (latLng.isNotEmpty) {
        print("Lat and Lng ${latLng[0].latitude} ${latLng[0].longitude} ");
        await SSH(ref: ref).setRefresh(context);
       /* await SSH(ref: ref).cleanSlaves(context);
        await SSH(ref: ref).cleanBalloon(context);*/
        await SSH(ref: ref).chatResponseBalloon(places.description![i], LatLng(latLng[0].latitude, latLng[0].longitude),places.name![i],"${places.name![i]} is a ${places.description![i]}");
        print("Showing chat response for ${places.name![i]} at ${places.address![i]}");
        _flyTo(latLng[0].latitude,latLng[0].longitude,150, 60, 0);
        /*_navigate("${latLng[0].latitude}, ${latLng[0].longitude}");*/
      } else {
        print("No coordinates found for ${places.name![i]}");
      }
      await Future.delayed(const Duration(seconds: 12));
    }
    latLng.clear();
   /* await SSH(ref: ref).cleanBalloon(context);
    await SSH(ref: ref).cleanSlaves(context);*/
    await SSH(ref: ref).setRefresh(context);
  }


}







class CircularWidget extends StatelessWidget {
  final Color color;
  const CircularWidget({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      width: 15,
      height: 15,
      decoration:  BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

