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
import 'package:lg_ai_travel_itinerary/ai_travel/data/model/TravelDestinations.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/model/WeatherModal.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/service/mapService.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/providers/connection_providers.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/ui/use_case/MapUseCase.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/widgets/app_bar.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../core/kml/LookAt.dart';
import '../../../../core/kml/orbit.dart';
import '../../../../data/model/SubPoiInfoModal.dart';
import '../../../../core/utils/constants.dart';
import '../../../../data/model/TimeZoneModal.dart';
import '../../../../data/model/test.dart';
import '../../../../domain/ssh/SSH.dart';
import '../../../../injection_container.dart';
import '../../use_case/MiscUseCase.dart';
import '../../use_case/api_use_case.dart';

class GoogleMapScreen extends ConsumerStatefulWidget {
  final List<Destinations> destinations;
  final int selectedDestination;

  const GoogleMapScreen({
    super.key,
    required this.destinations,
    this.selectedDestination = 0,
  });

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
  List<Location?> _cords = [];
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
      if (widget.selectedDestination != 0) {
        setState(() {
          _currentPlaceIndex = widget.selectedDestination;
        });
      }
      _getSubPoiInfo();
      _showChatResponse(widget.destinations);
      print("currentIndex ${_currentPlaceIndex}");
    });
  }

  Future<void> _fetchCoordinates() async {
    var newLatLng = await locationFromAddress(
        "${widget.destinations[_currentPlaceIndex].name}, ${widget.destinations[_currentPlaceIndex].city}");
    setState(() {
      _cords = newLatLng;
    });
  }

  void _getSubPoiInfo() async {
    final newSubPoiInfo = await getSubPoiInfo(
        "${widget.destinations[_currentPlaceIndex].name!}, ${widget.destinations[_currentPlaceIndex].city!}");
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

  String getWeatherForecastLink(String id) {
    return "https://openweathermap.org/img/wn/${id}@2x.png";
  }

  void _getTemp() async {
    double? latitude = subPoiInfo?.places?[0].viewport?.low?.latitude;
    double? longitude = subPoiInfo?.places?[0].viewport?.low?.longitude;
    final newSubPoiTemp = await getWeatherInfo(latitude!, longitude!);
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

  String kelvinToCelsius(String kelvin) {
    if (kelvin == "0") {
      return "--";
    }
    return (double.parse(kelvin) - 273.15).toString();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goToTheNextDescription() async {
    _getSubPoiInfo();
    changeMapPosition();
    setState(() {
      if (_currentPlaceIndex < (widget.destinations.length ?? 0) - 1) {
        _currentPlaceIndex++;
      } else {
        _currentPlaceIndex = 0;
      }
      _showChatResponse(widget.destinations);
    });
  }

  void _goToThePreviousDescription() async {
    _getSubPoiInfo();
    changeMapPosition();

    setState(() {
      if (_currentPlaceIndex > 0) {
        _currentPlaceIndex--;
      }
    });
    _showChatResponse(widget.destinations);
  }

  void changeMapPosition() async {
    final GoogleMapController controller = await _controller.future;
    if (widget.destinations!.isNotEmpty) {
      print(
          "thisIsPlace: ${widget.destinations[_currentPlaceIndex].name!}, ${widget.destinations[_currentPlaceIndex].address!}");
      LatLng target = await _getLatLngForPlace(
          widget.destinations[_currentPlaceIndex].name!,
          widget.destinations[_currentPlaceIndex].city!);
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
    _showChatResponse(widget.destinations);
    _timer = Timer.periodic(Duration(seconds: 12), (Timer timer) async {
      final GoogleMapController controller = await _controller.future;
      if (_currentPlaceIndex >= widget.destinations.length) {
        _currentPlaceIndex = 0;
        setState(() {
          isPlaying = false;
        });
        timer.cancel();
      } else {
        /*_loadChatResponses(widget.destinations);*/
        LatLng target = await _getLatLngForPlace(
            widget.destinations[_currentPlaceIndex].name!,
            widget.destinations[_currentPlaceIndex].address!);
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

  Future<LatLng> _getLatLngForPlace(String destinations, String address) async {
    print("thisIsPlace: $destinations $address");
    List<Location> latlng = await locationFromAddress("$destinations $address");
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

  Future<WeatherModal?> getWeatherInfo(
      double latitude, double longitude) async {
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
    double latitude = subPoiInfo?.places?[0].viewport?.low?.latitude ?? 0;
    double longitude = subPoiInfo?.places?[0].viewport?.low?.longitude ?? 0;
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
                                    widget
                                        .destinations[_currentPlaceIndex].name!,
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
                                    '${widget.destinations[_currentPlaceIndex].address!}',
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
                                ? Center(child: Text("--"))
                                : Column(
                                    children: [
                                      Row(
                                        children: [
                                          _buildInfoItem(
                                            "${subPoiTemp?.sys?.country}",
                                            Icon(Iconsax.direct_up,
                                                color: Colors.white),
                                          ),
                                          SizedBox(width: 70),
                                          _buildTempInfoItem(
                                            subPoiTemp != null &&
                                                    subPoiTemp?.main != null &&
                                                    subPoiTemp?.main?.temp !=
                                                        null
                                                ? '${double.parse(kelvinToCelsius(subPoiTemp!.main!.temp.toString())).toStringAsFixed(2)}°C'
                                                : '--',
                                            getWeatherForecastLink(
                                                subPoiTemp?.weather?[0].icon ??
                                                    "--"),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          _buildInfoItem(
                                            "${subPoiInfo!.places![0].rating}",
                                            Icon(
                                              Icons.star,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      _buildInfoItem(
                                        "${subPoiTimeZone?.timeZone}",
                                        Icon(Iconsax.global,
                                            color: Colors.white),
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
                                  widget.destinations[_currentPlaceIndex]
                                      .description!,
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
                                    ? Center(child: Text("--"))
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: (2 / 2).ceil(),
                                        itemBuilder: (context, index) {
                                          // Fetch the review or use default values if null
                                          var review = subPoiInfo
                                              ?.places?.firstOrNull?.reviews
                                              ?.elementAtOrNull(index);
                                          var author = review?.authorAttribution
                                                  ?.displayName ??
                                              "Unable to load";
                                          var rating =
                                              review?.rating?.toString() ?? "0";
                                          var reviewText = review?.text?.text ??
                                              "Unable to load";
                                          var secondReview = subPoiInfo
                                              ?.places?.firstOrNull?.reviews
                                              ?.elementAtOrNull(index + 1);
                                          var secondAuthor = secondReview
                                                  ?.authorAttribution
                                                  ?.displayName ??
                                              "Unable to load";
                                          var secondRating = secondReview
                                                  ?.rating
                                                  ?.toString() ??
                                              "0";
                                          var secondReviewText =
                                              secondReview?.text?.text ??
                                                  "Unable to load";

                                          return Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.all(8.0),
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  decoration: BoxDecoration(
                                                    color: AppColors
                                                        .backgroundColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.5),
                                                        spreadRadius: 2,
                                                        blurRadius: 5,
                                                        offset: Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            author,
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 6),
                                                          Text(
                                                            '$rating',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 2),
                                                          Icon(
                                                            Icons.star,
                                                            color: Colors
                                                                .yellowAccent
                                                                .shade100,
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
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if ((index * 2 + 1) < 2)
                                                Expanded(
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12.0),
                                                    decoration: BoxDecoration(
                                                      color: AppColors
                                                          .backgroundColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.5),
                                                          spreadRadius: 2,
                                                          blurRadius: 5,
                                                          offset: Offset(0, 3),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              secondAuthor,
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 6),
                                                            Text(
                                                              '$secondRating',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 2),
                                                            Icon(
                                                              Icons.star,
                                                              color: Colors
                                                                  .yellowAccent
                                                                  .shade100,
                                                              size: 20,
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 8),
                                                        Text(
                                                          secondReviewText,
                                                          // You may want to use another review for the second container
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                          maxLines: 6,
                                                          overflow: TextOverflow
                                                              .ellipsis,
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
                            '${_currentPlaceIndex + 1}/${widget.destinations.length}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: _currentPlaceIndex <
                                  (widget.destinations.length ?? 0) - 1
                              ? _goToTheNextDescription
                              : null,
                          child: Icon(
                            Icons.skip_next,
                            color: _currentPlaceIndex <
                                    (widget.destinations.length ?? 0) - 1
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
                    child: Stack(
                      children: [
                        ClipRRect(
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
                        Positioned(
                          bottom: 16.0,
                          // Adjust the distance from the bottom as needed
                          left: 16.0,
                          // Adjust the distance from the left as needed
                          right: 16.0,
                          // Adjust the distance from the right as needed
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                /*const SizedBox(height: 10),
                                _roundedBtn("Start Auto Touring", () {},
                                    Icon(Iconsax.play, color: Colors.white)),*/
                                const SizedBox(height: 24),
                                Opacity(
                                  opacity:
                                      ref.watch(connectedProvider) ? 1.0 : 0.6,
                                  child: _cords != null
                                      ? ref.watch(isOrbitPlaying)
                                          ? _roundedBtn(
                                              "Stop Orbit",
                                              () {
                                                ref
                                                    .read(
                                                        isOrbitPlaying.notifier)
                                                    .state = false;
                                                SSH(ref: ref)
                                                    .stopOrbit(context);
                                                // _flyTo(_cords![0]!.latitude, _cords![0]!.longitude, 100, 60, 0);
                                              },
                                              Icon(Iconsax.stop,
                                                  color: Colors.white),
                                            )
                                          : _roundedBtn(
                                              "Play Orbit",
                                              () {
                                                ref
                                                    .read(
                                                        isOrbitPlaying.notifier)
                                                    .state = true;
                                                /*SSH.orbitAround(
                                                  LatLng(
                                                      _cords![0]!.latitude,
                                                      _cords![0]!.longitude),
                                                  );*/
                                                _startOrbit(
                                                    _cords![0]!.latitude,
                                                    _cords![0]!.longitude,
                                                    200,
                                                    60,
                                                    0);
                                              },
                                              Icon(Iconsax.play,
                                                  color: Colors.white),
                                            )
                                      : CircularProgressIndicator(), // Show a loading indicator while fetching coordinates
                                ),
                                ref.watch(connectedProvider)
                                    ? const SizedBox.shrink()
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
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 6, // 40% of the height
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                             Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 10.0, top: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Explore the places: ",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.onBackgroundColor,
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "${ref.read(currentAiModelSelected)}",
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(10.0),
                                child: ListView.builder(
                                  itemCount: widget.destinations.length,
                                  itemBuilder: (context, index) {
                                    final place = widget.destinations[index];
                                    return Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: 4.0), // Space between items
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.white, // Border color
                                          width: 1.0, // Border width
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            8.0), // Border radius
                                      ),
                                      child: Stack(
                                        children: [
                                          ListTile(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 10.0),
                                            // Padding inside the ListTile
                                            title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        place.name,
                                                        // Display place name
                                                        style: const TextStyle(
                                                          fontSize: 18.0,
                                                          color: Colors.white,
                                                          // Adjust color as needed
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis, // Add ellipsis if text overflows
                                                      ),
                                                      Text(
                                                        place.description,
                                                        // Display place address
                                                        style: const TextStyle(
                                                          fontSize: 14.0,
                                                          color: Colors
                                                              .white, // Adjust color as needed
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis, // Add ellipsis if text overflows
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Icon(
                                                  _currentPlaceIndex == index
                                                      ? Icons
                                                          .pause_circle // Pause icon
                                                      : Icons.play_circle,
                                                  // Play icon
                                                  color: Colors
                                                      .white, // Icon color
                                                )
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _currentPlaceIndex = index;
                                              });
                                              _getSubPoiInfo();
                                              changeMapPosition();
                                              _showChatResponse(
                                                  widget.destinations);
                                            },
                                            child: Container(
                                              color: Colors.transparent,
                                              // Transparent color to allow interaction
                                              height:
                                                  60.0, // Adjust height as needed
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        )),
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
            child: Center(child: Text("--")),
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
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            } else {
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            }
          },
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) {
            return Icon(Icons.downloading, color: Colors.grey);
          },
        ),
        Text(temperature, style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _roundedBtn(String title, Function() onTap, Icon icon) {
    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: width * 0.12,
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
        ],
      ),
    );
  }

  Future<void> _flyTo(double latitude, double longitude, double zoom,
      double tilt, double bearing) async {
    await SSH(ref: ref)
        .flyToOrbit(context, latitude, longitude, zoom, tilt, bearing);
  }

  playOrbit(double longvalue, double latvalue) async {
    await SSH(ref: ref)
        .buildOrbit(Orbit.buildOrbit(Orbit.generateOrbitTag(LookAt(
            double.parse((longvalue).toStringAsFixed(2)),
            double.parse((latvalue).toStringAsFixed(2)),
            "30492.665945696469",
            "0",
            "0"))))
        .then((value) async {
      await SSH(ref: ref).startOrbit(context);
    });
  }

  Future<void> _startOrbit(double latitude, double longitude, double zoom,
      double tilt, double bearing) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final startTime = DateTime.now();

    for (int i = 0; i <= 360; i += 10) {
      if (!mounted || ref.read(isOrbitPlaying) == false) {
        ref.read(isOrbitPlaying.notifier).state = false;
        return;
      }

      if (DateTime.now().difference(startTime).inSeconds > 20) {
        ref.read(isOrbitPlaying.notifier).state = false;
        return;
      }

      ref.read(isOrbitPlaying.notifier).state = true;
      SSH(ref: ref).flyToOrbit(context, latitude, longitude, zoom, 60, i.toDouble());
      await Future.delayed(const Duration(milliseconds: 1000));
    }
  }

  void _showChatResponse(List<Destinations> places) async {
    List<Location> latLng = [];
    _fetchCoordinates();
    var currentPlace = places[_currentPlaceIndex];
    print(
        "ChatResponse: ${_currentPlaceIndex}. ${currentPlace.name}, ${currentPlace.address}");

    try {
      var newLatLng = await locationFromAddress(
          "${currentPlace.name}, ${currentPlace.city}");
      setState(() {
        latLng = newLatLng;
      });

      if (latLng.isNotEmpty) {
        // Debugging SSH commands
        await SSH(ref: ref).setRefresh(context);
        // await SSH(ref: ref).cleanSlaves(context);
        // await SSH(ref: ref).cleanBalloon(context);

        await _flyTo(latLng[0].latitude, latLng[0].longitude, 200, 60, 0);

        await SSH(ref: ref).chatResponseBalloon(
            currentPlace.description,
            LatLng(latLng[0].latitude, latLng[0].longitude),
            currentPlace.name,
            "${currentPlace.name!} is a ${currentPlace.address}");
      } else {
        print("No coordinates found for ${currentPlace.name}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }

    latLng.clear();

    // Debugging SSH commands
    await SSH(ref: ref).setRefresh(context);
    // await SSH(ref: ref).cleanBalloon(context);
    // await SSH(ref: ref).cleanSlaves(context);
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
