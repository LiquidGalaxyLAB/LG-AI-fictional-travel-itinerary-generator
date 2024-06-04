import 'dart:convert';

import 'package:lg_ai_travel_itinerary/ai_travel/domain/repository/groq/ApiRepository.dart';

import '../../../data/model/GroqModel.dart';
import '../../../data/service/apiService.dart';

class GetPLaceRepositoryImpl implements GetPlaceDetailRepository {
  final GroqApiService groqApiService;

  GetPLaceRepositoryImpl(this.groqApiService);

  @override
  Future<Place> getPlaceDetails(String city) async {
    GroqModelNew? groqModelNew = await
    groqApiService.sendPostRequest("Provide details about one eating place in $city including its name, coordinates in array format, and a brief description in JSON format no Markdown");
    var response = groqModelNew!.choices?[0].message?.content;
    response = response?.substring(7, response.length - 3); //this is done to remove the ```json from the beginning and ``` from the end
    Map<String, dynamic> jsonMap = jsonDecode(response!);
    return Place.fromJson(jsonMap);
  }
}