import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
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
            child: ShowLogos()
          )
      ),
    );
  }

}


class ShowLogos extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          Center(
            child: Image.asset(
              "assets/images/lg_logos/lg-ai-fictional-groq.png",
              width: width * 0.4,
              height: height * 0.2,
            ),
          ),
          SizedBox(height: 20),
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
      );
  }
  Widget _buildImage(String assetPath, double width, double height, [bool useBoxFitCover = false]) {
    return Image.asset(
      assetPath,
      width: width * 0.15,
      height: height * 0.15,
      fit: useBoxFitCover ? BoxFit.cover : BoxFit.contain,
    );
  }

}