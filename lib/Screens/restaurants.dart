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
          "R E S T A U R A N T S",
          style: TextStyle(
              fontSize: 20, fontFamily: "Raleway", fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
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
            ],
          ),
        ),
      ),
    );
  }
}
