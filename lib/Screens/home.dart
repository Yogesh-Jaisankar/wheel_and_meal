import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:wheel_and_meal/Screens/activity.dart';
import 'package:wheel_and_meal/Screens/grocery.dart';
import 'package:wheel_and_meal/Screens/profile.dart';
import 'package:wheel_and_meal/Screens/rider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 0;
  List<IconData> data = [
    Icons.two_wheeler,
    Icons.shopping_basket,
    Icons.receipt_long,
    Icons.person_outline_sharp
  ];

  final List<Widget> pages = [
    Rider(),
    Grocery(),
    Activity(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "WHEEL  AND  MEAL",
          style: TextStyle(
              color: Colors.black87,
              fontFamily: "Raleway",
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: HexColor("#BB8FCE"),
      ),
      body: pages[selectedIndex], // Show the selected page
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20),
        child: Material(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 60,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(data.length, (i) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      HapticFeedback.heavyImpact();
                      selectedIndex = i;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 250),
                        width: 35,
                        height: 35,
                        child: Icon(
                          data[i],
                          size: 35,
                          color:
                              i == selectedIndex ? Colors.white : Colors.grey,
                        ),
                      ),
                      if (i == selectedIndex)
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        )
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
