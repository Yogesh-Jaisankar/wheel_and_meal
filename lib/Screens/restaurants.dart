import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shimmer/shimmer.dart';
import 'package:toastification/toastification.dart';

class Restaurants extends StatefulWidget {
  const Restaurants({super.key});

  @override
  State<Restaurants> createState() => _RestaurantsState();
}

class _RestaurantsState extends State<Restaurants> {
  List<dynamic> restaurants = [];
  List<dynamic> filteredRestaurants = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    final db = await mongo.Db.create(
        "mongodb+srv://wm:7806@wm.4lglk.mongodb.net/Res?retryWrites=true&w=majority&appName=wm");

    await db.open();
    final restaurantCollection = db.collection('Restaurants');

    try {
      final List<dynamic> fetchedRestaurants =
          await restaurantCollection.find().toList();
      setState(() {
        restaurants = fetchedRestaurants;
        filteredRestaurants = restaurants; // Initialize the filtered list
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      toastification.show(
        alignment: Alignment.bottomCenter,
        context: context,
        title: Text("Error fetching restaurants. Please try again."),
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: const Duration(seconds: 2),
      );
    } finally {
      await db.close();
    }
  }

  void filterRestaurants(String query) {
    setState(() {
      searchQuery = query;
      if (searchQuery.isEmpty) {
        filteredRestaurants = restaurants; // Show all if search is cleared
      } else {
        filteredRestaurants = restaurants
            .where((restaurant) =>
                restaurant['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        backgroundColor: Colors.black87,
        title: Text(
          "Search for dishes & restaurants",
          style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: "Raleway",
              fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? Center(
              child: Lottie.asset(
                'assets/res_load.json',
                width: 300,
                height: 300,
              ),
            )
          : Column(children: [
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
                            onChanged: filterRestaurants, // Search filter logic
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GestureDetector(
                          onTap: () {
                            // Clear search query and reset restaurant list
                            setState(() {
                              searchQuery = '';
                              filteredRestaurants = restaurants;
                            });
                          },
                          child: Icon(Icons.close),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.grey,
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
                child: filteredRestaurants.isEmpty
                    ? Center(
                        child: Text(
                          "No restaurants found",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredRestaurants.length,
                        itemBuilder: (context, index) {
                          final restaurant = filteredRestaurants[index];
                          return restaurantCard(
                            restaurant['name'],
                            restaurant['location']['address'],
                            restaurant['logo'],
                            restaurant['ratings']['rating'],
                            restaurant['ratings']['number_of_reviews'],
                          );
                        },
                      ),
              ),
            ]),
    );
  }

  Widget restaurantCard(String name, String location, String imagePath,
      dynamic rating, int reviews) {
    double finalRating = rating is int ? rating.toDouble() : rating;

    return Padding(
      padding: EdgeInsets.all(20.0),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.heavyImpact();
          toastification.show(
            alignment: Alignment.bottomCenter,
            context: context,
            title: Text("$name selected"),
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
                Positioned.fill(
                  child: Container(
                    width: 150,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.white,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 150,
                  height: 180,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                      )),
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
                            "$finalRating",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "($reviews reviews)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
