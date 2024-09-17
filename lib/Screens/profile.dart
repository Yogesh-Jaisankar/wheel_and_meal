import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mongo_dart/mongo_dart.dart'
    as mongo; // Adjust the import based on your directory structure
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheel_and_meal/Screens/PhoneAuth.dart';
import 'package:wheel_and_meal/Screens/edituserdetails.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? name;
  String? phoneNumber;

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
  void initState() {
    super.initState();
    _loadPhoneNumber(); // Load phone number on initialization
  }

  Future<void> _loadPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    phoneNumber = prefs.getString('phoneNumber'); // Retrieve phone number
    if (phoneNumber != null) {
      await _fetchUserDetails(phoneNumber!); // Fetch user details
    }
    setState(() {});
  }

  Future<void> _fetchUserDetails(String phoneNumber) async {
    var db = await mongo.Db.create(
        "mongodb+srv://yogesh:7806@cluster0.4lglk.mongodb.net/Users?retryWrites=true&w=majority&appName=Cluster0");
    await db.open();
    var collection = db.collection('users');

    // Query for the user with the given phone number
    var user = await collection.findOne({'_id': phoneNumber});

    if (user != null) {
      setState(() {
        name = user['name'];
      });
    } else {
      // Handle the case where user is not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User details not found')),
      );
    }

    await db.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          "Profile",
          style: TextStyle(fontSize: 30),
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
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black, // Start with black
                            Colors
                                .grey.shade800, // Dark grey for a subtle shine
                            Colors.grey.shade600, // Lighter grey for more shine
                            Colors
                                .black, // End with black for a smooth transition
                          ],
                          begin: Alignment
                              .topLeft, // Control the direction of the gradient
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all()),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name ?? "Loading...",
                                    style: TextStyle(
                                        fontSize: 30,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Raleway"),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Member since 2023",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Lottie.asset(
                            "assets/premium.json",
                          ),
                        )
                      ],
                    ),
                  ),
                ),
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
