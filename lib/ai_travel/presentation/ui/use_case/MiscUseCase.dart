import 'package:lg_ai_travel_itinerary/ai_travel/domain/repository/MiscRepository.dart';

import '../../../data/model/TimeZoneModal.dart';
import '../../../data/model/WeatherModal.dart';

class MiscUseCase{
  MiscRepository repository;
  MiscUseCase(this.repository);

  Future<TimeZoneModal?> getTimeZoneInfo(double latitude, double longitude) async {
    return await repository.getTimeZoneInfo(latitude, longitude);
  }

  Future<WeatherModal?> getWeatherInfo(double latitude, double longitude) async {
    return await repository.getWeatherInfo(latitude, longitude);
  }
}
