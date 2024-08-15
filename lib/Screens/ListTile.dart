import 'package:flutter/material.dart';

Widget buildLocationTile({
  required String description,
  required double distance,
  required VoidCallback onTap,
}) {
  String formattedDistance = (distance / 1000).toStringAsFixed(2); // in km

  return Container(
    height: 70, // Fixed height for the tile
    padding: const EdgeInsets.all(5.0),
    child: ListTile(
      leading: Container(
        height: 60,
        width: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
      onTap: onTap,
    ),
  );
}
