import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class Rider extends StatefulWidget {
  const Rider({Key? key}) : super(key: key);

  @override
  State<Rider> createState() => _RiderState();
}

class _RiderState extends State<Rider> {
  late GoogleMapController _mapController;
  LatLng? _currentLocation;
  LatLng? _searchedLocation;
  bool _loading = true;
  bool _suggestionsLoading = false;
  List<dynamic> _suggestions = [];
  final TextEditingController _searchController = TextEditingController();
  final String _apiKey =
      'AIzaSyA8njHoIZmi21e6roCJP41OsvGLAnIG6Ug'; // Replace with your API key
  Set<Polyline> _polylines = {};

  String _distance = '';
  String _duration = '';
  bool _showRouteInfo = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
    _searchController.addListener(() {
      _fetchSuggestions(_searchController.text);
    });
  }

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
    setState(() {
      _currentLocation = LatLng(locData.latitude!, locData.longitude!);
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
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$pattern&key=$_apiKey'));

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

  Future<void> _fetchPlaceDetails(String placeId) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['result']['geometry']['location'];
      final lat = location['lat'];
      final lng = location['lng'];

      setState(() {
        _searchedLocation = LatLng(lat, lng);
      });

      if (_currentLocation != null && _searchedLocation != null) {
        await _showRoute(_currentLocation!, _searchedLocation!);
        await _showDistanceAndTime(_currentLocation!, _searchedLocation!);

        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(_searchedLocation!, 16.0),
        );
      } else {
        setState(() {
          _showRouteInfo = false; // Hide route info if locations are not set
        });
      }
    } else {
      throw Exception('Failed to load place details');
    }
  }

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
              color: Colors.blue,
              width: 5,
            ),
          );
          _showRouteInfo = true; // Show route info
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
        body: Stack(
          children: [
            _loading
                ? Center(child: CircularProgressIndicator())
                : _currentLocation == null
                    ? Center(
                        child: Text(
                            'Location permissions are required to display the map.'))
                    : GoogleMap(
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
                        markers: {
                          if (_searchedLocation != null)
                            Marker(
                              markerId: MarkerId('searchedLocation'),
                              position: _searchedLocation!,
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueRed),
                              infoWindow:
                                  InfoWindow(title: 'Searched Location'),
                            ),
                        },
                        polylines: _polylines,
                      ),
            Column(
              children: [
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.all(20.0),
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
                    child: Row(children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          height: 15,
                          width: 15,
                          decoration: BoxDecoration(
                              color: Colors.lightGreen,
                              borderRadius: BorderRadius.circular(50)),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          style: TextStyle(color: Colors.white),
                          controller: _searchController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Raleway",
                            ),
                            hintText: "Where to?",
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.arrow_upward,
                          color: Colors.white54,
                        ),
                      )
                    ]),
                  ),
                ),
                if (_searchController.text.isNotEmpty &&
                    _suggestions.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        height: 200,
                        child: _suggestionsLoading
                            ? Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                itemCount: _suggestions.length,
                                itemBuilder: (context, index) {
                                  final suggestion = _suggestions[index];
                                  return ListTile(
                                    title: Text(suggestion['description']),
                                    onTap: () async {
                                      await _fetchPlaceDetails(
                                          suggestion['place_id']);
                                      setState(() {
                                        _suggestions = [];
                                      });
                                    },
                                  );
                                },
                              ),
                      ),
                    ),
                  )
              ],
            ),

            // container to show distance and time
            if (_showRouteInfo)
              Positioned(
                bottom: 80,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    height: 50,
                    width: 150,
                    decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$_distance",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        Text(
                          "$_duration",
                          style: TextStyle(
                              color: Colors.white,
                              //fontWeight: FontWeight.bold,
                              fontSize: 15),
                        )
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 50, right: 10),
          child: FloatingActionButton(
            enableFeedback: true,
            backgroundColor: Colors.black87,
            onPressed: _recenterMap,
            child: Icon(Icons.my_location, color: Colors.white),
          ),
        ));
  }

  Future<void> _recenterMap() async {
    if (_currentLocation != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 14.0),
      );
    }
  }
}
