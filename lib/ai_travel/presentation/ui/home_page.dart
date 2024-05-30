import 'package:flutter/material.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/string/String.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/theme/app_theme.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/presentation/widgets/app_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: Drawer(
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
      ),
      body: const Center(
        child: Text(
          Strings.noCitiesAdded,
          style: TextStyle(color: Colors.white54),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: FloatingActionButton.extended(
          onPressed: () {},
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
