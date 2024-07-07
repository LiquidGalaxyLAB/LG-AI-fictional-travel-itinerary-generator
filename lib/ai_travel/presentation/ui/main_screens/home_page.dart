import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:groq/groq.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/route/routes.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/string/String.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/theme/app_theme.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/model/GroqModel.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/ui/main_screens/add_city.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/widgets/app_bar.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/widgets/destination_card.dart';

import '../../../data/model/destination.dart';
import '../../../data/service/apiService.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(isHomePage: true),
      drawer: const DrawerWidget(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemCount: _generateDefaultVisitingLocationList().length,
          itemBuilder: (context, index) {
            return DestinationCard(
              index: index,
              onPressed: (){
                switch(index){
                  case 0:
                    _navigateToAddCity(context, "Agra");
                    break;

                  case 1:
                    _navigateToAddCity(context, "Madrid");
                    break;

                  case 2:
                    _navigateToAddCity(context, "Mumbai");
                    break;

                  case 3:
                    _navigateToAddCity(context, "Greenland");
                    break;

                  case 4:
                    _navigateToAddCity(context, "Canada");
                    break;

                  case 5:
                    _navigateToAddCity(context, "Bangalore");
                    break;
                }
              },
              destination: _generateDefaultVisitingLocationList()[index],
            );
          },
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, '/addCity');
          },
          label: const Text(
            'Add city',
            style: TextStyle(color: Colors.white),
          ),
          icon: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: AppColors.tertiaryColor,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
  List<Destination> _generateDefaultVisitingLocationList(){
    return [
      Destination(
        image: 'assets/images/travel/taj.jpg',
        title: 'Taj Mahal',
        location: 'Agra, UP, India',
        coordinates: '27.1751° N, 78.0421° E',
        description: 'One of the most iconic monuments in India, known for its stunning architecture and history.',
      ),
      Destination(
        image: 'assets/images/travel/spain.jpg',
        title: 'Madrid',
        location: 'Spain',
        coordinates: '40.4168° N, 3.7038° W',
        description: 'The capital of Spain, known for its rich cultural heritage, beautiful architecture, and vibrant nightlife.',
      ),
      Destination(
        image: 'assets/images/travel/gatewayofindia.jpg',
        title: 'Gateway of India',
        location: 'Mumbai, Maharashtra, India',
        coordinates: '18.9220° N, 72.8347° E',
        description: 'A grand monument in Mumbai that overlooks the Arabian Sea, built during the British Raj.',
      ),
      Destination(
        image: 'assets/images/travel/ladakh.jpg',
        title: 'Ilulissat',
        location: 'Greenland',
        coordinates: '69.2193° N, 51.0986° W',
        description: 'A town in western Greenland, famous for its stunning ice fjord, colorful houses, and Arctic experiences.',
      ),
      Destination(
        image: 'assets/images/travel/manali.jpg',
        title: 'Canada',
        location: 'North America',
        coordinates: '56.1304° N, 106.3468° W',
        description: 'A vast and diverse country known for its natural beauty, multicultural cities, and outdoor adventures.',
      ),
      Destination(
        image: 'assets/images/travel/banglore.jpg',
        title: 'Bangalore',
        location: 'Karnataka, India',
        coordinates: '12.9716° N, 77.5946° E',
        description: 'The capital of Karnataka, known as the "Silicon Valley of India" for its thriving tech industry and pleasant climate.',
      ),
    ];
  }

  _navigateToAddCity(BuildContext context, String location) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddCity(initialText: location)));
  }
}


class DrawerWidget extends StatelessWidget {
  const DrawerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Container(
        color: const Color(0xff1E1E1E),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xff25253e)
              ),
              child: Text(
                Strings.appName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person,color: Colors.white,),
              title: Text('subPoiPage',style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushNamed(context, '/generatedSubPoiPage');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Iconsax.settings,color: Colors.white,),
              title: Text('Liquid Galaxy Management', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/galaxyManagement');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout,color: Colors.white,),
              title: Text('About', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about');
              },
            ),
            /*ListTile(
              leading: Icon(Iconsax.map,color: Colors.white,),
              title: Text('Map', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, googleMapPage);
              },
            )*/
          ],
        ),
      ),
    );
  }


}
