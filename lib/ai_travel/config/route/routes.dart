import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/ui/home_page.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/ui/splash_screen.dart';
import 'package:lg_ai_travel_itinerary/main.dart';

import '../../presentation/ui/settings_screen.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings){
    switch(settings.name){
      case '/':
        return _materialRoute(const SplashScreen());
      case '/homePage':
        return _fadeRoute(HomePage());
      case '/settings':
        return _fadeRoute(const ConnectionScreen());
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
