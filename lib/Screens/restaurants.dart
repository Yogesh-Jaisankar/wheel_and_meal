import 'package:flutter/material.dart';

class Restaurants extends StatefulWidget {
  const Restaurants({super.key});

  @override
  State<Restaurants> createState() => _RestaurantsState();
}

//commit
class _RestaurantsState extends State<Restaurants> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          "R E S T A U R A N T S",
          style: TextStyle(
              fontSize: 20, fontFamily: "Raleway", fontWeight: FontWeight.bold),
        ),
        // actions: [
        //   Lottie.asset("assets/userlogo.json", fit: BoxFit.cover),
        // ],
      ),
      body: Center(
        child: Text("Restaurants"),
      ),
    );
  }
}
