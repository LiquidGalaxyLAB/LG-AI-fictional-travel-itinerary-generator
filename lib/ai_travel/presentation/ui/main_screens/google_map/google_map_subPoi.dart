import 'dart:async';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/string/String.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/theme/app_theme.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/core/utils/extensions.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/model/GroqModel.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/model/MultiPlaceModel.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/model/WeatherModal.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/service/mapService.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/providers/connection_providers.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/ui/use_case/MapUseCase.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/widgets/app_bar.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../data/model/SubPoiInfoModal.dart';
import '../../../../core/utils/constants.dart';
import '../../../../data/model/TimeZoneModal.dart';
import '../../../../data/model/test.dart';
import '../../../../domain/ssh/SSH.dart';
import '../../../../injection_container.dart';
import '../../use_case/MiscUseCase.dart';
import '../../use_case/api_use_case.dart';

class GoogleMapScreen extends ConsumerStatefulWidget {
  final Places place;

  const GoogleMapScreen({super.key, required this.place});

  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends ConsumerState<GoogleMapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  bool isPlaying = false;
  final tourIndex = 0;
  SubPoiInfoModal? subPoiInfo;
  WeatherModal? subPoiTemp;
  TimeZoneModal? subPoiTimeZone;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(0, 0),
    zoom: 0,
  );
  bool _isLoading = true;
  int _currentPlaceIndex = 0;
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      _getSubPoiInfo();
    });

  }

  void _getSubPoiInfo() async {
    final newSubPoiInfo = await getSubPoiInfo("${widget.place.name![_currentPlaceIndex]}, ${widget.place.address![_currentPlaceIndex]}");
    setState(() {
      subPoiInfo = newSubPoiInfo;
      double? latitude = subPoiInfo?.places?[0].viewport?.low?.latitude;
      double? longitude = subPoiInfo?.places?[0].viewport?.low?.longitude;
      if (latitude != null && longitude != null) {
        _isLoading = false;
        print('${latitude} ${longitude} and Longitude is not null');
        _getTemp();
      } else {
        _isLoading = true;
        print('Latitude or Longitude is null');
      }
    });
    changeMapPosition();
  }

  String getWeatherForecastLink(String id){
    return "https://openweathermap.org/img/wn/${id}@2x.png";
  }

  void _getTemp() async{
    double? latitude = subPoiInfo?.places?[0].viewport?.low?.latitude;
    double? longitude = subPoiInfo?.places?[0].viewport?.low?.longitude;
    final newSubPoiTemp = await getWeatherInfo(latitude!,longitude!);
    final newSubPoiTimeZone = await getTimeZone(latitude, longitude);
    if (latitude != null && longitude != null) {
      setState(() {
        subPoiTemp = newSubPoiTemp;
        subPoiTimeZone = newSubPoiTimeZone;
        print("Temp is ${subPoiTimeZone?.timeZone}");
      });
    } else {
      print('Latitude or Longitude is null');
    }
  }
  double kelvinToCelsius(double kelvin) {
    return kelvin - 273.15;
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goToTheNextDescription() async {
    _getSubPoiInfo();
    if (widget.place.description != null &&
        widget.place.description!.isNotEmpty) {
      setState(() {
        String firstDescription = widget.place.description!.removeAt(0);
        String firstName = widget.place.name!.removeAt(0);
        String firstAddress = widget.place.address!.removeAt(0);
        widget.place.description!.add(firstDescription);
        widget.place.name!.add(firstName);
        widget.place.address!.add(firstAddress);
      });
    }
    changeMapPosition();
    setState(() {
      if (_currentPlaceIndex < (widget.place.description?.length ?? 0) - 1) {
        _currentPlaceIndex++;
      } else {
        _currentPlaceIndex = 0;
      }
    });
  }

  void _goToThePreviousDescription() async {
    _getSubPoiInfo();
    setState(() {
      String lastDescription = widget.place.description!.removeLast();
      String lastName = widget.place.name!.removeLast();
      String lastAddress = widget.place.address!.removeLast();
      widget.place.description!.insert(0, lastDescription);
      widget.place.name!.insert(0, lastName);
      widget.place.address!.insert(0, lastAddress);
    });
    changeMapPosition();
    setState(() {
      if (_currentPlaceIndex > 0) {
        _currentPlaceIndex--;
      }
    });
  }

  void changeMapPosition() async {
    final GoogleMapController controller = await _controller.future;
    if (widget.place.description != null &&
        widget.place.description!.isNotEmpty) {
      LatLng target = await _getLatLngForPlace(
          widget.place.name![_currentPlaceIndex],
          widget.place.address![_currentPlaceIndex]);
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: 19.151926040649414,
          tilt: 59.440717697143555,
          bearing: 192.8334901395799,
        ),
      ));
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
        LatLng target = await _getLatLngForPlace(
            widget.place.name![_currentPlaceIndex],
            widget.place.address![_currentPlaceIndex]);
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

  Future<SubPoiInfoModal?> getSubPoiInfo(String query) async {
    try {
      print("Query is $query");
      final useCase = sl.get<MapUseCase>();
      return await useCase.getSubPoiInfo(query);
    } catch (e) {
      print("subPoiInfo is $e");
      return null;
    }
  }

  Future<WeatherModal?> getWeatherInfo(double latitude, double longitude) async {
    try {
      final useCase = sl.get<MiscUseCase>();
      return await useCase.getWeatherInfo(latitude, longitude);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<TimeZoneModal?> getTimeZone(double latitude, double longitude) async {
    try {
      final useCase = sl.get<MiscUseCase>();
      return await useCase.getTimeZoneInfo(latitude, longitude);
    } catch (e) {
      print(e);
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth * 0.4; // Adjusted for 4:6 ratio
    final isLoading = subPoiInfo == null ||
        subPoiInfo!.places == null ||
        subPoiInfo!.places!.isEmpty ||
        subPoiInfo!.places![0].googleMapsUri == null;
    return Scaffold(
      appBar: CustomAppBar(isHomePage: false),
      body: Row(
        children: <Widget>[
          Expanded(
            flex: 6, // 40% of the width
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 0),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.place.name![_currentPlaceIndex],
                                    style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text(
                                    '${widget.place.address![_currentPlaceIndex]}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 28),
                        isLoading
                            ? Center(child: CircularProgressIndicator())
                            : Column(
                          children: [
                            Row(
                              children: [
                                _buildInfoItem(
                                  "${subPoiTemp?.sys?.country}",
                                  Icon(Iconsax.direct_up, color: Colors.white),
                                ),
                                SizedBox(width: 70),
                                _buildTempInfoItem(
                                  '${kelvinToCelsius(subPoiTemp?.main?.temp ?? 0).toStringAsFixed(2)}°C',
                                  getWeatherForecastLink(subPoiTemp?.weather?[0].icon ?? "01d"),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _buildInfoItem(
                                  "${subPoiInfo!.places![0].rating}",
                                  Icon(Icons.star, color: Colors.grey,),
                                ),

                              ],
                            ),
                            SizedBox(height: 10),
                            _buildInfoItem(
                              "${subPoiTimeZone?.timeZone}",
                              Icon(Iconsax.global, color: Colors.white),
                            ),
                            SizedBox(height: 10),
                            SizedBox(height: 28),
                          ],
                        ),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      Strings.description,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(),
                                Text(
                                  widget.place.description![_currentPlaceIndex],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      Strings.reviews,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(),
                                const SizedBox(height: 10),
                        _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: (2 / 2).ceil(),
                          itemBuilder: (context, index) {
                            // Fetch the review or use default values if null
                            var review = subPoiInfo?.places?.firstOrNull?.reviews?.elementAtOrNull(index);
                            var author = review?.authorAttribution?.displayName ?? "Unable to load";
                            var rating = review?.rating?.toString() ?? "0";
                            var reviewText = review?.text?.text ?? "Unable to load";
                            var secondReview = subPoiInfo?.places?.firstOrNull?.reviews?.elementAtOrNull(index + 1);
                            var secondAuthor = secondReview?.authorAttribution?.displayName ?? "Unable to load";
                            var secondRating = secondReview?.rating?.toString() ?? "0";
                            var secondReviewText = secondReview?.text?.text ?? "Unable to load";


                            return Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.all(8.0),
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundColor,
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              author,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '$rating',
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 2),
                                            Icon(
                                              Icons.star,
                                              color: Colors.yellowAccent.shade100,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          reviewText,
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                          maxLines: 6,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if ((index * 2 + 1) < 2)
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.all(8.0),
                                      padding: const EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundColor,
                                        borderRadius: BorderRadius.circular(10.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                secondAuthor,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '$secondRating',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Icon(
                                                Icons.star,
                                                color: Colors.yellowAccent.shade100,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            secondReviewText, // You may want to use another review for the second container
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                            maxLines: 6,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Constant Container at the bottom
                  Container(
                    padding: const EdgeInsets.only(
                        left: 16, top: 8.0, bottom: 8, right: 8.0),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xff9D9BB1),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _currentPlaceIndex > 0
                              ? _goToThePreviousDescription
                              : null,
                          child: Icon(
                            Icons.skip_previous,
                            color: _currentPlaceIndex > 0
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            size: 40,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Text(
                            '${_currentPlaceIndex + 1}/${widget.place.description?.length}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: _currentPlaceIndex <
                                  (widget.place.description?.length ?? 0) - 1
                              ? _goToTheNextDescription
                              : null,
                          child: Icon(
                            Icons.skip_next,
                            color: _currentPlaceIndex <
                                    (widget.place.description?.length ?? 0) - 1
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      child: Container(
                        color: Colors.black,
                        child: GoogleMap(
                          mapType: MapType.satellite,
                          initialCameraPosition: _kGooglePlex,
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 4, // 40% of the height
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        border: Border.all(
                          width: 2.0,
                          style: BorderStyle.solid,
                          color: Colors.transparent,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF817CC9),
                            Colors.transparent,
                            Colors.transparent,
                            Color(0xFF817CC9)
                          ],
                          stops: [0.0, 0.3, 0.7, 1.0],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 10),
                                _roundedBtn("Start Auto Touring", () {},
                                    Icon(Iconsax.play, color: Colors.white)),
                                const SizedBox(height: 24),
                                Opacity(
                                  opacity:
                                      ref.watch(connectedProvider) ? 1.0 : 0.6,
                                  child: _roundedBtn(
                                    "Play Orbit",
                                    () {}, //define the functionaslity
                                    Icon(Iconsax.play, color: Colors.white),
                                  ),
                                ),
                                ref.watch(connectedProvider)
                                    ? const SizedBox
                                        .shrink() // This will render an empty widget when connected
                                    : const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.info,
                                              color: Colors.grey,
                                              size: 20,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              "Connect with LG Rigs to use this feature",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                                color: Colors
                                                    .white, // Set text color to match the icon
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoItem(String? title, Icon icon) {
    return title == null || title.isEmpty || title == "null"
        ? Container(
      width: 24, // Adjust as needed
      height: 24, // Adjust as needed
      child: Center(child: CircularProgressIndicator()),
    )
        : Row(
      children: [
        icon,
        SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTempInfoItem(String temperature, String iconUrl) {
    return Row(
      children: [
        Image.network(
          iconUrl,
          width: 48.0,
          height: 48.0,
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            } else {
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            }
          },
          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
            return Icon(Icons.error, color: Colors.grey);
          },
        ),
        Text(temperature, style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _roundedBtn(String title, Function() onTap, Icon icon) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.tertiaryColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title aligned to the left
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Icon aligned to the right
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: icon,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _flyTo(double latitude, double longitude, double zoom,
      double tilt, double bearing) async {
    SSHSession? session = await SSH(ref: ref)
        .flyToOrbit(context, latitude, longitude, zoom, tilt, bearing);
    if (session != null) {
      print("flyTo ${session.stdout}");
    }
  }

  //define startOrbit
  Future<void> _startOrbit(double latitude, double longitude, double zoom,
      double tilt, double bearing) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    for (int i = 0; i <= 360; i += 10) {
      if (!mounted) {
        return;
      }
      SSH(ref: ref).flyToOrbit(context, latitude, longitude,
          Const.orbitZoomScale.zoomLG, 60, i.toDouble());
      await Future.delayed(const Duration(milliseconds: 1000));
    }
  }

  void _showChatResponse(Places places) async {
    List<Location> latLng = [];
    List<Map<String, double>> cords = [];
    for (int i = 0; i < places.name!.length; i++) {
      latLng = await locationFromAddress(
          "${places.name![i]}, ${places.address![i]}");
      if (latLng.isNotEmpty) {
        print("Lat and Lng ${latLng[0].latitude} ${latLng[0].longitude} ");
        await SSH(ref: ref).setRefresh(context);
        /* await SSH(ref: ref).cleanSlaves(context);
        await SSH(ref: ref).cleanBalloon(context);*/
        await SSH(ref: ref).chatResponseBalloon(
            places.description![i],
            LatLng(latLng[0].latitude, latLng[0].longitude),
            places.name![i],
            "${places.name![i]} is a ${places.description![i]}");
        print(
            "Showing chat response for ${places.name![i]} at ${places.address![i]}");
        _flyTo(latLng[0].latitude, latLng[0].longitude, 150, 60, 0);
        /*_navigate("${latLng[0].latitude}, ${latLng[0].longitude}");*/
      } else {
        print("No coordinates found for ${places.name![i]}");
      }
      await Future.delayed(const Duration(seconds: 12));
    }
    cords.clear();
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
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
