import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/string/String.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/theme/app_theme.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/ui/use_case/api_use_case.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/widgets/app_bar.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/widgets/destination_card.dart';

import '../../data/model/GroqModel.dart';
import '../../domain/ssh/SSH.dart';
import '../../injection_container.dart';

class AddCity extends ConsumerStatefulWidget {
  const AddCity({super.key});

  @override
  _AddCityState createState() => _AddCityState();
}

class _AddCityState extends ConsumerState<AddCity> {
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    /*_getResponse();*/
  }

  void _getResponse(String poi) async {
    print('Getting place details for $poi');
    final useCase = sl.get<GetPlaceDetailUseCase>(); // Inject with GetIt
    Place place = await useCase.getPlace(poi);
    _loadChatResponse(place.description!);
    print('Name: ${place.name}');
    print('Location: ${place.location}');
    print('Description: ${place.description}');
  }

  Future<void> _loadChatResponse(String response) async {
    await SSH(ref: ref).cleanSlaves(context);
    await SSH(ref: ref).cleanBalloon(context);
    await SSH(ref: ref).ChatResponseBalloon(response);
    await SSH(ref:ref).stopOrbit(context);
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
                                  Strings.enterDestination,
                                  // Replace with your text
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Expanded(
                                  child: TextField(
                                    cursorColor: AppColors.textColor,
                                    textAlign: TextAlign.start,
                                    controller: _textEditingController,
                                    textAlignVertical: TextAlignVertical.top,
                                    maxLines: null,
                                    expands: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: BorderSide(
                                            color: AppColors.textFieldColor,
                                            width: 2),
                                      ),
                                      hintText: Strings.exampleAddCity,
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade500,
                                      ),
                                      focusColor: AppColors.textFieldColor,
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 0.5)),
                                      fillColor: AppColors.textFieldColor,
                                      filled: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Container(
                                    alignment: Alignment.center,
                                    child: CustomButtonWidget(
                                      onPressed: () {
                                        _getResponse(_textEditingController.text);
                                      },
                                    )
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
