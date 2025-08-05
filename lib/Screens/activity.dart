import 'package:flutter/material.dart';

class Activity extends StatefulWidget {
  const Activity({super.key});

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          "A C T I V I T Y",
          style: TextStyle(
            fontSize: 20,
            fontFamily: "Raleway",
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: Icon(
                  Icons.directions_car,
                  color: Colors.blue,
                  size: 40,
                ),
                title: Text(
                  "Ride from VIT Chennai to Vandalur",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "A ride from VIT Chennai to Vandalur.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                trailing: Text(
                  "₹90",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
            // Pizza Order Activity
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: Icon(
                  Icons.fastfood,
                  color: Colors.orange,
                  size: 40,
                ),
                title: Text(
                  "Pizza Order",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "Ordered pizza for dinner.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                trailing: Text(
                  "₹350",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
