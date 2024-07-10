import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/core/utils/Images.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/core/utils/extensions.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/ui/main_screens/splash_screen.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/widgets/app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/constants.dart';
import '../../../core/utils/text_styles.dart';
import '../../../utils/logo_shower.dart';
import '../../providers/connection_providers.dart';


class AboutPage extends ConsumerStatefulWidget {
  const AboutPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _AboutPageState();
}

class _AboutPageState extends ConsumerState<AboutPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((x) async {
      ref
          .read(isLoadingProvider.notifier)
          .state = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          child: Column(
            children: [
              SizedBox(height: Const.appBarHeight),
              AnimationLimiter(
                child: Column(
                  children: AnimationConfiguration.toStaggeredList(
                    duration: Const.animationDuration,
                    childAnimationBuilder: (widget) =>
                        SlideAnimation(
                          horizontalOffset: -Const.animationDistance,
                          child: FadeInAnimation(child: widget),
                        ),
                    children: [
                      _buildHeader(),
                      SizedBox(height: 50),
                      _buildDescription(),
                      SizedBox(height: 30),
                      _buildLinks(),
                      SizedBox(height: 30),
                      Divider(
                          thickness: 1, color: Colors.white.withOpacity(0.5)),
                      SizedBox(height: 20),
                      ShowLogos()
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        // Add a subtle background color
        borderRadius: BorderRadius.circular(Const.dashboardUIRoundness),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AssetLogoShower(logo: ImageConst.appLogo, size: 140),
            Text(
              'LG AI TRAVEL ITINERARY',
              style: TextStyle(
                fontSize: 35, // Slightly smaller for better fit
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent, // Add color to the text
              ),
            ),
            const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Text(
        '''
        The Travel Adventures App aims to simplify the travel planning process by providing users with engaging fictional stories tailored to their interests around specific Points of Interest (POIs). Powered by the Groq AI model, users can generate personalized stories that inspire and inform their travel decisions. The app also integrates tour recommendations and real-time visualization of POIs using Google Maps, enhancing the user experience.
        ''',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16), // Adjust font size
      ),
    );
  }

  Widget _buildLinks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        children: [
          Row(
            children: [
              _buildLinkCard(
                icon: Icons.code,
                text: 'Project GitHub',
                url: 'https://github.com/LiquidGalaxyLAB/LG-AI-fictional-travel-itinerary-generator',
              ),
              SizedBox(width: 10),
              _buildLinkCard(
                icon: Icons.web,
                text: 'Liquid Galaxy Site',
                url: 'https://www.liquidgalaxy.eu/',
              ),
              SizedBox(width: 10),
              _buildLinkCard(
                icon: Icons.link,
                text: 'LinkedIn',
                url: 'https://www.linkedin.com/in/rohit115/',
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildInfoCard(
            title: 'Made with Love by',
            subtitle: 'Rohit',
          ),
          _buildInfoCard(
            title: 'Organization',
            subtitle: 'Liquid Galaxy',
          ),
          _buildInfoCard(
            title: 'LG Lab Tester',
            subtitle: 'LG Lab Testers',
          ),
          _buildInfoCard(
            title: 'Mentor',
            subtitle: 'Merul Dhiman',
          ),
          _buildInfoCard(
            title: 'Organization Admin',
            subtitle: 'Andrew',
          ),
        ],
      ),
    );
  }

  Widget _buildLinkCard(
      {required IconData icon, required String text, required String url}) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        color: Color(0xFF1A1A2E), // Darker card color
        child: InkWell(
          onTap: () => launch(url), // Assuming you have a method to launch URLs
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 30, color: Colors.tealAccent),
                // Accent color for icons
                SizedBox(height: 10),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors
                        .white, // Text color to contrast with card color
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String subtitle}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 5),
      color: Color(0xFF1A1A2E),
      // Darker card color
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(Icons.info, size: 30, color: Colors.tealAccent),
            // Accent color for icons
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors
                        .white, // Text color to contrast with card color
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70, // Subtle text color for subtitles
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


  Widget _buildInfoCard({required String title, required String subtitle}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(Icons.info, size: 30, color: Colors.blueAccent),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildLogosRow1() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        AboutLogoShower(logo: ImageConst.gsoc, height: 100, width: 200),
        AboutLogoShower(logo: ImageConst.lg, height: 100, width: 200),
        AboutLogoShower(logo: ImageConst.flutter, height: 100, width: 230),
      ],
    );
  }

  Widget _buildLogosRow2() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          AboutLogoShower(logo: ImageConst.lgEU, height: 100, width: 210),
          AboutLogoShower(logo: ImageConst.lgLab, height: 100, width: 200),
          AboutLogoShower(logo: ImageConst.gdg, height: 100, width: 200),
        ],
      ),
    );
  }

  Widget _buildLogosRow3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          AboutLogoShower(logo: ImageConst.parcLleida, height: 100, width: 200),
        ],
      ),
    );
  }

class UrlLauncher extends StatelessWidget {
  const UrlLauncher({super.key, required this.text, required this.url});

  final String text;
  final String url;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () async => await launchUrl(Uri.parse(url)),
      child: Text(
        text,
        style: textStyleNormal.copyWith(fontSize: 17, color: Colors.blue),
      ),
    );
  }
}

class AboutText extends ConsumerWidget {
  const AboutText({super.key, required this.text1, required this.text2});

  final String text1;
  final String text2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text1,
          style: textStyleNormal.copyWith(fontSize: 17, color: Colors.green),
        ),
        Text(
          ': ',
          style: textStyleNormal.copyWith(fontSize: 17, color: Colors.yellow),
        ),
        Expanded(
          child: Text(
            text2,
            style: textStyleNormal.copyWith(fontSize: 17),
          ),
        ),
      ],
    );
  }
}
