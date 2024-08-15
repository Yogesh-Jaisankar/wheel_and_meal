import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:wheel_and_meal/Screens/confirm_drop.dart';

class DestSearch extends StatefulWidget {
  final LatLng selectedLocation;
  final String pickupAddress;

  const DestSearch({
    super.key,
    required this.selectedLocation,
    required this.pickupAddress,
  });

  @override
  State<DestSearch> createState() => _DestSearchState();
}

class _DestSearchState extends State<DestSearch> {
  TextEditingController _locationController = TextEditingController();
  final String _googleApiKey = 'AIzaSyA8njHoIZmi21e6roCJP41OsvGLAnIG6Ug';
  List<dynamic> _suggestions = [];
  Position? _currentPosition;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setCurrentLocation();
  }

  Future<void> _setCurrentLocation() async {
    try {
      setState(() {
        _isLoading = true;
      });

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching location: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getSuggestions(String input) async {
    if (input.isEmpty || _currentPosition == null) return;

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_googleApiKey&location=${_currentPosition!.latitude},${_currentPosition!.longitude}&radius=50000');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      if (data['predictions'] != null) {
        setState(() {
          _suggestions = data['predictions'];
          _isLoading = false;
        });
      }
    } else {
      print('Error fetching suggestions: ${response.body}');
      setState(() {
        _isLoading = false;
      });
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
          "Drop at?",
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
                        color: Colors.orangeAccent,
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
                        hintText: "Search for your drop place...",
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
          _isLoading
              ? Center(
                  child: Column(
                    children: [
                      Container(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            "assets/icons/wm.png",
                            height: 80,
                            width: 80,
                          ),
                        ),
                      ),
                      Text(
                        "Loading",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Raleway"),
                      )
                    ],
                  ), // Loading indicator
                )
              : Expanded(
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
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(); // Empty container while waiting
                          } else if (snapshot.hasError) {
                            return Container(); // Handle error gracefully
                          } else {
                            final details =
                                snapshot.data as Map<String, dynamic>;
                            double distance = details['distance'];
                            String formattedDistance =
                                (distance / 1000).toStringAsFixed(2); // in km

                            if (distance <= 100000) {
                              return Container(
                                height: 70, // Fixed height for the tile
                                padding: const EdgeInsets.all(5.0),
                                child: ListTile(
                                  leading: Container(
                                    height: 60,
                                    width: 50,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        Text(
                                          '$formattedDistance\nkm',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 12),
                                        )
                                      ],
                                    ),
                                  ),
                                  title: Text(
                                    description,
                                    style: TextStyle(
                                        fontFamily: "Raleway",
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  onTap: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ConfirmDrop(
                                          location: LatLng(
                                              details['lat'], details['lng']),
                                          placeName: description,
                                          selectedLocation:
                                              widget.selectedLocation,
                                          pickupAddress: widget.pickupAddress,
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
