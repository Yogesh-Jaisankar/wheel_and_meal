import 'package:flutter/material.dart';

class Grocery extends StatefulWidget {
  const Grocery({super.key});

  @override
  State<Grocery> createState() => _GroceryState();
}

class _GroceryState extends State<Grocery> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          " G R O C E R Y ",
          style: TextStyle(
              fontSize: 20, fontFamily: "Raleway", fontWeight: FontWeight.bold),
        ),
        // actions: [
        //   Lottie.asset("assets/userlogo.json", fit: BoxFit.cover),
        // ],
      ),
      body: Center(
        child: Text("groceries"),
      ),
    );
  }
}
