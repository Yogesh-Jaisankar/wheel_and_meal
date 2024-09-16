import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheel_and_meal/Screens/PhoneAuth.dart';
import 'package:wheel_and_meal/Screens/edituserdetails.dart'; // Adjust the import based on your directory structure

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Future<void> _logout() async {
    // Clear the authentication status
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false); // Set login status to false

    // Navigate back to the phone input page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PhoneInputPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        title: Text(
          "Yogesh",
          style: TextStyle(fontSize: 40),
        ),
        actions: [
          Lottie.asset("assets/userlogo.json", fit: BoxFit.cover),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SafeArea(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.electric_bike,
                    color: Colors.black87,
                    size: 30,
                  ),
                  title: Text(
                    "Rides",
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.shopping_basket_rounded,
                    color: Colors.black87,
                    size: 30,
                  ),
                  title: Text(
                    "Orders",
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserDetailsEdit()));
                  },
                  child: ListTile(
                    leading: Icon(
                      Icons.person,
                      color: Colors.black87,
                      size: 30,
                    ),
                    title: Text(
                      "Manage Your Account",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _logout();
                  },
                  child: ListTile(
                    leading: Icon(
                      Icons.key_rounded,
                      color: Colors.black87,
                      size: 30,
                    ),
                    title: Text(
                      "Logout",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
