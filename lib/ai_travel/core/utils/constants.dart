import 'package:lg_ai_travel_itinerary/ai_travel/data/model/MultiPlaceModel.dart';

class Const {
  static const overLayImageLink = 'https://raw.githubusercontent.com/Rohit-554/LaserSlidesFlutter/master/skml.png';
  static double appBarHeight = 80;
  static double tabBarWidthDivider = 5;
  static double longitude = 87.296992;
  static double latitude = 23.547625;
  static double heading = 0.0;
  static Duration animationDuration = const Duration(milliseconds: 375);
  static double animationDurationDouble = 375;
  static Duration screenshotDelay = const Duration(milliseconds: 1000);
  static double animationDistance = 50;
  static double dashboardUIRoundness = 20;
  static double dashboardUISpacing = 10;
  static double dashboardUIHeightFactor = 0.65;
  static double tilt = 0.0;
  static double range = 11;
  static double splashAspectRatio = 2864 / 3000;
  static double lgZoomScale = 130000000.0;
  static double appZoomScale = 11;
  static double tourZoomScale = 16;
  static double orbitZoomScale = 13;
  static double defaultZoomScale = 2;
  static List<String> availableLanguages = [
    'English',
    'Spanish',
    'Russian',
    'French',
    'Greek',
    'Swedish',
    'German',
  ];
  static List<String> availableLanguageCodes = [
    'en',
    'es',
    'ru',
    'fr',
    'el',
    'sv',
    'de',
  ];

  static List<String> testPrompts = [
    'Provide details about one eating place in \$city including its name, the place accurate coordinates in array format, and a brief description in JSON format. No Markdown.',
    'create interlinked story about five famous places to visit in \$city. Please provide a response in a structured JSON format that matches the following model: ${Places} containing name,description of the story,address for all, and a single very short overall `title`. No Markdown.',
    'Provide details about a famous place to visit in \$city. Format the information in JSON as follows:\n{\n  "name": "Place Name",\n  "address": "Place Address",\n  "description": "Brief Description"\n}. No Markdown.',
    "Give a famous place to visit in \$city. Include its name, precise address and a brief description in JSON format. No Markdown.",
    "Tell me about a restaurant in \$city. Include its name, address, and a brief description in JSON format. No Markdown.",
    "Provide details about a restaurant in \$city. Include its name, address, and a brief description in JSON format. No Markdown.",
  ];
}