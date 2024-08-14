import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/route/routes.dart';
import '../../widgets/app_bar.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () async {
    Navigator.pushReplacementNamed(context, '/homePage');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: SingleChildScrollView(
            child: ShowLogos(isSplashScreen: true,)
          )
      ),
    );
  }
}


class ShowLogos extends StatelessWidget {
  final bool isSplashScreen;

  ShowLogos({required this.isSplashScreen});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    double scale = isSplashScreen ? 0.8 : 0.8; // Adjust scale based on isSplashScreen

    return SizedBox(
      width: width * scale,
      height: height * scale,
      child: FittedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isSplashScreen) SizedBox(height: 16),
            Center(
              child: Image.asset(
                "assets/images/lg_logos/Lg_Ai_Travel_Itinerary.png",
                width: width * (isSplashScreen ? 0.3 : 0.5), // Adjust width based on isSplashScreen
                height: height * (isSplashScreen ? 0.3 : 0.5), // Adjust height based on isSplashScreen
              ),
            ),
            const SizedBox(height: 20),
             Text(
              "LG AI Travel Itinerary",
              style: GoogleFonts.kalam(
                fontSize: 50,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            // Line 2
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10.0,
              runSpacing: 10.0,
              children: [
                _buildImage("assets/images/lg_logos/line_2/Lg.png", width, height),
                _buildImage("assets/images/lg_logos/line_2/Gsoc.png", width, height, true),
                _buildImage("assets/images/lg_logos/line_2/twnty_years_gsoc.png", width, height),
              ],
            ),
            SizedBox(height: 20),
            // Line 3
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10.0,
              runSpacing: 10.0,
              children: [
                _buildImage("assets/images/lg_logos/line_3/LogoLGEU.png", width, height),
                _buildImage("assets/images/lg_logos/line_3/lg_lab.png", width, height, true),
                _buildImage("assets/images/lg_logos/line_3/flutter_lleida.png", width, height),
                _buildImage("assets/images/lg_logos/line_3/flutter_lleida_sq.png", width, height),
                _buildImage("assets/images/lg_logos/line_3/Parc_.png", width, height),
                _buildImage("assets/images/lg_logos/line_3/parc_lab.png", width, height),
              ],
            ),
            SizedBox(height: 20),
            // Line 4
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10.0,
              runSpacing: 10.0,
              children: [
                _buildImage("assets/images/lg_logos/line_4/build_with_ai.png", width, height),
                _buildImage("assets/images/lg_logos/line_4/groq_tm.png", width, height, true),
                _buildImage("assets/images/lg_logos/line_4/LiquidGalaxyAI.png", width, height),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String assetPath, double width, double height, [bool useBoxFitCover = false]) {
    return Image.asset(
      assetPath,
      width: width * 0.20,
      height: height * 0.20,
      fit: useBoxFitCover ? BoxFit.cover : BoxFit.contain,
    );
  }
}




