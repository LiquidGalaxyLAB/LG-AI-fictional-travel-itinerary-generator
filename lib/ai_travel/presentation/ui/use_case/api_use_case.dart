import '../../../data/model/GroqModel.dart';
import '../../../domain/repository/groq/ApiRepository.dart';

class GetPlaceDetailUseCase {
  final GetPlaceDetailRepository repository;
  GetPlaceDetailUseCase(this.repository);

  Future<Place> getPlace(String city) async {
    return await repository.getPlaceDetails(city);
  }
}