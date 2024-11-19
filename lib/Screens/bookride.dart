import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Bookride extends StatefulWidget {
  const Bookride({super.key});

  @override
  State<Bookride> createState() => _BookrideState();
}

class _BookrideState extends State<Bookride> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Column(
              children: [
                Lottie.asset("assets/rider_Search.json"),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Waiting for our drivers to accept your ride...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: "Raleway",
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
