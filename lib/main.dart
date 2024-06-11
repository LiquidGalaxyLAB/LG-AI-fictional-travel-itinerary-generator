import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/theme/app_theme.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/ui/main_screens/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'ai_travel/config/route/routes.dart';
import 'ai_travel/injection_container.dart';

void main() async{
  await initializeDependencies();
  WidgetsFlutterBinding.ensureInitialized();
  try{
    await dotenv.load(fileName: "keys.env");
  } catch (e) {
    print("Please create keys.env file in the root repository and also in pubspec.yaml file");
  }
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft])
      .then((_) {
    runApp(const ProviderScope(child: MyApp()));
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LG AI travel itinerary',
      theme: appTheme(),
      onGenerateRoute: AppRoutes.onGenerateRoutes,
      home: const SplashScreen(),
    );
  }
}
