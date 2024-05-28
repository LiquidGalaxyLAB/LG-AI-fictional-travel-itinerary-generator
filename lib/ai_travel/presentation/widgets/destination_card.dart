import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/theme/app_theme.dart';

class DestinationCard extends StatelessWidget {
  final Image image;
  final String title;
  final String location;
  final String coordinates;
  final String description;

  DestinationCard({
    required this.image,
    required this.title,
    required this.location,
    required this.coordinates,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor, // Dark background color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Ensures height adjusts to content
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/taj.png', // Make sure this path is correct for your asset
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Agra',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'India',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.location_on, color: Colors.white70),
              SizedBox(width: 4),
              Text(
                '27.1751° N, 78.0421° E',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Once a bustling hub of the Mughal Empire, Agra stands as a timeless testament...',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor, // Button background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle,color: Colors.white,),
                SizedBox(width: 8),
                Text('Explore',style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


