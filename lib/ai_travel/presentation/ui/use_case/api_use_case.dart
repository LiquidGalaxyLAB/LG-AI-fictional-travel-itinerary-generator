import '../../../data/model/GroqModel.dart';
import '../../../data/model/MultiPlaceModel.dart';
import '../../../data/model/TravelDestinations.dart';
import '../../../domain/repository/groq/ApiRepository.dart';

class GetPlaceDetailUseCase {
  final GetPlaceDetailRepository repository;
  GetPlaceDetailUseCase(this.repository);

  Future<Place> getPlace(String city) async {
    return await repository.getPlaceDetails(city);
  }

  Future<Places> getPlaces(String city,String model) async {
    return await repository.getPlacesDetails(city,model);
  }

  Future<TravelDestinations> getTravelDestinations(String city, String model) async {
    return await repository.getTravelDestinations(city,model);
  }
}