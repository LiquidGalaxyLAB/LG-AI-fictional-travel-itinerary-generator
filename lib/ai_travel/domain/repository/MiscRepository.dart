import '../../data/model/TimeZoneModal.dart';
import '../../data/model/WeatherModal.dart';

abstract class MiscRepository{
  Future<TimeZoneModal?> getTimeZoneInfo(double latitude, double longitude);
  Future<WeatherModal?> getWeatherInfo(double latitude, double longitude);
}