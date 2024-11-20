import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class DriverDetailsScreen extends StatefulWidget {
  final String driverId;

  const DriverDetailsScreen({super.key, required this.driverId});

  @override
  State<DriverDetailsScreen> createState() => _DriverDetailsScreenState();
}

class _DriverDetailsScreenState extends State<DriverDetailsScreen> {
  late mongo.Db db;
  late mongo.DbCollection driversCollection;
  late GoogleMapController _mapController;
  late LatLng _driverLocation;

  Timer? _locationUpdateTimer;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  // Initialize MongoDB connection and fetch initial driver location
  Future<void> _initialize() async {
    try {
      // Initialize the MongoDB connection
      db = await mongo.Db.create(
          "mongodb+srv://wm:7806@wm.4lglk.mongodb.net/Drivers?retryWrites=true&w=majority&appName=wm");
      await db.open();
      driversCollection = db.collection('driver');

      // Fetch driver data
      final driver = await driversCollection.findOne({'_id': widget.driverId});

      if (driver != null) {
        setState(() {
          // Get the driver's initial location
          _driverLocation = LatLng(driver['latitude'], driver['longitude']);
        });
      }

      // Start periodic location updates
      _locationUpdateTimer = Timer.periodic(Duration(seconds: 25), (timer) {
        _updateDriverLocation();
      });
    } catch (e) {
      print('Error fetching driver details: $e');
    }
  }

  // Update driver location every 5 seconds
  Future<void> _updateDriverLocation() async {
    final driver = await driversCollection.findOne({'_id': widget.driverId});
    if (driver != null) {
      setState(() {
        _driverLocation = LatLng(driver['latitude'], driver['longitude']);
      });
      _mapController.animateCamera(
        CameraUpdate.newLatLng(_driverLocation),
      );
    }
  }

  @override
  void dispose() {
    // Cancel the periodic location updates when the screen is disposed
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Details"),
      ),
      body: _driverLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _driverLocation,
                zoom: 14.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              markers: {
                Marker(
                  markerId: MarkerId(widget.driverId),
                  position: _driverLocation,
                  infoWindow: InfoWindow(title: 'Driver Location'),
                ),
              },
            ),
    );
  }
}
