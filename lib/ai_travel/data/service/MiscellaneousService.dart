import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/model/TimeZoneModal.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/model/WeatherModal.dart';

class MiscellaneousService {
  static const String _timeZoneBaseUrl = 'https://timeapi.io/api/TimeZone/coordinate';
  static const String _weatherBaseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  final Dio _dio = Dio();

  Future<String> _getWeatherApiKey() async{
    await dotenv.load(fileName: 'keys.env');
    String? weatherApiKey = dotenv.env['WEATHER_API']; //USING KEYS.ENV FILE FOR STORING THE KEYS
    String? apiKey = weatherApiKey ?? 'your-api-key-here';
    return apiKey;
  }

  Future<WeatherModal?> getWeatherInfo(double latitude, double longitude) async {
    final apiKey = await _getWeatherApiKey();
    final response = await _dio.get(
      _weatherBaseUrl,
      queryParameters: {
        'lat': latitude,
        'lon': longitude,
        'appid': apiKey,
      },
    );
    print("weather modal ${response.data}");
    if (response.statusCode == 200) {
      return WeatherModal.fromJson(response.data);
    } else {
      throw Exception('Failed to load weather information');
    }
  }

  Future<TimeZoneModal?> getTimeInfo(double latitude, double longitude) async {
    final response = await _dio.get(
      _timeZoneBaseUrl,
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    if (response.statusCode == 200) {
      print("tempx is ${response.data}");
      return TimeZoneModal.fromJson(response.data);
    } else {
      throw Exception('Failed to load time information');
    }
  }
}
