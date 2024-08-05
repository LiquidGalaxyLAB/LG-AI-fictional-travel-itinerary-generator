import 'package:lg_ai_travel_itinerary/ai_travel/data/model/SubPoiInfoModal.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/service/mapService.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/domain/repository/groq/mapRepository.dart';

class MapRepositoryImpl implements MapRepository{
  MapService mapService;
  MapRepositoryImpl(this.mapService);

  @override
  Future<SubPoiInfoModal?> getSubPoiPlaceInfo(String query) {
    print("MapRepositoryImpl: getSubPoiPlaceInfo");
    return mapService.getSubPoiPlaceInfo(query);
  }

}