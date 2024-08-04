import 'dart:convert';

class SubPoiInfoModalx {
  final List<Place> places;

  SubPoiInfoModalx({required this.places});

  factory SubPoiInfoModalx.fromJson(Map<String, dynamic> json) {
    return SubPoiInfoModalx(
      places: (json['places'] as List<dynamic>)
          .map((placeJson) => Place.fromJson(placeJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'places': places.map((place) => place.toJson()).toList(),
    };
  }
}

class Place {
  final String formattedAddress;
  final List<AddressComponent> addressComponents;
  final Viewport viewport;
  final String googleMapsUri;
  final String websiteUri;
  final int utcOffsetMinutes;
  final DisplayName displayName;

  Place({
    required this.formattedAddress,
    required this.addressComponents,
    required this.viewport,
    required this.googleMapsUri,
    required this.websiteUri,
    required this.utcOffsetMinutes,
    required this.displayName,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      formattedAddress: json['formattedAddress'],
      addressComponents: (json['addressComponents'] as List<dynamic>)
          .map((componentJson) => AddressComponent.fromJson(componentJson))
          .toList(),
      viewport: Viewport.fromJson(json['viewport']),
      googleMapsUri: json['googleMapsUri'],
      websiteUri: json['websiteUri'],
      utcOffsetMinutes: json['utcOffsetMinutes'],
      displayName: DisplayName.fromJson(json['displayName']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formattedAddress': formattedAddress,
      'addressComponents': addressComponents.map((component) => component.toJson()).toList(),
      'viewport': viewport.toJson(),
      'googleMapsUri': googleMapsUri,
      'websiteUri': websiteUri,
      'utcOffsetMinutes': utcOffsetMinutes,
      'displayName': displayName.toJson(),
    };
  }
}

class AddressComponent {
  final String longText;
  final String shortText;
  final List<String> types;
  final String languageCode;

  AddressComponent({
    required this.longText,
    required this.shortText,
    required this.types,
    required this.languageCode,
  });

  factory AddressComponent.fromJson(Map<String, dynamic> json) {
    return AddressComponent(
      longText: json['longText'],
      shortText: json['shortText'],
      types: List<String>.from(json['types']),
      languageCode: json['languageCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'longText': longText,
      'shortText': shortText,
      'types': types,
      'languageCode': languageCode,
    };
  }
}

class Viewport {
  final LatLngNew low;
  final LatLngNew high;

  Viewport({required this.low, required this.high});

  factory Viewport.fromJson(Map<String, dynamic> json) {
    return Viewport(
      low: LatLngNew.fromJson(json['low']),
      high: LatLngNew.fromJson(json['high']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'low': low.toJson(),
      'high': high.toJson(),
    };
  }
}

class LatLngNew {
  final double latitude;
  final double longitude;

  LatLngNew({required this.latitude, required this.longitude});

  factory LatLngNew.fromJson(Map<String, dynamic> json) {
    return LatLngNew(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class DisplayName {
  final String text;
  final String languageCode;

  DisplayName({required this.text, required this.languageCode});

  factory DisplayName.fromJson(Map<String, dynamic> json) {
    return DisplayName(
      text: json['text'],
      languageCode: json['languageCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'languageCode': languageCode,
    };
  }
}
