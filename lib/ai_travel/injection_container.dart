import 'package:get_it/get_it.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/domain/repository/groq/ApiRepository.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/domain/repository/groq/ApiRepositoryImpl.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/ui/use_case/api_use_case.dart';

import 'data/service/apiService.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl.registerSingleton<GroqApiService>(GroqApiService());
  sl.registerLazySingleton<GetPlaceDetailRepository>(() => GetPLaceRepositoryImpl(sl<GroqApiService>()));
  sl.registerLazySingleton<GetPlaceDetailUseCase>(() => GetPlaceDetailUseCase(sl<GetPlaceDetailRepository>()));
}