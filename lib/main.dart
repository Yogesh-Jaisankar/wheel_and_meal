import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheel_and_meal/Screens/home.dart';

import 'Screens/PhoneAuth.dart'; // Import your home screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wheel And Meal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.white),
      // home: Home(),
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          // Show a loading indicator while checking the status
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            // Navigate to the appropriate screen
            if (snapshot.data == true) {
              return Home(); // User is logged in
            } else {
              return PhoneInputPage(); // User needs to log in
            }
          }
        },
      ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false; // Default to false if not set
  }
}
