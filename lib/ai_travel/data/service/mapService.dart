
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/SubPoiInfoModal.dart';

import 'package:dio/dio.dart';

class MapService {
  static const String _baseUrl = "https://places.googleapis.com/v1/places:searchText";

  final Dio _dio = Dio();


  Future<SubPoiInfoModal?> getSubPoiPlaceInfo(String query) async {
    print('Making API request for place info $query');
    try {
      final response = await _dio.post(
        _baseUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': await _apiKey(),
            'X-Goog-FieldMask': 'places.displayName,places.formattedAddress,places.googleMapsUri,places.goodForChildren,places.accessibilityOptions,places.userRatingCount,places.rating,places.websiteUri,places.viewport,places.addressComponents,places.utcOffsetMinutes,places.reviews',
          },
        ),
        data: {
          'textQuery': query,
        },
      );
      if (response.statusCode == 200) {
        print(response.data);
        return SubPoiInfoModal.fromJson(response.data);
      } else {
        throw Exception('Failed to load place info');
      }
    } on DioException catch (e) {
      print('Error making API request: ${e.message}');
    } catch(e) {
      print('Error making API request: $e');
    }
    return null;
  }

  Future<dynamic> getSubPoiPlaceInfotest(String query) async {
    print('Making API request for place info $query');

      final response = await _dio.post(
        _baseUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': await _apiKey(),
            'X-Goog-FieldMask': 'places.displayName,places.formattedAddress,places.googleMapsUri,places.goodForChildren,places.accessibilityOptions,places.userRatingCount,places.rating,places.websiteUri,places.viewport,places.addressComponents,places.utcOffsetMinutes',
          },
        ),
        data: {
          'textQuery': query,
        },
      );
      print(response.data);
      return response.data;
  }
}

Future<String> _apiKey() async{
  await dotenv.load(fileName: 'keys.env');
  String? GMAPSAPI = dotenv.env['GMAPSAPI']; //USING KEYS.ENV FILE FOR STORING THE KEYS
  String? apiKey = GMAPSAPI ?? 'your-api-key-here';
  print('API Key: $apiKey');
  return apiKey;
}

Future<List<String>> searchPlacesByText({
  required String textQuery,
  required String apiKey,
}) async {
  final String url = 'https://places.googleapis.com/v1/places:searchText';
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': await _apiKey(),
      'X-Goog-FieldMask': 'places.displayName,places.formattedAddress,places.photos',
    },
    body: jsonEncode({'textQuery': textQuery}),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);

    // Debugging print
    print('API Response: $data');

    // Check if 'places' is present and is a list
    final places = data['places'];
    if (places is List) {
      List<String> photoReferences = [];
      for (var place in places) {
        if (place['photos'] != null && place['photos'].isNotEmpty) {
          // Use the 'name' field from the 'photos' list
          photoReferences.add(place['photos'][0]['name']);
        }
      }
      return photoReferences;
    } else {
      throw Exception('Unexpected data format: places is not a list');
    }
  } else {
    throw Exception('Failed to search places: ${response.statusCode}');
  }
}

Future<Uint8List> fetchPlaceImage({
  required String photoReference,
  required String apiKey,
}) async {
  print('Fetching image for photoReference: $photoReference');
  final String url = 'https://places.googleapis.com/v1/$photoReference/media?maxHeightPx=400&maxWidthPx=400&key=${await _apiKey()}';
  final http.Response response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return response.bodyBytes;
  } else {
    throw Exception('Failed to load place image');
  }
}

Future<String> loadNearbyPlacesImages({
  required String textQuery,
  required String apiKey,
}) async {
  List<String> photoReferences = await searchPlacesByText(
    textQuery: textQuery,
    apiKey: apiKey,
  );

  if (photoReferences.isEmpty) {
    throw Exception('No photo references found.');
  }

  try {
    String firstPhotoReference = photoReferences[0];

    Uint8List imageBytes = await fetchPlaceImage(
      photoReference: firstPhotoReference,
      apiKey: apiKey,
    );
    return base64Encode(imageBytes);
  } catch (e) {
    print("Error fetching image: $e");
    return 'https://drive.google.com/file/d/1z7Qu17dyVYW84YLad4wL7qkZ9RdfKpwy/preview';
  }
}



