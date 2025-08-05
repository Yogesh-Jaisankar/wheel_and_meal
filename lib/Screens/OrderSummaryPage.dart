import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'home.dart';

class OrderSummaryPage extends StatelessWidget {
  final double totalPrice;

  OrderSummaryPage({required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Order Summary'),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Lottie.asset("assets/fare.json"),
            Center(
              child: Text(
                'Total Price: \₹${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                textAlign: TextAlign.center,
                'S1 - Sarvee House, Poompuhar Street, Melakottaiyur, Chennai - 600127',
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Raleway",
                    fontWeight: FontWeight.bold),
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Payment Successful'),
                      content: Text('Thank you for your order!'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close the dialog
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Home(),
                              ),
                            ); // Navigate back to previous screen
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(
                    child: Text(
                      "Paid",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
