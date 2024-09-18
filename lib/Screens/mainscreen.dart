import 'package:flutter/material.dart';
import 'package:wheel_and_meal/Screens/search.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "W & M",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: "Raleway",
                      fontSize: 30,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    Search(),
                            transitionDuration: Duration
                                .zero, // No transition duration (immediate)
                            reverseTransitionDuration:
                                Duration.zero, // No reverse transition
                          ),
                        );
                      },
                      child: AbsorbPointer(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextFormField(
                            readOnly: true,
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              hintStyle: TextStyle(
                                fontFamily: "Raleway",
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              hintText: "Searching for?",
                              border: InputBorder.none,
                              icon: Icon(
                                Icons.search_sharp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
