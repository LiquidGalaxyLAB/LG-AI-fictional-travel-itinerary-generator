import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/string/String.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/theme/app_theme.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/model/MultiPlaceModel.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/ui/use_case/api_use_case.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/widgets/app_bar.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/widgets/destination_card.dart';

import '../../../data/model/GroqModel.dart';
import '../../../domain/ssh/SSH.dart';
import '../../../injection_container.dart';
import 'generated_sub_poi_page.dart';

class AddCity extends ConsumerStatefulWidget {
  const AddCity({super.key});

  @override
  _AddCityState createState() => _AddCityState();
}

class _AddCityState extends ConsumerState<AddCity> {
  TextEditingController _textEditingController = TextEditingController();
  late Place place = Place(name: "", location: [], description: "", address: '',place: '');
  late Places places = Places(name: [],description: [],address: []);
  final isLoading = true;
  void _getResponse(String poi) async {
    print('Getting place details for $poi');
    /*Place place = await getResponse(poi);*/
    places = await getResponses(poi);
    print('Name: ${places.name![0]}');
   /* _loadChatResponse(place);*/
    _loadChatResponses(places);
    print('Name: ${place.place}');
    print('address: ${place.address}');
    print('Description: ${place.description}');
  }

  Future<Place> getResponse(String poi) async{
    final useCase = sl.get<GetPlaceDetailUseCase>(); // Inject with GetIt
    /*place = await useCase.getPlace(poi);*/
    places = await useCase.getPlaces(poi);
    return place;
  }

  Future<Places> getResponses(String poi) async{
    final useCase = sl.get<GetPlaceDetailUseCase>(); // Inject with GetIt
    places = await useCase.getPlaces(poi);
    return places;
  }

  Future<void> _loadChatResponse(Place response) async {
    /*await SSH(ref: ref).cleanSlaves(context);
    await SSH(ref: ref).cleanBalloon(context);*/
    if(response.description != null){
      await SSH(ref: ref).ChatResponseBalloon(response.description!);
    }else{
      await SSH(ref: ref).ChatResponseBalloon('No description available');
    }
    /*_navigate(place.address!);*/
    await SSH(ref:ref).stopOrbit(context);
  }
  //do it for places
  Future<void> _loadChatResponses(Places response) async {
    for(int i=0;i<response.name!.length;i++){
      Future.delayed(Duration(seconds: 2 * (i + 1)), () async{
        await SSH(ref: ref).cleanSlaves(context);
        await SSH(ref: ref).cleanBalloon(context);
        if(response.description![i] != null){
          await SSH(ref: ref).ChatResponseBalloon(response.description![i]);
        }else{
          await SSH(ref: ref).ChatResponseBalloon('No description available');
        }
        await SSH(ref:ref).stopOrbit(context);
      });
    }
  }

  Future<void> _navigate(String location) async {
    print('Navigating to $location');
    SSHSession? session = await SSH(ref: ref).search("$location");
    if (session != null) {
      print(session.stdout);
    }
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
                                Container(
                                    alignment: Alignment.center,
                                    child: CustomButtonWidget(
                                      text: "explore place",
                                      onPressed: () async{
                                        if(place.name==null){
                                          print('Navigating to ${place.place}, ${place.address!}');
                                          _navigate("${place.place}, ${place.address!}");
                                        }else{
                                          print('Navigating to ${place.name}, ${place.address!}');
                                          _navigate("${place.name}, ${place.address!}");
                                          for(int i=0;i<places.name!.length;i++){
                                            if(i==0){
                                              Future.delayed(Duration(seconds: 2 * (i + 1)), () async{
                                                print('Navigating to ${places.name![i]}, ${places.address![i]}');
                                                _navigate("${places.name![i]}, ${places.address![i]}");
                                              });
                                            }else{
                                              Future.delayed(Duration(seconds: 8 * (i + 1)), () async{
                                                print('Navigating to ${places.name![i]}, ${places.address![i]}');
                                                _navigate("${places.name![i]}, ${places.address![i]}");
                                              });
                                            }
                                          }
                                        }
                                        Navigator.push(context,
                                          MaterialPageRoute(builder: (context) =>
                                              GeneratedSubPoiPage(places: places)
                                          )
                                        );
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
  Future<void> navigateToSubPoiPage(Places places) async {
    Navigator.pushNamed(context, '/generatedSubPoiPage',arguments: places);
  }
}
