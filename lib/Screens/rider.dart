import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:lottie/lottie.dart' as Lot;
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'package:wheel_and_meal/Screens/dest_search.dart';
import 'package:wheel_and_meal/Screens/start_search.dart';

import 'bookride.dart';

class Rider extends StatefulWidget {
  final LatLng selectedLocation;
  final String pickupAddress;
  final String dropAddress;
  final LatLng dropLOcation;
  const Rider({
    Key? key,
    required this.selectedLocation,
    required this.pickupAddress,
    required this.dropAddress,
    required this.dropLOcation,
  }) : super(key: key);

  @override
  State<Rider> createState() => _RiderState();
}

//commit

class _RiderState extends State<Rider> {
  late GoogleMapController _mapController;
  LatLng? _currentLocation;
  LatLng? _searchedLocation;
  bool _loading = true;
  bool _suggestionsLoading = false;
  List<dynamic> _suggestions = [];
  final TextEditingController _searchController = TextEditingController();
  final String _apiKey =
      'AIzaSyA2Nqezz1idcqRvJRXEu68O7t2aJC99Tyw'; // Replace with your API key
  Set<Polyline> _polylines = {};

  String _distance = '';
  String _duration = '';
  bool _showRouteInfo = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        setState(() {
          _suggestions = [];
          _polylines.clear();
          _distance = '';
          _duration = '';
          _showRouteInfo = false;
        });
      } else {
        _fetchSuggestions(_searchController.text);
      }
    });

    // Fetch and display the route, distance, and time between pickup and drop locations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedLocation != null && widget.dropLOcation != null) {
        _showRoute(widget.selectedLocation, widget.dropLOcation);
        _showDistanceAndTime(widget.selectedLocation, widget.dropLOcation);
      }
    });
  }

  String? _currentLocationAddress;

  Future<void> _getLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _loading = false;
        });
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() {
          _loading = false;
        });
        return;
      }
    }

    final locData = await location.getLocation();
    final currentCoordinates = LatLng(locData.latitude!, locData.longitude!);
    final address = await _getCurrentAddress(currentCoordinates);

    setState(() {
      _currentLocation = currentCoordinates;
      _currentLocationAddress = address; // Store the address
      _loading = false;
    });
  }

  Future<void> _fetchSuggestions(String pattern) async {
    if (pattern.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    setState(() {
      _suggestionsLoading = true;
    });

    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$pattern&components=country:IN&key=$_apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _suggestions = data['predictions'];
        _suggestionsLoading = false;
      });
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  Set<Marker> _markers = {};

  Future<void> _showRoute(LatLng origin, LatLng destination) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$_apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final routes = data['routes'];
      if (routes.isNotEmpty) {
        final polylinePoints = routes[0]['overview_polyline']['points'];
        final points = _decodePolyline(polylinePoints);

        setState(() {
          _polylines.add(
            Polyline(
              polylineId: PolylineId('route'),
              points: points,
              color: Colors.black87,
              width: 5,
            ),
          );
          _showRouteInfo = true; // Show route info

          // Update the markers set
          _markers = {
            Marker(
              markerId: MarkerId('origin'),
              position: origin,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueOrange),
              infoWindow: InfoWindow(title: 'Pick Up'),
            ),
            Marker(
              markerId: MarkerId('destination'),
              position: destination,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure),
              infoWindow: InfoWindow(title: 'Destination'),
            ),
          };
        });

        LatLngBounds bounds = LatLngBounds(
          southwest: LatLng(
            points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b),
            points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b),
          ),
          northeast: LatLng(
            points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b),
            points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b),
          ),
        );
        _mapController.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 50),
        );
      }
    } else {
      throw Exception('Failed to load directions');
    }
  }

  Future<void> _showDistanceAndTime(LatLng origin, LatLng destination) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$_apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final routes = data['routes'];
      if (routes.isNotEmpty) {
        final legs = routes[0]['legs'];
        final distance = legs[0]['distance']['text'];
        final duration = legs[0]['duration']['text'];

        setState(() {
          _distance = distance;
          _duration = duration;
        });
      }
    } else {
      throw Exception('Failed to load distance and time');
    }
  }

  Future<String> _getCurrentAddress(LatLng coordinates) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${coordinates.latitude},${coordinates.longitude}&key=$_apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final address = data['results'][0]['formatted_address'];
      return address;
    } else {
      throw Exception('Failed to load address');
    }
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0;
    int len = polyline.length;
    int latitude = 0;
    int longitude = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      latitude += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      longitude += dlng;

      final lat = (latitude / 1E5).toDouble();
      final lng = (longitude / 1E5).toDouble();
      points.add(LatLng(lat, lng));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _loading
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Lot.Lottie.asset("assets/mapload.json",
                          height: 100, width: 100),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Loading...",
                      style: TextStyle(
                          fontFamily: "Raleway",
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ))
              : _currentLocation == null
                  ? Center(
                      child: Text(
                          'Location permissions are required to display the map.'))
                  : GestureDetector(
                      onTap: () {
                        // Close the suggestion if tapping on the map
                        HapticFeedback.heavyImpact();
                        setState(() {
                          _suggestions.clear();
                        });
                        FocusScope.of(context).unfocus();
                      },
                      child: GoogleMap(
                        zoomControlsEnabled: false,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                          if (_currentLocation != null) {
                            _mapController.animateCamera(
                              CameraUpdate.newLatLngZoom(
                                  _currentLocation!, 16.0),
                            );
                          }
                        },
                        initialCameraPosition: CameraPosition(
                          target: _currentLocation ?? LatLng(0, 0),
                          zoom: 14.0,
                        ),
                        markers: _markers, // Use the _markers set here
                        polylines: _polylines,
                      ),
                    ),
          Column(
            children: [
              SizedBox(height: 50),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => StartSearch()));
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            height: 15,
                            width: 15,
                            decoration: BoxDecoration(
                              color: Colors.lightGreen,
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.pickupAddress.isNotEmpty
                                ? widget.pickupAddress
                                : "Pick Up From?",
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Raleway",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DestSearch(
                                selectedLocation: widget.selectedLocation,
                                pickupAddress: widget.pickupAddress,
                              )));
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            height: 15,
                            width: 15,
                            decoration: BoxDecoration(
                              color: Colors.deepOrangeAccent,
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.dropAddress.isNotEmpty
                                ? widget.dropAddress
                                : "Where to?",
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Raleway",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Suggestions container
            ],
          ),
          if (_showRouteInfo)
            Positioned(
              top: 200,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  height: 50,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$_distance",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Raleway",
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "$_duration",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Raleway",
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_showRouteInfo)
            Positioned(
              bottom: 50,
              left: 50,
              right: 50,
              child: GestureDetector(
                onTap: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Bookride(
                                selectedLocation: widget.selectedLocation,
                                dropLOcation: widget.dropLOcation,
                              )));
                  // toastification.show(
                  //   alignment: Alignment.bottomCenter,
                  //   context:
                  //       context, // optional if you use ToastificationWrapper
                  //   title: Text('To be imlemented!'),
                  //   type: ToastificationType.warning,
                  //   showProgressBar: false,
                  //   autoCloseDuration: const Duration(seconds: 2),
                  // );

                  try {
                    final customerId =
                        await _fetchCustomerId(); // Fetch the customer's ID (phone number)
                    if (customerId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Customer ID not found.")),
                      );
                      return;
                    }

                    final rideId = await createRideRequest(customerId);

                    if (rideId != null) {
                      toastification.show(
                        alignment: Alignment.bottomCenter,
                        context: context,
                        title: Text('Ride request created!'),
                        type: ToastificationType.success,
                        showProgressBar: false,
                        autoCloseDuration: const Duration(seconds: 2),
                      );
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Bookride(
                                    selectedLocation: widget.selectedLocation,
                                    dropLOcation: widget.dropLOcation,
                                  )));
                    } else {
                      toastification.show(
                        alignment: Alignment.bottomCenter,
                        context: context,
                        title: Text('Failed to create ride request.'),
                        type: ToastificationType.error,
                        showProgressBar: false,
                        autoCloseDuration: const Duration(seconds: 2),
                      );
                    }
                  } catch (e) {
                    toastification.show(
                      alignment: Alignment.bottomCenter,
                      context: context,
                      title: Text('Error: $e'),
                      type: ToastificationType.error,
                      showProgressBar: false,
                      autoCloseDuration: const Duration(seconds: 2),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    height: 50,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "BOOK RIDE",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Raleway",
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 150,
            right: 20,
            child: Container(
              height: 50,
              width: 50,
              child: FloatingActionButton(
                enableFeedback: true,
                backgroundColor: Colors.black87,
                onPressed: _recenterMap,
                child: Icon(Icons.my_location, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _recenterMap() async {
    if (_currentLocation != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 14.0),
      );
    }
  }

  Future<Object?> createRideRequest(String customerId) async {
    var db = await mongo.Db.create(
        "mongodb+srv://wm:7806@wm.4lglk.mongodb.net/Users?retryWrites=true&w=majority&appName=wm");
    await db.open();
    var collection = db.collection('ride_requests');

    try {
      final rideRequest = {
        "_id": mongo.ObjectId().toHexString(),
        "customer_id": customerId,
        "pickup_location": {
          "type": "Point",
          "coordinates": [
            widget.selectedLocation.longitude,
            widget.selectedLocation.latitude
          ],
        },
        "drop_location": {
          "type": "Point",
          "coordinates": [
            widget.dropLOcation.longitude,
            widget.dropLOcation.latitude
          ],
        },
        "status": "pending",
        "driver_id": null,
        "created_at": DateTime.now().toIso8601String(),
      };

      final result = await collection.insertOne(rideRequest);
      if (result.isSuccess) {
        return rideRequest["_id"];
      } else {
        throw Exception("Failed to insert ride request.");
      }
    } catch (e) {
      print("Error creating ride request: $e");
      return null;
    } finally {
      await db.close();
    }
  }

  Future<String?> _fetchCustomerId() async {
    // Fetch customer phone number from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final customerPhoneNumber =
        prefs.getString('user_id'); // Key for stored user ID

    if (customerPhoneNumber == null) {
      print("Customer phone number not found in SharedPreferences.");
      return null;
    }

    // MongoDB connection and query
    var db = await mongo.Db.create(
        "mongodb+srv://wm:7806@wm.4lglk.mongodb.net/Users?retryWrites=true&w=majority&appName=wm");
    await db.open();
    var collection = db.collection('users');

    try {
      var user = await collection.findOne({
        '_id': customerPhoneNumber
      }); // Use the fetched customer phone number
      return user?['_id'];
    } catch (e) {
      print("Error fetching customer ID: $e");
      return null;
    } finally {
      await db.close();
    }
  }
}
