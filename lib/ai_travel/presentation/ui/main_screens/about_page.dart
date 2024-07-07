import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/widgets/app_bar.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double firstLogoWidth = width * 0.20;
    double firstLogoHeight = height * 0.20;
    double logoWidth = width * 0.15;
    double logoHeight = height * 0.15;
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Center(
            child: Image.asset(
              "assets/images/lg_logos/lg-ai-fictional-groq.png",
              width: firstLogoWidth,
              height: firstLogoHeight,
            ),
          ),
          SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/lg_logos/line_2/logo_liquid_galaxy.png",
                width: logoWidth,
                height: logoHeight,
              ),
              Image.asset(
                "assets/images/lg_logos/line_2/gsoc.png",
                width: logoWidth,
                height: logoHeight,
              ),
              Image.asset(
                "assets/images/lg_logos/line_2/twnty_years_gsoc.png",
                width: logoWidth,
                height: logoHeight,
              ),
            ],
          ),
          SizedBox(height: 20),
          //Line 3
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/lg_logos/line_3/flutter_lleida.png",
                width: logoWidth,
                height: logoHeight,
              ),
              Image.asset(
                "assets/images/lg_logos/line_3/flutter_lleida_sq.png",
                width: logoWidth,
                height: logoHeight,
              ),
              Image.asset(
                "assets/images/lg_logos/line_3/Parc_.png",
                width: logoWidth,
                height: logoHeight,
              ),
              Image.asset(
                "assets/images/lg_logos/line_3/parc_lab.png",
                width: logoWidth,
                height: logoHeight,
              ),
            ],
          )

        ],
      ),
    );
  }
}
