import '../../../data/model/GroqModel.dart';
import '../../../data/model/MultiPlaceModel.dart';
import '../../../domain/repository/groq/ApiRepository.dart';

class GetPlaceDetailUseCase {
  final GetPlaceDetailRepository repository;
  GetPlaceDetailUseCase(this.repository);

  Future<Place> getPlace(String city) async {
    return await repository.getPlaceDetails(city);
  }

  Future<Places> getPlaces(String city) async {
    return await repository.getPlacesDetails(city);
  }
}