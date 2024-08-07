import 'package:json_annotation/json_annotation.dart';

part 'SubPoiInfoModal.g.dart';

@JsonSerializable()
class SubPoiInfoModal {
  @JsonKey(name: 'places')
  final List<Place>? places;

  SubPoiInfoModal({this.places});

  factory SubPoiInfoModal.fromJson(Map<String, dynamic> json) =>
      _$SubPoiInfoModalFromJson(json);

  Map<String, dynamic> toJson() => _$SubPoiInfoModalToJson(this);
}

@JsonSerializable()
class Place {
  @JsonKey(name: 'formattedAddress')
  final String? formattedAddress;

  @JsonKey(name: 'addressComponents')
  final List<AddressComponent>? addressComponents;

  @JsonKey(name: 'viewport')
  final Viewport? viewport;

  @JsonKey(name: 'rating')
  final double? rating;

  @JsonKey(name: 'googleMapsUri')
  final String? googleMapsUri;

  @JsonKey(name: 'websiteUri')
  final String? websiteUri;

  @JsonKey(name: 'utcOffsetMinutes')
  final int? utcOffsetMinutes;

  @JsonKey(name: 'userRatingCount')
  final int? userRatingCount;

  @JsonKey(name: 'displayName')
  final DisplayName? displayName;

  @JsonKey(name: 'goodForChildren')
  final bool? goodForChildren;

  @JsonKey(name: 'accessibilityOptions')
  final AccessibilityOptions? accessibilityOptions;

  @JsonKey(name: 'reviews')
  final List<Review>? reviews;

  Place({
    this.formattedAddress,
    this.addressComponents,
    this.viewport,
    this.rating,
    this.googleMapsUri,
    this.websiteUri,
    this.utcOffsetMinutes,
    this.userRatingCount,
    this.displayName,
    this.goodForChildren,
    this.accessibilityOptions,
    this.reviews,
  });

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);

  Map<String, dynamic> toJson() => _$PlaceToJson(this);
}

@JsonSerializable()
class AddressComponent {
  @JsonKey(name: 'longText')
  final String? longText;

  @JsonKey(name: 'shortText')
  final String? shortText;

  @JsonKey(name: 'types')
  final List<String>? types;

  @JsonKey(name: 'languageCode')
  final String? languageCode;

  AddressComponent({
    this.longText,
    this.shortText,
    this.types,
    this.languageCode,
  });

  factory AddressComponent.fromJson(Map<String, dynamic> json) =>
      _$AddressComponentFromJson(json);

  Map<String, dynamic> toJson() => _$AddressComponentToJson(this);
}

@JsonSerializable()
class Viewport {
  @JsonKey(name: 'low')
  final LatLngNew? low;

  @JsonKey(name: 'high')
  final LatLngNew? high;

  Viewport({this.low, this.high});

  factory Viewport.fromJson(Map<String, dynamic> json) => _$ViewportFromJson(json);

  Map<String, dynamic> toJson() => _$ViewportToJson(this);
}

@JsonSerializable()
class LatLngNew {
  @JsonKey(name: 'latitude')
  final double? latitude;

  @JsonKey(name: 'longitude')
  final double? longitude;

  LatLngNew({this.latitude, this.longitude});

  factory LatLngNew.fromJson(Map<String, dynamic> json) => _$LatLngNewFromJson(json);

  Map<String, dynamic> toJson() => _$LatLngNewToJson(this);
}

@JsonSerializable()
class DisplayName {
  @JsonKey(name: 'text')
  final String? text;

  @JsonKey(name: 'languageCode')
  final String? languageCode;

  DisplayName({this.text, this.languageCode});

  factory DisplayName.fromJson(Map<String, dynamic> json) => _$DisplayNameFromJson(json);

  Map<String, dynamic> toJson() => _$DisplayNameToJson(this);
}

@JsonSerializable()
class AccessibilityOptions {
  @JsonKey(name: 'wheelchairAccessibleParking')
  final bool? wheelchairAccessibleParking;

  @JsonKey(name: 'wheelchairAccessibleEntrance')
  final bool? wheelchairAccessibleEntrance;

  AccessibilityOptions({
    this.wheelchairAccessibleParking,
    this.wheelchairAccessibleEntrance,
  });

  factory AccessibilityOptions.fromJson(Map<String, dynamic> json) =>
      _$AccessibilityOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$AccessibilityOptionsToJson(this);
}

@JsonSerializable()
class Review {
  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'relativePublishTimeDescription')
  final String? relativePublishTimeDescription;

  @JsonKey(name: 'rating')
  final int? rating;

  @JsonKey(name: 'text')
  final ReviewText? text;

  @JsonKey(name: 'originalText')
  final ReviewText? originalText;

  @JsonKey(name: 'authorAttribution')
  final AuthorAttribution? authorAttribution;

  @JsonKey(name: 'publishTime')
  final String? publishTime;

  Review({
    this.name,
    this.relativePublishTimeDescription,
    this.rating,
    this.text,
    this.originalText,
    this.authorAttribution,
    this.publishTime,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}

@JsonSerializable()
class ReviewText {
  @JsonKey(name: 'text')
  final String? text;

  @JsonKey(name: 'languageCode')
  final String? languageCode;

  ReviewText({this.text, this.languageCode});

  factory ReviewText.fromJson(Map<String, dynamic> json) => _$ReviewTextFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewTextToJson(this);
}

@JsonSerializable()
class AuthorAttribution {
  @JsonKey(name: 'displayName')
  final String? displayName;

  @JsonKey(name: 'uri')
  final String? uri;

  @JsonKey(name: 'photoUri')
  final String? photoUri;

  AuthorAttribution({
    this.displayName,
    this.uri,
    this.photoUri,
  });

  factory AuthorAttribution.fromJson(Map<String, dynamic> json) =>
      _$AuthorAttributionFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorAttributionToJson(this);
}
