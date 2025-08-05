import 'dart:async';
import 'dart:math'; // For generating the random OTP

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

import '../AmountToPay.dart';
// Import the payment page

class DriverDetailsScreen extends StatefulWidget {
  final String driverId;
  final String requestId;

  const DriverDetailsScreen({
    super.key,
    required this.driverId,
    required this.requestId,
  });

  @override
  State<DriverDetailsScreen> createState() => _DriverDetailsScreenState();
}

class _DriverDetailsScreenState extends State<DriverDetailsScreen> {
  late mongo.Db db;
  late mongo.DbCollection driversCollection;
  late mongo.DbCollection rideRequestsCollection;
  late GoogleMapController _mapController;
  LatLng _driverLocation = LatLng(0.0, 0.0);
  String _otpCode = '';

  Timer? _locationUpdateTimer;
  Timer? _navigationTimer; // Timer to navigate to payment page

  @override
  void initState() {
    super.initState();
    _initialize();
    _generateOtpCode();

    // Set a timer to navigate to the AmountToPayPage after 10 seconds
    _navigationTimer = Timer(Duration(seconds: 10), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AmountToPayPage(
            fareAmount: 90,
          ),
        ),
      );
    });
  }

  Future<void> _initialize() async {
    try {
      // Initialize MongoDB connection for Drivers database
      var db1 = await mongo.Db.create(
          "mongodb+srv://wm:7806@wm.4lglk.mongodb.net/Drivers?retryWrites=true&w=majority&appName=wm");
      await db1.open();
      driversCollection = db1.collection('driver');

      // Initialize MongoDB connection for Users database
      var db2 = await mongo.Db.create(
          "mongodb+srv://wm:7806@wm.4lglk.mongodb.net/Users?retryWrites=true&w=majority&appName=wm");
      await db2.open();
      rideRequestsCollection = db2.collection('ride_requests');

      // Fetch driver data
      final driver = await driversCollection.findOne({'_id': widget.driverId});
      if (driver != null) {
        setState(() {
          _driverLocation = LatLng(driver['latitude'], driver['longitude']);
        });
      }

      _locationUpdateTimer = Timer.periodic(Duration(seconds: 10), (timer) {
        _updateDriverLocation();
      });
    } catch (e) {
      print('Error fetching driver details: $e');
    }

    _storeOtpInRideRequest();
  }

  Future<void> _storeOtpInRideRequest() async {
    try {
      final result = await rideRequestsCollection.updateOne(
        mongo.where.eq('_id', widget.requestId),
        mongo.modify.set('otp_code', _otpCode),
      );

      if (result.isAcknowledged) {
        print('OTP stored successfully.');
      }
    } catch (e) {
      print('Error storing OTP: $e');
    }
  }

  void _generateOtpCode() {
    final random = Random();
    setState(() {
      _otpCode = (1000 + random.nextInt(9000)).toString();
    });
  }

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
    _locationUpdateTimer?.cancel();
    _navigationTimer?.cancel(); // Cancel the navigation timer
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
          : Stack(
              children: [
                GoogleMap(
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
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _otpCode,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
