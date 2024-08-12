import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                            color: Colors.lightGreen,
                            borderRadius: BorderRadius.circular(50))),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                      child: TextField(
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Raleway"),
                              hintText: "Enter Your Current Location"))),
                ],
              ),
            ),
          )
        ],
      ),
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
