import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

import 'driver_details.dart';

class Bookride extends StatefulWidget {
  final LatLng selectedLocation;
  final LatLng dropLOcation;
  final String rideRequestId; // Ride request ID passed from the previous screen

  const Bookride({
    super.key,
    required this.selectedLocation,
    required this.dropLOcation,
    required this.rideRequestId,
  });

  @override
  State<Bookride> createState() => _BookrideState();
}

class _BookrideState extends State<Bookride> {
  bool isPolling = true;

  @override
  void initState() {
    super.initState();
    pollRideStatus(widget.rideRequestId);
  }

  // Function to poll the ride status
  void pollRideStatus(String rideRequestId) async {
    var db = await mongo.Db.create(
        "mongodb+srv://wm:7806@wm.4lglk.mongodb.net/Users?retryWrites=true&w=majority&appName=wm");
    await db.open();
    var collection = db.collection('ride_requests');

    try {
      while (isPolling) {
        var rideRequest = await collection.findOne({"_id": rideRequestId});

        if (rideRequest != null && rideRequest["status"] == "accepted") {
          setState(() {
            isPolling = false;
          });

          // Navigate to the driver details screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DriverDetailsScreen(
                driverId: rideRequest["driver_id"],
              ),
            ),
          );
        }

        // Wait for a few seconds before polling again
        await Future.delayed(const Duration(seconds: 5));
      }
    } catch (e) {
      print("Error polling ride status: $e");
    } finally {
      await db.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset("assets/rider_Search.json"),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "Waiting for our drivers to accept your ride...",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Raleway",
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
