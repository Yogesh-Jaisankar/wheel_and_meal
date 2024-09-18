import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:lottie/lottie.dart' as Lot;
import 'package:wheel_and_meal/Screens/mainscreen.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  LatLng? _currentLocation;
  bool _loading = true;
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  String? _currentLocationAddress;
  final String _apiKey = 'AIzaSyA2Nqezz1idcqRvJRXEu68O7t2aJC99Tyw';
  bool _isLoading = false;
  List<dynamic> _pickupSuggestions = [];
  List<dynamic> _dropoffSuggestions = [];
  Position? _currentPosition;
  TextEditingController _pickupController = TextEditingController();
  TextEditingController _dropoffController = TextEditingController();

  Future<LatLng> _getLatLngFromPlaceId(String placeId) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['result']['geometry']['location'];
      return LatLng(location['lat'], location['lng']);
    } else {
      throw Exception('Failed to get LatLng from place ID');
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

  Future<void> _getSuggestions(String input, bool isPickup) async {
    if (input.isEmpty || _currentLocation == null) return;

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_apiKey&location=${_currentLocation!.latitude},${_currentLocation!.longitude}&radius=50000&region=in'); // Added region parameter

    final response = await http.get(url);

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      if (data['predictions'] != null) {
        setState(() {
          if (isPickup) {
            _pickupSuggestions = data['predictions'];
          } else {
            _dropoffSuggestions = data['predictions'];
          }
        });
      }
    } else {
      print('Error fetching suggestions: ${response.body}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
    // Show the bottom sheet when the page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showBottomSheet();
    });
  }

  void _showBottomSheet() {
    double _bottomSheetHeight = 0.9; // Initial height is 0.9

    showModalBottomSheet(
      backgroundColor: Colors.black87,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: FractionallySizedBox(
            heightFactor: _bottomSheetHeight, // Dynamically change the height
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      MainScreen(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                        child: ListTile(
                          leading: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                          ),
                          title: Center(
                            child: Text(
                              "Plan your ride",
                              style: TextStyle(
                                fontSize: 25,
                                fontFamily: "Raleway",
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                height: 50,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    controller: _pickupController,
                                    cursorColor: Colors.white,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      icon: Icon(
                                        Icons.stars,
                                        color: Colors.green,
                                      ),
                                      hintStyle: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Raleway",
                                      ),
                                      border: InputBorder.none,
                                      hintText: "Select pickup location",
                                    ),
                                    onChanged: (value) async {
                                      await _getSuggestions(value, true);
                                      setModalState(() {});
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 50),
                              child: Divider(color: Colors.grey),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                height: 50,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    controller: _dropoffController,
                                    cursorColor: Colors.white,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      icon: Icon(
                                        Icons.pin_drop_rounded,
                                        color: Colors.red,
                                      ),
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Raleway",
                                      ),
                                      hintText: "Select Drop",
                                    ),
                                    onChanged: (value) async {
                                      await _getSuggestions(value, false);
                                      setModalState(() {});
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Expanded(
                      child: ListView(
                        children: [
                          ..._pickupSuggestions.map((suggestion) {
                            String description =
                                suggestion['description'] ?? 'No description';
                            return Column(
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.location_on_rounded,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    description,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                  onTap: () async {
                                    FocusScope.of(context).unfocus();
                                    setModalState(() {
                                      _pickupController.text = description;
                                      _pickupSuggestions = [];
                                      _bottomSheetHeight =
                                          0.3; // Minimize height
                                    });
                                    final placeId =
                                        suggestion['place_id'] ?? '';
                                    final LatLng selectedLocation =
                                        await _getLatLngFromPlaceId(placeId);
                                    _mapController.animateCamera(
                                      CameraUpdate.newLatLngZoom(
                                          selectedLocation, 16),
                                    );
                                  },
                                ),
                                const Divider(color: Colors.white30),
                              ],
                            );
                          }).toList(),
                          ..._dropoffSuggestions.map((suggestion) {
                            String description =
                                suggestion['description'] ?? 'No description';
                            return Column(
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.location_on_rounded,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    description,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                  onTap: () async {
                                    FocusScope.of(context).unfocus();
                                    setModalState(() {
                                      _dropoffController.text = description;
                                      _dropoffSuggestions = [];
                                      _bottomSheetHeight =
                                          0.3; // Minimize height
                                    });
                                    final placeId =
                                        suggestion['place_id'] ?? '';
                                    final LatLng selectedLocation =
                                        await _getLatLngFromPlaceId(placeId);
                                    _mapController.animateCamera(
                                      CameraUpdate.newLatLngZoom(
                                          selectedLocation, 16),
                                    );
                                  },
                                ),
                                const Divider(color: Colors.white30),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
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
                        HapticFeedback.heavyImpact();
                        FocusScope.of(context).unfocus();
                      },
                      child: GoogleMap(
                        buildingsEnabled: true,
                        trafficEnabled: true,
                        mapType: MapType.hybrid,
                        zoomControlsEnabled: false,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                          if (_currentLocation != null) {
                            _mapController.animateCamera(
                              CameraUpdate.newLatLngZoom(_currentLocation!, 16),
                            );
                          }
                        },
                        initialCameraPosition: CameraPosition(
                          target: _currentLocation!,
                          zoom: 16,
                        ),
                        markers: _markers,
                        polylines: _polylines,
                      ),
                    ),
          Positioned(
            child: Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.location_on,
                size: 40,
                color: Colors.red, // Marker color
              ),
            ),
          ),
        ],
      ),
    );
  }
}
