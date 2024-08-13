import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wheel_and_meal/Screens/activity.dart';
import 'package:wheel_and_meal/Screens/grocery.dart';
import 'package:wheel_and_meal/Screens/profile.dart';
import 'package:wheel_and_meal/Screens/rider.dart';

import 'restaurants.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 0;
  final List<IconData> icons = [
    Icons.two_wheeler,
    Icons.local_restaurant,
    Icons.shopping_basket,
    Icons.receipt_long,
    Icons.person_outline_sharp,
  ];

  final List<Widget> pages = [
    Rider(),
    Restaurants(),
    Grocery(),
    Activity(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: pages[selectedIndex],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Material(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 60,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(icons.length, (index) {
                      return _buildNavItem(index);
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          HapticFeedback.heavyImpact();
          selectedIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 35,
            height: 35,
            child: Icon(
              icons[index],
              size: 35,
              color: index == selectedIndex ? Colors.white : Colors.grey,
            ),
          ),
          if (index == selectedIndex)
            Container(
              margin: const EdgeInsets.only(top: 5),
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
