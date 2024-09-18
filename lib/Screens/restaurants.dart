import 'package:flutter/material.dart';

class Restaurants extends StatefulWidget {
  const Restaurants({super.key});

  @override
  State<Restaurants> createState() => _RestaurantsState();
}

class _RestaurantsState extends State<Restaurants> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          "Search for dishes & restaurants",
          style: TextStyle(
              fontSize: 18, fontFamily: "Raleway", fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: TextField(
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: "Raleway"),
                            cursorColor: Colors.black87,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Raleway")),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Icon(Icons.close),
                    ),
                    // Vertical Divider
                    Container(
                      width: 1, // Fixed width for vertical divider
                      height: 30, // Height to match the icon size
                      color: Colors.grey, // Color of the divider
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Icon(
                        Icons.mic,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Container(
                    height: 180,
                    child: Row(
                      children: [
                        Stack(children: [
                          Container(
                            width: 150,
                            height: 180,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                "assets/icons/dominos.jpeg",
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Container(
                            height: 180,
                            width: 150,
                            decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          Positioned(
                              right: 10,
                              child: Icon(
                                Icons.favorite_rounded,
                                size: 30,
                                color: Colors.pink,
                              )),
                        ]),
                        Expanded(
                          // Use Expanded to avoid overflow issues
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Domino's Pizza",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.stars,
                                      color: Colors.lightGreen,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "4.3",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "(12.k+)",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Pizzas, Italian, Pastas",
                                  style: TextStyle(color: Colors.black87),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Selaiyur",
                                  style: TextStyle(color: Colors.black87),
                                ),
                                // SizedBox(height: 10),
                                // Divider(
                                //   color: Colors.grey,
                                //   thickness: 1,
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Container(
                    height: 180,
                    child: Row(
                      children: [
                        Stack(children: [
                          Container(
                            width: 150,
                            height: 180,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                "assets/icons/kfc.jpeg",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            height: 180,
                            width: 150,
                            decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          Positioned(
                              right: 10,
                              child: Icon(
                                Icons.favorite_rounded,
                                size: 30,
                                color: Colors.pink,
                              )),
                        ]),
                        Expanded(
                          // Use Expanded to avoid overflow issues
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "KFC",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.stars,
                                      color: Colors.lightGreen,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "4.1",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "(10.k+)",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Fried Chicken, Zinger, Wings",
                                  style: TextStyle(color: Colors.black87),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Kelambakkam",
                                  style: TextStyle(color: Colors.black87),
                                ),
                                // SizedBox(height: 10),
                                // Divider(
                                //   color: Colors.grey,
                                //   thickness: 1,
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Container(
                    height: 180,
                    child: Row(
                      children: [
                        Stack(children: [
                          Container(
                            width: 150,
                            height: 180,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                "assets/icons/taco.jpg",
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Container(
                            height: 180,
                            width: 150,
                            decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          Positioned(
                              right: 10,
                              child: Icon(
                                Icons.favorite_rounded,
                                size: 30,
                                color: Colors.pink,
                              )),
                        ]),
                        Expanded(
                          // Use Expanded to avoid overflow issues
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Taco Bell",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.stars,
                                      color: Colors.lightGreen,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "4.5",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "(15.k+)",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Meals, Burritos, Quesadila",
                                  style: TextStyle(color: Colors.black87),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Velachery",
                                  style: TextStyle(color: Colors.black87),
                                ),
                                // SizedBox(height: 10),
                                // Divider(
                                //   color: Colors.grey,
                                //   thickness: 1,
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
