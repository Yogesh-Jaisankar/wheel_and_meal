import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    await prefs.remove('phoneNumber'); // Clear stored phone number
    await prefs.remove('name'); // Clear stored name
    await prefs.remove('memberSinceDate'); // Clear member since date

    // Use pushReplacement to navigate to PhoneInputPage
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PhoneInputPage()), // Replace with your target page
      (Route<dynamic> route) => false, // This clears all previous routes
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

    name = prefs.getString('name');
    memberSinceDate = prefs.getString('memberSinceDate');

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
          name = user['name'];

          if (user['createdAt'] is DateTime) {
            DateTime memberSince = user['createdAt'];
            memberSinceDate = DateFormat('MMMM yyyy').format(memberSince);
          } else {
            memberSinceDate = "Unknown";
          }
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', name!);
        await prefs.setString('memberSinceDate', memberSinceDate!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User details not found')),
        );
      }
    } catch (e) {
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
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(0, 4),
                          blurRadius: 8,
                          spreadRadius: 2,
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
                      context: context,
                      title: Text('To be implemented!'),
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
                      context: context,
                      title: Text('To be implemented!'),
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
