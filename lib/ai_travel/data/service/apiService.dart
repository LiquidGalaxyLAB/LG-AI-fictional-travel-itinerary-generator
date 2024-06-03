import 'package:dio/dio.dart';
import 'package:groq/groq.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/model/GroqModel.dart';

class GroqApiService {
  String myApiKey = 'your-api-key-here';
  GroqModel myModel = GroqModel.gemma7bit; // or any other model you want to useration

  Future<GroqModelNew?> sendPostRequest(String userPrompt) async {
    const String apiUrl = "https://api.groq.com/openai/v1/chat/completions";
    const String apiKey = "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";

    Dio dio = Dio();

    try {
      final response = await dio.post(
        apiUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer $apiKey",
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
        // Successfully received a response
        print('Response data: ${response.data}');
        return GroqModelNew.fromJson(response.data);
      } else {
        // An error occurred
        print('Request failed with status: ${response.statusCode}');
        print('Response data: ${response.data}');
        return null;
      }
    } catch (e) {
      // Handle any errors that occur during the request
      print('Error: $e');
    }
    return null;
  }

}
