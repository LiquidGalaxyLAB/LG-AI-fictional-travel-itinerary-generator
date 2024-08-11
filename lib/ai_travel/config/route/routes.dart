import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/ui/main_screens/google_map/google_maps.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/ui/main_screens/home_page.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/ui/main_screens/splash_screen.dart';
import 'package:lg_ai_travel_itinerary/main.dart';

import '../../core/utils/constants.dart';
import '../../presentation/ui/main_screens/about_page.dart';
import '../../presentation/ui/main_screens/add_city.dart';
import '../../presentation/ui/main_screens/generated_sub_poi_page.dart';
import '../../presentation/ui/main_screens/google_map/google_map_subPoi.dart';
import '../../presentation/ui/main_screens/settings_screen.dart';
import '../../presentation/ui/side_nav_screens/galaxy_management.dart';

const String splashScreen = '/';
const String homePage = '/homePage';
const String addCityPage = '/addCity';
const String settingsPage = '/settings';
const String galaxyManagementPage = '/galaxyManagement';
const String generatedSubPoiPage = '/generatedSubPoiPage';
const String googleMapPage = '/googleMap';
const String aboutPage = '/about';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings){
    switch(settings.name){
      case splashScreen:
        return _materialRoute(const SplashScreen());
      case homePage:
        return _fadeRoute(HomePage());
      case addCityPage:
        return _fadeRoute(const AddCity());
      case settingsPage:
        return _materialRoute( const ConnectionScreen());
      case galaxyManagementPage:
        return SlidingPageRoute(page: const LiquidGalaxyManagement());
      case aboutPage:
        return _materialRoute(AboutPage());
      case googleMapPage:
        return SlidingPageRoute(page: const GoogleMapsPage());
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
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => view,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Define the slide animation
        const begin = Offset(1.0, 0.0); // Slide in from the right
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var slideTween = Tween(begin: begin, end: end);
        var slideAnimation = animation.drive(slideTween.chain(CurveTween(curve: curve)));

        // Define the fade animation for exit
        const fadeBegin = 1.0;
        const fadeEnd = 0.0;
        var fadeTween = Tween(begin: fadeBegin, end: fadeEnd);
        var fadeAnimation = secondaryAnimation.drive(fadeTween.chain(CurveTween(curve: curve)));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300), // Adjust duration as needed
    );
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

class SlidingPageRoute extends PageRouteBuilder {
  final Widget page;
  SlidingPageRoute({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // Start off-screen to the right
      const end = Offset.zero; // End at the normal position
      const curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end);
      var offsetAnimation = animation.drive(tween.chain(CurveTween(curve: curve)));

      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}


