import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/model/MultiPlaceModel.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/ui/main_screens/google_map/google_map_subPoi.dart';

import '../../../config/string/String.dart';
import '../../../config/theme/app_theme.dart';
import '../../../domain/ssh/SSH.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/destination_card.dart';
class GeneratedSubPoiPage extends ConsumerStatefulWidget {
  final Places places;
  const GeneratedSubPoiPage({super.key, required this.places});


  @override
  _GeneratedSubPoiPageState createState() => _GeneratedSubPoiPageState();
}

class _GeneratedSubPoiPageState extends ConsumerState<GeneratedSubPoiPage> {
  @override
  void initState() {
    print('Places: ${widget.places.name}');
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
        body: Center(
          child: Padding(
            padding: EdgeInsets.only(
                top: 20, left: paddingValue, right: paddingValue, bottom: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: height * 0.5,
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
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.places.title!,
                                  // Replace with your text
                                  style: const TextStyle(
                                    fontSize: 32.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                const Row(
                                  children: [
                                    Icon(
                                      Iconsax.location,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 5.0),
                                    Text(
                                      "Unknown",
                                      // Replace with your text
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2.0),
                                const Row(
                                  children: [
                                    Icon(
                                      Iconsax.map,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 5.0),
                                    Text(
                                      "Multiple Location",
                                      // Replace with your text
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.0),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: widget.places.description!.map((description) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                                          child: Text(
                                            description,
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Container(
                                  alignment: Alignment.center,
                                  child: CustomButtonWidget(
                                    onPressed: () {
                                      //Navigator.push(context, MaterialPageRoute(builder: (context) => MapSample()));
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => GoogleMapScreen(place: widget.places)));
                                      /*_loadChatResponses(widget.places);*/
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
      ),
    );
  }



}
