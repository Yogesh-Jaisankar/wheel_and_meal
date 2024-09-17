import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:wheel_and_meal/Screens/rider.dart';

class ConfirmPickup extends StatefulWidget {
  final LatLng location;
  final String placeName;

  const ConfirmPickup({
    super.key,
    required this.location,
    required this.placeName,
  });

  @override
  State<ConfirmPickup> createState() => _ConfirmPickupState();
}

class _ConfirmPickupState extends State<ConfirmPickup> {
  late GoogleMapController _mapController;
  late Marker _marker;
  String _address = 'Loading...';

  @override
  void initState() {
    super.initState();
    _marker = Marker(
      markerId: MarkerId('selectedPlace'),
      position: widget.location,
      infoWindow: InfoWindow(
        title: widget.placeName,
      ),
      draggable: true,
      onDragEnd: (newPosition) {
        _onMarkerDragEnd(newPosition);
      },
    );
    _getAddress(widget.location);
  }

  Future<void> _getAddress(LatLng location) async {
    final lat = location.latitude;
    final lng = location.longitude;
    final apiKey =
        'AIzaSyA2Nqezz1idcqRvJRXEu68O7t2aJC99Tyw'; // Replace with your Google Maps API key

    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'].isNotEmpty) {
        final formattedAddress = data['results'][0]['formatted_address'];
        // Extract landmark if available or highlight it in the address
        // For example, using the first part of the address as the landmark
        final addressParts = formattedAddress.split(',');
        final landmark = addressParts.isNotEmpty ? addressParts[0] : 'Landmark';
        setState(() {
          _address = '$landmark\n$formattedAddress';
        });
      } else {
        setState(() {
          _address = 'Address not found';
        });
      }
    } else {
      setState(() {
        _address = 'Error fetching address';
      });
    }
  }

  void _onMarkerDragEnd(LatLng newPosition) {
    setState(() {
      _marker = _marker.copyWith(positionParam: newPosition);
      _getAddress(newPosition);
    });
  }

  void _updateMarker(LatLng newPosition, String placeName) {
    setState(() {
      _marker = _marker.copyWith(
        positionParam: newPosition,
        infoWindowParam: InfoWindow(title: placeName),
      );
      _getAddress(newPosition);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          "Confirm Pick Up",
          style: TextStyle(
            fontFamily: "Raleway",
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Set the back button color to white
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            initialCameraPosition: CameraPosition(
              target: _marker.position,
              zoom: 18.0,
            ),
            markers: {_marker},
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            onTap: (LatLng position) {
              // Handle map tap to update marker position
              _updateMarker(
                  position, "New Location"); // Example: Use a placeholder name
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: ListTile(
                    leading: Icon(
                      Icons.warning,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Tap to select location",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Address container
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Container(
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          _address,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Raleway",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    print('Selected Location: ${_marker.position}');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Rider(
                                  selectedLocation: _marker.position,
                                  pickupAddress: _address,
                                  dropAddress: '',
                                  dropLOcation: LatLng(1, 1),
                                )));
                  },
                  child: Container(
                    height: 50,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "Confirm?",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Raleway",
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
