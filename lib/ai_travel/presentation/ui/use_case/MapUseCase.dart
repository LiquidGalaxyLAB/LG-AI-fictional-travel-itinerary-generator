import '../../../data/model/SubPoiInfoModal.dart';
import '../../../domain/repository/groq/mapRepository.dart';

class MapUseCase {
  final MapRepository _repository;

  MapUseCase(this._repository);

  Future<SubPoiInfoModal?> getSubPoiInfo(String query) async {
    return await _repository.getSubPoiPlaceInfo(query);
  }
}