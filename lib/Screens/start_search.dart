import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'confirm_pickup.dart'; // Import the ConfirmPickup page

class StartSearch extends StatefulWidget {
  const StartSearch({super.key});

  @override
  State<StartSearch> createState() => _StartSearchState();
}

class _StartSearchState extends State<StartSearch> {
  TextEditingController _locationController = TextEditingController();
  final String _googleApiKey = 'AIzaSyA8njHoIZmi21e6roCJP41OsvGLAnIG6Ug';
  List<dynamic> _suggestions = [];
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _setCurrentLocation();
  }

  Future<void> _setCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentPosition = position;
      });

      String address =
          await _getAddressFromLatLng(position.latitude, position.longitude);

      setState(() {
        _locationController.text = address;
      });
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future<String> _getAddressFromLatLng(double lat, double lng) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$_googleApiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        return data['results'][0]['formatted_address'];
      }
    }
    return "Address not found";
  }

  Future<void> _getSuggestions(String input) async {
    if (input.isEmpty || _currentPosition == null) return;

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_googleApiKey&location=${_currentPosition!.latitude},${_currentPosition!.longitude}&radius=50000');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      if (data['predictions'] != null) {
        setState(() {
          _suggestions = data['predictions'];
        });
      }
    } else {
      print('Error fetching suggestions: ${response.body}');
    }
  }

  Future<double> _calculateDistance(double lat, double lng) async {
    if (_currentPosition == null) return 0.0;

    return Geolocator.distanceBetween(
        _currentPosition!.latitude, _currentPosition!.longitude, lat, lng);
  }

  Future<Map<String, dynamic>> _getPlaceDetailsAndDistance(
      String placeId) async {
    final detailsUrl = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_googleApiKey');

    final response = await http.get(detailsUrl);

    if (response.statusCode == 200) {
      Map<String, dynamic> detailsData = json.decode(response.body);
      if (detailsData['result'] != null) {
        double lat = detailsData['result']['geometry']['location']['lat'];
        double lng = detailsData['result']['geometry']['location']['lng'];
        double distance = await _calculateDistance(lat, lng);
        return {'lat': lat, 'lng': lng, 'distance': distance};
      }
    }
    return {'lat': 0.0, 'lng': 0.0, 'distance': 0.0};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          "Pick Up at?",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Raleway",
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Set the back button color to white
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _locationController,
                      onChanged: (value) {
                        _getSuggestions(value);
                      },
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Raleway",
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search for your place...",
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Raleway",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                var suggestion = _suggestions[index];
                String description =
                    suggestion['description'] ?? 'No description';
                String placeId = suggestion['place_id'];
                return FutureBuilder(
                  future: _getPlaceDetailsAndDistance(placeId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        title: Text('...'),
                      );
                    } else if (snapshot.hasError) {
                      return ListTile(
                        title: Text('Error loading suggestion'),
                      );
                    } else {
                      final details = snapshot.data as Map<String, dynamic>;
                      double distance = details['distance'];
                      String formattedDistance =
                          (distance / 1000).toStringAsFixed(2); // in km

                      if (distance <= 100000) {
                        // 100 km in meters
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ListTile(
                            leading: Column(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                Text('$formattedDistance km')
                              ],
                            ),
                            title: Text(
                              description,
                              style: TextStyle(
                                  overflow: TextOverflow.fade,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            onTap: () async {
                              // Handle tap on the suggestion
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ConfirmPickup(
                                    location:
                                        LatLng(details['lat'], details['lng']),
                                    placeName: description,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return Container(); // Return an empty container if the distance is greater than 100 km
                      }
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
