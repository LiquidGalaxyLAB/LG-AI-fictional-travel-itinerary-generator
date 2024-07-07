import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/string/String.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/theme/app_theme.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/model/MultiPlaceModel.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/providers/connection_providers.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/ui/use_case/api_use_case.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/ui/use_case/get_model_use_case.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/widgets/app_bar.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/widgets/destination_card.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/widgets/drop_down_class.dart';
import '../../../data/model/GroqModel.dart';
import '../../../injection_container.dart';
import '../../widgets/cutom_circular_indicator.dart';
import 'generated_sub_poi_page.dart';

class AddCity extends ConsumerStatefulWidget {
  final String initialText;

  const AddCity({Key? key, this.initialText = ''}) : super(key: key);

  @override
  _AddCityState createState() => _AddCityState();
}


class _AddCityState extends ConsumerState<AddCity> {
  final List<String> groqAiModelList = [];
  var isContentLoaded = false;
  var isLoadingModels = true;
  late  TextEditingController _textEditingController = TextEditingController();
  late Place place = Place(name: "", location: [], description: "", address: '', place: '');
  late Places places = Places(name: [], description: [], address: [], title: "");
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.initialText);
    _getModels();
  }

  void _getModels() async {
    try {
      final useCase = sl.get<GetModelUseCase>();
      var models = await useCase.getAvailableModels();
      models?.data?.forEach((element) {
        groqAiModelList.add(element.id!);
      });
      setState(() {
        ref.read(groqAiModelsListProvider.notifier).state = groqAiModelList;
        isLoadingModels = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoadingModels = false;
      });
    }
  }

  void _getResponse(String poi) async {
    setState(() {
      isLoading = true;
      isContentLoaded = false;
      places = Places(name: [], description: [], address: [], title: "");
    });
    places = await getResponses(poi);
    setState(() {
      isLoading = false;
      if (places.name!.isNotEmpty) {
        isContentLoaded = true;
      } else {
        isContentLoaded = false;
      }
    });
    print("this is the state of $isContentLoaded ${places.title?.length}");
    if (isContentLoaded) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GeneratedSubPoiPage(places: places)),
      );
    }
  }

  Future<Places> getResponses(String poi) async {
    var model = ref.watch(currentAiModelSelected);
    try {
      final useCase = sl.get<GetPlaceDetailUseCase>(); // Inject with GetIt
      return await useCase.getPlaces(poi,model);
    } catch (e) {
      print(e);
      return Places(name: [], description: [], address: [], title: "");
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      isLoadingModels
                          ? const SizedBox(
                        width: 24.0,
                        height: 24.0,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                          : CustomDropdown(elementList: groqAiModelList),
                    ],
                  ),
                  SizedBox(height: 20),
                  DestinationInputSection(
                    height: height,
                    textEditingController: _textEditingController,
                    isLoading: isLoading,
                    isContentLoaded: isContentLoaded,
                    getResponse: _getResponse,
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
    Navigator.pushNamed(context, '/generatedSubPoiPage', arguments: places);
  }
}


class DestinationInputSection extends StatelessWidget {
  final double height;
  final TextEditingController textEditingController;
  final bool isLoading;
  final bool isContentLoaded;
  final void Function(String) getResponse;

  const DestinationInputSection({
    Key? key,
    required this.height,
    required this.textEditingController,
    required this.isLoading,
    required this.isContentLoaded,
    required this.getResponse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                          controller: textEditingController,
                          textAlignVertical: TextAlignVertical.top,
                          maxLines: null,
                          expands: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: AppColors.textFieldColor, width: 2),
                            ),
                            hintText: Strings.exampleAddCity,
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                            ),
                            focusColor: AppColors.textFieldColor,
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
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
                        child: isLoading
                            ? Container()
                            : CustomButtonWidget(
                          text: Strings.explore,
                          onPressed: () {
                            getResponse(textEditingController.text);
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
        if (isLoading)
          Center(
            child: Container(
              height: height * 0.5,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomCircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text(
                    "Loading...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}