import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
              fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Set the back button color to white
        ),
      ),
      body: GoogleMap(
        myLocationButtonEnabled: false,
        initialCameraPosition: CameraPosition(
          target: widget.location,
          zoom: 18.0,
        ),
        markers: {
          Marker(
            markerId: MarkerId('selectedPlace'),
            position: widget.location,
            infoWindow: InfoWindow(
              title: widget.placeName,
            ),
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
    );
  }
}
