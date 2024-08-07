import 'package:json_annotation/json_annotation.dart';

part 'TravelDestinations.g.dart'; // This file will be generated

@JsonSerializable()
class TravelDestinations {
  @JsonKey(name: 'Title')
  final String title;

  @JsonKey(name: 'Places')
  final List<Destinations> Dest;

  TravelDestinations({
    required this.title,
    required this.Dest,
  });

  factory TravelDestinations.fromJson(Map<String, dynamic> json) =>
      _$TravelDestinationsFromJson(json);

  Map<String, dynamic> toJson() => _$TravelDestinationsToJson(this);
}

@JsonSerializable()
class Destinations {
  @JsonKey(name: 'Name')
  final String name;

  @JsonKey(name: 'Description')
  final String description;

  @JsonKey(name: 'Address')
  final String address;

  @JsonKey(name: 'City')
  final String city;

  Destinations({
    required this.name,
    required this.description,
    required this.address,
    required this.city,
  });

  factory Destinations.fromJson(Map<String, dynamic> json) => _$DestinationsFromJson(json);

  Map<String, dynamic> toJson() => _$DestinationsToJson(this);
}
