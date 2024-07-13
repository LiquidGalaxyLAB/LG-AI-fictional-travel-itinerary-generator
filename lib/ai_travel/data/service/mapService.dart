import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<String>> getNearbyPlacesPhotoReferences({required double latitude, required double longitude, required String apiKey}) async {
  final String url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=1500&key=$apiKey';

  final http.Response response = await http.get(Uri.parse(url));
  print("Response: ${latitude} ${longitude}  ${apiKey} ${response.body}");
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    List<String> photoReferences = [];
    for (var place in data['results']) {
      if (place['photos'] != null && place['photos'].isNotEmpty) {
        photoReferences.add(place['photos'][0]['photo_reference']);
      }
    }
    return photoReferences;
  } else {
    throw Exception('Failed to load nearby places');
  }
}

String uint8ListToBase64(Uint8List data) {
  return base64Encode(data);
}

Future<Uint8List> fetchPlaceImage({required String photoReference, required String apiKey}) async {
  final String url = 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$apiKey';

  final http.Response response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return response.bodyBytes;
  } else {
    throw Exception('Failed to load place image');
  }
}

Future<String> fetchPlaceImage2({required String photoReference, required String apiKey}) async {
  final String url = 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$apiKey';

  final http.Response response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final bytes = response.bodyBytes;
    return base64Encode(bytes);
  } else {
    throw Exception('Failed to load place image');
  }
}


Future<String> loadNearbyPlacesImages(double latitude, double longitude, String apiKey) async {
  List<String> photoReferences = await getNearbyPlacesPhotoReferences(
    latitude: latitude,
    longitude: longitude,
    apiKey: apiKey,
  );

  if (photoReferences.isEmpty) {
    throw Exception('No photo references found.');
  }

  try{
    String firstPhotoReference = photoReferences[0];
    Uint8List image = await fetchPlaceImage(photoReference: firstPhotoReference, apiKey: apiKey);
    String image2 = await fetchPlaceImage2(photoReference: firstPhotoReference, apiKey: apiKey);
    String base64Image = base64Encode(image);
    return image2;
  }catch(e){
    print("!@# $e");
    return 'https://drive.google.com/file/d/1z7Qu17dyVYW84YLad4wL7qkZ9RdfKpwy/preview';
  }


}

