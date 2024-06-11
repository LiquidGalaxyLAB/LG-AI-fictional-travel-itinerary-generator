import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/ui/main_screens/home_page.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/ui/main_screens/splash_screen.dart';
import 'package:lg_ai_travel_itinerary/main.dart';

import '../../presentation/ui/main_screens/add_city.dart';
import '../../presentation/ui/main_screens/generated_sub_poi_page.dart';
import '../../presentation/ui/main_screens/settings_screen.dart';
import '../../presentation/ui/side_nav_screens/galaxy_management.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings){
    switch(settings.name){
      case '/':
        return _materialRoute(const SplashScreen());
      case '/homePage':
        return _fadeRoute(HomePage());
      case '/addCity':
        return _fadeRoute(const AddCity());
      case '/settings':
        return _fadeRoute(const ConnectionScreen());
      case '/galaxyManagement':
        return _materialRoute(const LiquidGalaxyManagement());
      /*case '/generatedSubPoiPage':
        return _materialRoute(const GeneratedSubPoiPage());*/
      default:
        return _materialRoute(const MyApp());
    }
  }
  static Route<dynamic> _fadeRoute(Widget view) {
    return FadeRoute(page: view);
  }
  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}

class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}
