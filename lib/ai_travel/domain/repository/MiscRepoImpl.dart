import 'package:lg_ai_travel_itinerary/ai_travel/data/model/TimeZoneModal.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/model/WeatherModal.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/service/MiscellaneousService.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/domain/repository/MiscRepository.dart';

class MiscRepoImpl extends MiscRepository{
  final MiscellaneousService miscellaneousService;
  MiscRepoImpl(this.miscellaneousService);

  @override
  Future<TimeZoneModal?> getTimeZoneInfo(double latitude, double longitude) {
    final timeInfo = miscellaneousService.getTimeInfo(latitude, longitude);
    print("!@# $timeInfo");
    return timeInfo;
  }

  @override
  Future<WeatherModal?> getWeatherInfo(double latitude, double longitude) {
    final weatherInfo = miscellaneousService.getWeatherInfo(latitude, longitude);
    return weatherInfo;
  }
}