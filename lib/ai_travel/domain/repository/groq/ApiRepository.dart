import '../../../data/model/GroqModel.dart';
import '../../../data/model/MultiPlaceModel.dart';

abstract class GetPlaceDetailRepository {
  Future<Place> getPlaceDetails(String city);
  Future<Places> getPlacesDetails(String city);
}






