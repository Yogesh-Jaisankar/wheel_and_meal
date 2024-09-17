import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for formatting dates
import 'package:lottie/lottie.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
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
  String? memberSinceDate;

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PhoneInputPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    phoneNumber = prefs.getString('phoneNumber');

    // Load name and member since date from SharedPreferences
    name = prefs.getString('name');
    memberSinceDate = prefs.getString('memberSinceDate');

    // If phone number is not null and user data is not loaded, fetch from database
    if (phoneNumber != null && name == null && memberSinceDate == null) {
      await _fetchUserDetails(phoneNumber!);
    }

    setState(() {});
  }

  Future<void> _fetchUserDetails(String phoneNumber) async {
    var db = await mongo.Db.create(
        "mongodb+srv://yogesh:7806@cluster0.4lglk.mongodb.net/Users?retryWrites=true&w=majority&appName=Cluster0");
    await db.open();
    var collection = db.collection('users');

    try {
      var user = await collection.findOne({'_id': phoneNumber});

      if (user != null) {
        setState(() {
          name = user['name']; // Update the state with the user name

          // Check if the user has a createdAt field
          if (user['createdAt'] is DateTime) {
            DateTime memberSince = user['createdAt']; // This is a DateTime
            memberSinceDate = DateFormat('MMMM yyyy')
                .format(memberSince); // Format it to "Month Year"
          } else {
            memberSinceDate = "Unknown"; // Handle missing or incorrect field
          }
        });

        // Save user data to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', name!);
        await prefs.setString('memberSinceDate', memberSinceDate!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User details not found')),
        );
      }
    } catch (e) {
      // Error handling if something goes wrong with fetching data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user details: $e')),
      );
    } finally {
      await db.close();
    }
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
                          Colors.black,
                          Colors.grey.shade800,
                          Colors.grey.shade600,
                          Colors.black,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5), // Shadow color
                          offset:
                              Offset(0, 4), // X and Y offsets for the shadow
                          blurRadius: 8, // Amount of blur
                          spreadRadius: 2, // How much the shadow spreads
                        ),
                      ],
                    ),
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
                                    memberSinceDate != null
                                        ? "Member since $memberSinceDate"
                                        : "Loading...",
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
                GestureDetector(
                  onTap: () {
                    toastification.show(
                      alignment: Alignment.bottomCenter,
                      context:
                          context, // optional if you use ToastificationWrapper
                      title: Text('To be imlemented!'),
                      type: ToastificationType.warning,
                      showProgressBar: false,
                      autoCloseDuration: const Duration(seconds: 2),
                    );
                  },
                  child: ListTile(
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
                ),
                GestureDetector(
                  onTap: () {
                    toastification.show(
                      alignment: Alignment.bottomCenter,
                      context:
                          context, // optional if you use ToastificationWrapper
                      title: Text('To be imlemented!'),
                      type: ToastificationType.warning,
                      showProgressBar: false,
                      autoCloseDuration: const Duration(seconds: 2),
                    );
                  },
                  child: ListTile(
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
