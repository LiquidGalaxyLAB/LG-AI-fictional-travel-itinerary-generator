import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:groq/groq.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/string/String.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/theme/app_theme.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/data/model/GroqModel.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/widgets/app_bar.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/widgets/destination_card.dart';

import '../../data/service/apiService.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    /*_getResponse();*/
    super.initState();
  }

  _getResponse() async {
    GroqModelNew? groqModelNew = await GroqApiService().sendPostRequest("Provide details about one eating place in Mumbai including its name, coordinates in array format, and a brief description in JSON format");
    var response = groqModelNew!.choices?[0].message?.content;
    // Remove "```json" from the beginning
    response = response?.substring(7);
    // Remove "```" from the end
    response = response?.substring(0, response.length - 3);
    Map<String, dynamic> jsonMap = jsonDecode(response!);
    Place place = Place.fromJson(jsonMap);
    print('Name: ${place.name}');
    print('Location: ${place.location}');
    print('Description: ${place.description}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
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
          itemCount: 6, // Total number of items (3 per row, 2 rows)
          itemBuilder: (context, index) {
            return DestinationCard(
              image: Image.asset('assets/images/taj.png'),
              title: "Taj Mahal",
              location: "UP, India",
              coordinates: "27.1751° N, 78.0421° E",
              description: "A historical monument in India.",
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
              leading: const Icon(Icons.home,color: Colors.white,),
              title: const Text('Home',style: TextStyle(color: Colors.white)),
              onTap: () {
                // Handle home navigation
              },
            ),
            ListTile(
              leading: Icon(Icons.person,color: Colors.white,),
              title: Text('Profile',style: TextStyle(color: Colors.white)),
              onTap: () {
                // Handle profile navigation
              },
            ),
            ListTile(
              leading: Icon(Icons.settings,color: Colors.white,),
              title: Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Handle settings navigation
              },
            ),
            ListTile(
              leading: Icon(Icons.logout,color: Colors.white,),
              title: Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Handle logout navigation
              },
            ),
          ],
        ),
      ),
    );
  }
}
