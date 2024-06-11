import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/model/MultiPlaceModel.dart';

import '../../../config/string/String.dart';
import '../../../config/theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/destination_card.dart';

class GeneratedSubPoiPage extends StatefulWidget {
  final Places places;
  const GeneratedSubPoiPage({Key? key, required this.places}) : super(key: key);


  @override
  State<GeneratedSubPoiPage> createState() => _GeneratedSubPoiPageState();
}

class _GeneratedSubPoiPageState extends State<GeneratedSubPoiPage> {
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
                                      "India",
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
                                      "27.1767° N, 78.0081° E",
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
                                      print('Explore ${widget.places.name}');
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
