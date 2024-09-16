import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart'
    as mongo; // Using 'as mongo' for aliasing
import 'package:shared_preferences/shared_preferences.dart';

class UserDetailsEdit extends StatefulWidget {
  const UserDetailsEdit({super.key});

  @override
  State<UserDetailsEdit> createState() => _UserDetailsEditState();
}

class _UserDetailsEditState extends State<UserDetailsEdit> {
  String? phoneNumber;
  String? name;
  String? dob;

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
        dob = user['dob'];
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
        backgroundColor: Colors.white,
        title: Text(
          " WM™  Account",
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Name",
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    Text(
                      name ?? "Loading...", // Display loaded name
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w300,
                          fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Phone Number",
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    Row(
                      children: [
                        Text(
                          phoneNumber ??
                              "Loading...", // Display loaded phone number
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w300,
                              fontSize: 18),
                        ),
                        SizedBox(width: 5),
                        Center(
                          child: Icon(
                            Icons.verified_rounded,
                            color: Colors.green,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Date Of Birth",
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    Text(
                      dob ?? "Loading...", // Display loaded DOB
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w300,
                          fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
