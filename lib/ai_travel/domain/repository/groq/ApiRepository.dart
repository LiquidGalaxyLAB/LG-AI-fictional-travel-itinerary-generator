import 'package:lg_ai_travel_itinerary/ai_travel/data/model/AiModels.dart';

import '../../../data/model/GroqModel.dart';
import '../../../data/model/MultiPlaceModel.dart';

abstract class GetPlaceDetailRepository {
  Future<Place> getPlaceDetails(String city);
  Future<Places> getPlacesDetails(String city,String model);
  Future<GroqAiModelList?> getAvailableModels();
}






