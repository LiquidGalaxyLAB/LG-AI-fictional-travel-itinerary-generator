import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:groq/groq.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/model/AiModels.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/model/GroqModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/string/String.dart';
import '../model/MultiPlaceModel.dart';

class GroqApiService {
  String myApiKey = 'your-api-key-here';
  GroqModel myModel = GroqModel.gemma7bit;
  static const apiUrl = "https://api.groq.com/openai/v1/chat/completions";
  final Dio dio = Dio();

  Future<String> _getApiKey() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var userGroqKey = prefs.getString(Strings.groqApiKeys);
    print('User Groq Key: $userGroqKey');
    await dotenv.load(fileName: 'keys.env');
    String? GROQ_API_KEY = dotenv.env['GROQ_API']; // Using keys.env file for storing the keys
    // Use userGroqKey if it's not null or empty, otherwise fallback to the env key
    String apiKey = (userGroqKey != null && userGroqKey.isNotEmpty) ? userGroqKey : GROQ_API_KEY ?? '$GROQ_API_KEY';
    return apiKey;
  }


  Future<GroqModelNew?> sendPostRequest(String userPrompt) async {
    try {
      final response = await dio.post(
        apiUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer ${await _getApiKey()}",
            "Content-Type": "application/json",
          },
        ),
        data: {
          "messages": [
            {"role": "user", "content": userPrompt}
          ],
          "model": "gemma-7b-it",
        },
      );

      if (response.statusCode == 200) {
        print('Response data: ${response.data}');
        return GroqModelNew.fromJson(response.data);
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response data: ${response.data}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  Future<GroqResponseModel?> sendPostPrompt(String userPrompt,String model) async {
    try {
      final response = await dio.post(
        apiUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer ${await _getApiKey()}",
            "Content-Type": "application/json",
          },
        ),
        data: {
          "messages": [
            {"role": "user", "content": userPrompt}
          ],
          "model": "$model",
        },
      );

      if (response.statusCode == 200) {
        print('Response data: ${response.data}');
        return GroqResponseModel.fromJson(response.data);
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response data: ${response.data}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  Future<GroqAiModelList?> getAvailableModels() async {
    const String modelUrl = "https://api.groq.com/openai/v1/models";
    try {
      final response = await dio.get(
        modelUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer ${await _getApiKey()}",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Response data: ${response.data}');
        return GroqAiModelList.fromJson(response.data);
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response data: ${response.data}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
