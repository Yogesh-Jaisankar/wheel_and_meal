import 'package:flutter/material.dart';

import 'OrderSummaryPage.dart';

class CartPage extends StatefulWidget {
  final List<Map<String, String>> cartItems;

  CartPage({required this.cartItems});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // A map to store the item counts (using item name as the key)
  Map<String, int> itemCounts = {};

  @override
  void initState() {
    super.initState();
    // Initialize item counts based on the cartItems
    for (var item in widget.cartItems) {
      itemCounts[item['name']!] = (itemCounts[item['name']!] ?? 0) + 1;
    }
  }

  // Function to calculate total price
  double calculateTotalPrice() {
    double totalPrice = 0;
    for (var item in widget.cartItems) {
      totalPrice += double.parse(item['price']!) * itemCounts[item['name']]!;
    }
    return totalPrice;
  }

  // Function to increase item quantity
  void increaseItemQuantity(String itemName) {
    setState(() {
      itemCounts[itemName] = (itemCounts[itemName] ?? 0) + 1;
    });
  }

  // Function to decrease item quantity
  void decreaseItemQuantity(String itemName) {
    setState(() {
      if (itemCounts[itemName]! > 1) {
        itemCounts[itemName] = itemCounts[itemName]! - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Create a list of unique items
    List<Map<String, String>> uniqueItems = [];
    Set<String> addedItemNames = {};

    for (var item in widget.cartItems) {
      if (!addedItemNames.contains(item['name'])) {
        uniqueItems.add(item);
        addedItemNames.add(item['name']!);
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Your Cart',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Raleway"),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: uniqueItems.length,
                itemBuilder: (context, index) {
                  final item = uniqueItems[index];
                  int quantity = itemCounts[item['name']!] ?? 0;
                  return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Container(
                          width:
                              60, // Fixed width to maintain a consistent layout
                          height: 60,
                          child: Image.network(
                            item['image']!,
                            fit: BoxFit
                                .cover, // Ensures the image maintains aspect ratio and fills the space
                          ),
                        ),
                        title: Text(
                          item['name']!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                16, // Adjust font size to fit larger texts
                          ),
                          overflow: TextOverflow.ellipsis, // Handle long texts
                        ),
                        subtitle: Text(
                          item['description']!,
                          style: TextStyle(
                            fontSize: 14, // Smaller font size for description
                            color: Colors.grey[600],
                          ),
                          overflow:
                              TextOverflow.ellipsis, // Handle long descriptions
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () =>
                                  decreaseItemQuantity(item['name']!),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '$quantity',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () =>
                                  increaseItemQuantity(item['name']!),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                "\₹${(double.parse(item['price']!) * quantity).toStringAsFixed(2)}",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ));
                },
              ),
            ),
            Divider(),
            Text(
              'Total Price: \₹${calculateTotalPrice().toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'S1 - Sarvee House, Poompuhar Street, Melakottaiyur, Chennai - 600127',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Raleway"),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                // Navigate to the Order Summary page with the total price
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderSummaryPage(
                      totalPrice: calculateTotalPrice()
                          .toDouble(), // Pass the total price
                    ),
                  ),
                );
              },
              child: Text('Place Order'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
