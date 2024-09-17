import 'package:flutter/material.dart';
import 'package:wheel_and_meal/Screens/PhoneAuth.dart';

class Onboard extends StatefulWidget {
  const Onboard({super.key});

  @override
  State<Onboard> createState() => _OnboardState();
}

class _OnboardState extends State<Onboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/icons/wm.png",
              height: 250,
              width: 250,
            ),
            Text(
              "Wheel And Meal",
              style: TextStyle(
                  fontSize: 40,
                  fontFamily: "Raleway",
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PhoneInputPage()), // Replace with your target page
                    (Route<dynamic> route) =>
                        false, // This clears all previous routes
                  );
                },
                child: Container(
                  height: 50,
                  width: 200,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                      child: Text(
                    "Get started",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Raleway",
                        fontSize: 20),
                  )),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
