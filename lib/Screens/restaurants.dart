import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

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
        elevation: 2,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          "Search for dishes & restaurants",
          style: TextStyle(
              fontSize: 18, fontFamily: "Raleway", fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
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
                              hintText: "Search for 'Tacos' .....",
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
          Expanded(
            child: ListView(
              physics: ClampingScrollPhysics(),
              children: [
                restaurantCard("Domino's Pizza", "Pizzas, Italian, Pastas",
                    "Selaiyur", "assets/icons/dominos.jpeg", 4.3, 12),
                restaurantCard("KFC", "Fried Chicken, Zinger, Wings",
                    "Kelambakkam", "assets/icons/kfc.jpeg", 4.1, 10),
                restaurantCard("Taco Bell", "Meals, Burritos, Quesadilla",
                    "Velachery", "assets/icons/taco.jpg", 4.5, 15),
                restaurantCard("Taco Bell", "Meals, Burritos, Quesadilla",
                    "Velachery", "assets/icons/taco.jpg", 4.5, 15),
                // Add more restaurant cards as needed
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget restaurantCard(String name, String description, String location,
      String imagePath, double rating, int reviews) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.heavyImpact();
          toastification.show(
            alignment: Alignment.bottomCenter,
            context: context,
            title: Text("Currently "),
            type: ToastificationType.success,
            style: ToastificationStyle.flatColored,
            showProgressBar: false,
            autoCloseDuration: const Duration(seconds: 2),
          );
        },
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
                      imagePath,
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
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
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
                            "$rating",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "($reviews.k+)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        description,
                        style: TextStyle(color: Colors.black87),
                      ),
                      SizedBox(height: 5),
                      Text(
                        location,
                        style: TextStyle(color: Colors.black87),
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
