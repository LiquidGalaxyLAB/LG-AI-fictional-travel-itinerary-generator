import 'package:lg_ai_travel_itinerary/ai_travel/data/model/AiModels.dart';

import '../../../domain/repository/groq/ApiRepository.dart';

class GetModelUseCase {
  final GetPlaceDetailRepository repository;
  GetModelUseCase(this.repository);

  Future<GroqAiModelList?> getAvailableModels () async {
    return await repository.getAvailableModels();
  }
}