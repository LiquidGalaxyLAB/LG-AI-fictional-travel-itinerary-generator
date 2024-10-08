import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/route/routes.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/model/MultiPlaceModel.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/model/TravelDestinations.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/ui/main_screens/google_map/google_map_subPoi.dart';

import '../../../config/string/String.dart';
import '../../../config/theme/app_theme.dart';
import '../../../domain/ssh/SSH.dart';
import '../../providers/connection_providers.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/destination_card.dart';
import 'home_page.dart';
class GeneratedSubPoiPage extends ConsumerStatefulWidget {

  final TravelDestinations travelDestinations;
  const GeneratedSubPoiPage({super.key, required this.travelDestinations}) ;


  @override
  _GeneratedSubPoiPageState createState() => _GeneratedSubPoiPageState();
}

class _GeneratedSubPoiPageState extends ConsumerState<GeneratedSubPoiPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double paddingValue = width * 0.2;
    return SafeArea(
      child: Scaffold(
        appBar: const CustomAppBar(),
        body: Stack(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(
                    top: 20, left: paddingValue, right: paddingValue, bottom: 20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: height * 0.8,
                        decoration: BoxDecoration(
                          color: AppColors.onBackgroundColor,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                height: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.asset(
                                      'assets/images/travelPhoto.jpg',
                                      // Replace with your image path
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.travelDestinations.title,
                                      style: const TextStyle(
                                        fontSize: 32.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: widget.travelDestinations.Dest!.asMap().entries.map((description) {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  SlidingPageRoute(
                                                    page: GoogleMapScreen(destinations: widget.travelDestinations.Dest, selectedDestination: description.key ),
                                                  ),
                                                ).then((_) {
                                                  Navigator.pushAndRemoveUntil(
                                                    context,
                                                    SlidingPageRoute(page: HomePage()),
                                                        (route) {
                                                      // Keep the route if it's the homePage route or if it's the root route
                                                      return route.settings.name == homePage || !Navigator.canPop(context);
                                                    },
                                                  );
                                                });
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Flexible(
                                                          child: Stack(
                                                            children: [
                                                              // Text widget for the actual text
                                                              Text(
                                                                "${description.value.name}",
                                                                style: const TextStyle(
                                                                  fontSize: 24.0,
                                                                  fontWeight: FontWeight.normal,
                                                                  color: Colors.white, // Text color
                                                                ),
                                                                overflow: TextOverflow.ellipsis,
                                                                maxLines: 1,
                                                              ),
                                                              // Positioned widget to create the underline
                                                              Positioned(
                                                                bottom: 0,
                                                                left: 0,
                                                                right: 0, // Add right: 0 to ensure it takes full width
                                                                child: Container(
                                                                  height: 2.0, // Thickness of the underline
                                                                  color: Colors.white, // Underline color
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(width: 5.0), // Adding some space between text and icon
                                                        const Icon(
                                                          Icons.play_circle,
                                                          color: Colors.white,
                                                          size: 24.0,
                                                        ),
                                                      ],
                                                    ),


                                                    const SizedBox(height: 10.0),
                                                    Text(
                                                      description.value.description,
                                                      style: const TextStyle(
                                                        fontSize: 18.0,
                                                        fontWeight: FontWeight.normal,
                                                      ),
                                                    ),
                                                  ],
                                                ),


                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    Container(
                                      alignment: Alignment.center,
                                      child: CustomButtonWidget(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            SlidingPageRoute(page: GoogleMapScreen(destinations: widget.travelDestinations.Dest)),
                                          ).then((_) {
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              SlidingPageRoute(page: HomePage()),
                                                  (route) {
                                                // Keep the route if it's the homePage route or if it's the root route
                                                return route.settings.name == homePage || !Navigator.canPop(context);
                                              },
                                            );
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 20,
              child: Container(
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
            )
          ],
        ),
      ),
    );
  }
}





