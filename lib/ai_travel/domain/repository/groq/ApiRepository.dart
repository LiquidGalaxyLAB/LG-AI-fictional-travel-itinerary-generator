import '../../../data/model/GroqModel.dart';

abstract class GetPlaceDetailRepository {
  Future<Place> getPlaceDetails(String city);
}






