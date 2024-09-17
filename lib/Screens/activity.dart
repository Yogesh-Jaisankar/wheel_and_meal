import 'package:flutter/material.dart';

class Activity extends StatefulWidget {
  const Activity({super.key});

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          "A C T I V I T Y",
          style: TextStyle(
              fontSize: 20, fontFamily: "Raleway", fontWeight: FontWeight.bold),
        ),
        // actions: [
        //   Lottie.asset("assets/userlogo.json", fit: BoxFit.cover),
        // ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Text("Activity"),
      ),
    );
  }
}
