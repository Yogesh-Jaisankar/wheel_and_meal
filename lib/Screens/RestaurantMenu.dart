import 'package:flutter/material.dart';

import 'CartPage.dart';

class RestaurantMenu extends StatefulWidget {
  final String restaurantName;
  final List<Map<String, String>> menuItems;

  RestaurantMenu({
    required this.restaurantName,
    required this.menuItems,
  });

  @override
  _RestaurantMenuState createState() => _RestaurantMenuState();
}

class _RestaurantMenuState extends State<RestaurantMenu> {
  // A list to store the cart items
  List<Map<String, String>> cartItems = [];

  // Function to add items to the cart
  void addToCart(Map<String, String> menuItem) {
    setState(() {
      cartItems.add(menuItem);
    });
  }

  // Navigate to the Cart Page
  void navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(cartItems: cartItems),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.restaurantName,
          style: TextStyle(fontFamily: "Raleway", fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: widget.menuItems.length,
          itemBuilder: (context, index) {
            final menuItem = widget.menuItems[index];
            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Container(
                  height: 50,
                  width: 50,
                  child: Image.network(
                    menuItem['image']!,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(menuItem['name']!),
                subtitle: Text(menuItem['description']!),
                trailing: Text("\₹${menuItem['price']}"),
                onTap: () => addToCart(menuItem), // Add item to cart on tap
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToCart, // Navigate to cart page
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.shopping_cart),
            if (cartItems.isNotEmpty)
              Positioned(
                top: -4,
                right: -4,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.red,
                  child: Text(
                    '${cartItems.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
