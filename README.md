# LG AI travel itinerary

## Overview

Planning a vacation can be overwhelming with numerous options available. The Travel Adventures App aims to simplify the travel planning process by providing users with engaging fictional stories tailored to their interests around specific Points of Interest (POIs). Powered by the Groq AI model, users can generate personalized stories that inspire and inform their travel decisions. The app also integrates tour recommendations and real-time visualization of POIs using Google Maps, enhancing the user experience.

## Features

- **User-friendly Interface**: Easily input desired POIs through a search bar or map-based input system.
- **Interactive Storytelling**: Users can join in on the story as it develops, fostering a connection with the content.
- **POI Orbiting Functionality**: Seamless transition between POIs with real-time visualization on Google Maps.
- **Accessibility Feature**: Integrated speech to text for easy accessbility.

## Tech Stacks
- Utilizes Flutter for frontend development,
- Providers for state management,
- Gmaps for Google Maps integration,
- Dartssh2 for LG Rig integration,
- and Material 3 design system for improved UX.

## Usage

1. **Home Page**: Users can explore curated tour recommendations or input their desired POIs.
2. **Generate Story**: Enter desired POI and click generate to receive a personalized story crafted by the AI model.
3. **Interactive Experience**: Users can scroll through paragraphs or tap on specific sub-POIs to learn more.
4. **POI Orbiting**: Seamlessly transition between POIs with real-time visualization on Google Maps.
5. **Accessibility**: Users can give input using speech to text

## Screen shots
![HomePage](https://github.com/user-attachments/assets/81ce7b29-d3e5-4bec-95f0-4f10f438a267)
![TravelPage](https://github.com/user-attachments/assets/91729a89-3c24-4414-84d2-90a5cde00a53)
![ApiSettings](https://github.com/user-attachments/assets/0adefd5b-f11d-4e8c-985d-f8d220ae9301)
![AboutPage](https://github.com/user-attachments/assets/05bb6722-d950-42b9-b1e3-f29e7c9a7f85)

## Tech Stacks

### Frontend
- Flutter
- Providers (State Management)
- Translate (Language Support)
- Gmaps (Google Maps Integration)
- Material 3 (Design System)

### Backend
- Groq API (AI Model)

## Installation and contribution

1. Clone the repository.
2. Install Flutter and necessary dependencies.
3. Run `flutter pub get` to install dependencies.
4. Integrate necessary API keys for Groq, Gmaps, and other services.
5. Run the application on your preferred device or emulator.

<h2> Add Google Maps Key in Manifest </h2>h2
After cloning the project, follow these steps to add a Google Maps key:

- Obtain your Google Maps API key from the Google Cloud Console.

- Open the AndroidManifest.xml file in your Flutter project.

Add the following line inside the tag:

```
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```
Replace YOUR_GOOGLE_MAPS_API_KEY with your actual key.

- Go to [GroqApi](https://console.groq.com/keys) and create a key
- Go the setting in the app and add the key

Thankyou, Happy coding 😊
