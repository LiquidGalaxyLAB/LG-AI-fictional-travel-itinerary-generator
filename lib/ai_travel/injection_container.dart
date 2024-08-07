import 'package:get_it/get_it.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/service/MiscellaneousService.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/domain/repository/MiscRepoImpl.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/domain/repository/groq/ApiRepository.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/domain/repository/groq/ApiRepositoryImpl.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/domain/repository/groq/MapRepositoryImpl.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/ui/use_case/MapUseCase.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/ui/use_case/MiscUseCase.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/ui/use_case/api_use_case.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/ui/use_case/get_model_use_case.dart';

import 'data/service/apiService.dart';
import 'data/service/mapService.dart';
import 'domain/repository/MiscRepository.dart';
import 'domain/repository/groq/mapRepository.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl.registerSingleton<GroqApiService>(GroqApiService());
  sl.registerLazySingleton<GetPlaceDetailRepository>(() => GetPLaceRepositoryImpl(sl<GroqApiService>()));
  sl.registerLazySingleton<GetPlaceDetailUseCase>(() => GetPlaceDetailUseCase(sl<GetPlaceDetailRepository>()));
  sl.registerLazySingleton<GetModelUseCase>(() => GetModelUseCase(sl<GetPlaceDetailRepository>()));

  //MiscellaneousService
  sl.registerSingleton<MiscellaneousService>(MiscellaneousService());
  sl.registerLazySingleton<MiscRepository>(() => MiscRepoImpl(sl<MiscellaneousService>()));
  sl.registerLazySingleton<MiscUseCase>(() => MiscUseCase(sl<MiscRepository>()));

  //MapService
  sl.registerSingleton<MapService>(MapService());
  sl.registerLazySingleton<MapRepository>(() => MapRepositoryImpl(sl<MapService>()));
  sl.registerLazySingleton<MapUseCase>(() => MapUseCase(sl<MapRepository>()));

}