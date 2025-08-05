import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'Screens/home.dart';

class AmountToPayPage extends StatelessWidget {
  final int fareAmount;

  const AmountToPayPage({super.key, required this.fareAmount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset("assets/premium.json"),
            Center(
              child: Text(
                "Fare Amount",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "₹$fareAmount",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Home(), // Replace with your home screen widget
                  ),
                  (route) => false,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 50,
                  width: 100,
                  decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(15)),
                  child: Center(
                    child: Text(
                      "Paid",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Raleway",
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
