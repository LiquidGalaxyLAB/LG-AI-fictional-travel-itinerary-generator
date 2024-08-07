import 'dart:convert';

import 'package:lg_ai_travel_itinerary/ai_travel/core/utils/constants.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/model/AiModels.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/model/MultiPlaceModel.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/model/TravelDestinations.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/domain/repository/groq/ApiRepository.dart';
import '../../../data/model/GroqModel.dart';
import '../../../data/service/apiService.dart';

class GetPLaceRepositoryImpl implements GetPlaceDetailRepository {
  final GroqApiService groqApiService;

  GetPLaceRepositoryImpl(this.groqApiService);

  @override
  Future<Place> getPlaceDetails(String city) async {
    GroqModelNew? groqModelNew = await
    groqApiService.sendPostRequest(Const.testPrompts[1].replaceAll("\$city", city));
    var response = groqModelNew!.choices?[0].message?.content;
    response = response?.substring(7, response.length - 3); //this is done to remove the ```json from the beginning and ``` from the end
    response = response?.replaceAll(RegExp(r',\s*}'), '}'); // Remove trailing commas before closing braces
    response = response?.replaceAll(RegExp(r',\s*\]'), ']'); // Remove trailing commas before closing brackets
    print('Response: $response');
    Map<String, dynamic> jsonMap = jsonDecode(response!);
    return Place.fromJson(jsonMap);
  }

  @override
  Future<Places> getPlacesDetails(String city,String model) async{
    GroqResponseModel? groqModelNew = await groqApiService.sendPostPrompt(Const.testPrompts[1].replaceAll("\$city", city),model);
    var response = groqModelNew!.choices?[0].message?.content;
    response = response?.substring(7, response.length - 3); //this is done to remove the ```json from the beginning and ``` from the end
    Map<String, dynamic> jsonMap = jsonDecode(response!);
    return Places.fromJson(jsonMap);
  }

  @override
  Future<GroqAiModelList?> getAvailableModels() async{
    return await groqApiService.getAvailableModels();
  }

  @override
  Future<TravelDestinations> getTravelDestinations(String city,String model) async{
    GroqResponseModel? groqModelNew = await groqApiService.sendPostPrompt(Const.testPrompts[2].replaceAll("\$city", city),model);
    var response = groqModelNew!.choices?[0].message?.content;
    response = response?.substring(7, response.length - 3); //this is done to remove the ```json from the beginning and ``` from the end
    Map<String, dynamic> jsonMap = jsonDecode(response!);
    return TravelDestinations.fromJson(jsonMap);
  }
}