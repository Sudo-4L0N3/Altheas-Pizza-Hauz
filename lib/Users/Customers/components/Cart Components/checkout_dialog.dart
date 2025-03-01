import 'dart:math';
import 'package:altheas_pizza_hauz/Users/Customers/customerConstant.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../Login/Screens/Signup/signup_screen.dart';
import 'cart_model.dart';

class CheckoutDialog extends StatelessWidget {
  final CartModel cart;
  final bool isPrioritizeOrder;
  final double prioritizeFee;
  final double totalPriceWithFee;

  const CheckoutDialog({
    super.key,
    required this.cart,
    required this.isPrioritizeOrder,
    required this.prioritizeFee,
    required this.totalPriceWithFee,
  });

  // Function to generate a random 4-digit order number
  int _generateOrderNumber() {
    return Random().nextInt(9000) +
        1000; // Generates a number between 1000 and 9999
  }

  Future<void> _confirmOrder(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Check if the user has any incomplete orders
        final QuerySnapshot existingOrderSnapshot = await FirebaseFirestore.instance
            .collection('Order')
            .where('email', isEqualTo: user.email)
            .where('Complete', isEqualTo: 'No')
            .get();

        if (existingOrderSnapshot.docs.isNotEmpty) {
          // User has an incomplete order, show an error message and prevent placing a new order
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                backgroundColor: Colors.deepOrangeAccent,
                duration: Duration(milliseconds: 2000),
                content: Text('You already have an order that is not yet completed. Please complete your existing order before placing a new one.')),
          );
          return;
        }

        // Fetch additional user data from Firestore if necessary
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // Get user details
        final String fullname = userDoc['fullname'] ?? 'N/A';
        final String email = user.email ?? 'N/A';
        final String username = userDoc['username'] ?? 'N/A';
        final String address = userDoc['address'] ?? 'No address available';

        // Prepare cart items for the order
        List<Map<String, dynamic>> cartItems = cart.cartItems.map((productMap) {
          final product = productMap.keys.first;
          final quantity = productMap.values.first;

          return {
            'foodName': product.title,
            'foodPicture': product.image,
            'quantity': quantity,
            'totalPrice': product.price * quantity,
          };
        }).toList();

        // Create an order document in Firestore
        await FirebaseFirestore.instance.collection('Order').add({
          'orderNumber': _generateOrderNumber(),
          'items': cartItems, // All cart items
          'totalPrice': totalPriceWithFee,
          'priority': isPrioritizeOrder ? 'Yes' : 'Normal',
          'fullname': fullname,
          'email': email,
          'username': username,
          'address': address, // Add user address to the order document
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'Pending', // Default status
          'Complete': 'No',
          'estimatedTime': '0',
        });

        // After successfully placing the order, clear the cart
        cart.clearCart();

        // After successfully placing the order, close the dialog and show a success message
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.green,
              duration: Duration(milliseconds: 800),
              content: Text('Order placed successfully!')),
        );
      } catch (e) {
        // Handle any errors
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.red,
              duration: const Duration(milliseconds: 800),
              content: Text('Failed to place order: $e')),
        );
      }
    } else {
      // If the user is not logged in, show a dialog prompting them to register
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Not Logged In',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'You need to register or log in first before you can place your order.',
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => const SignUpScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColorButton,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text('Go to Sign Up', style: TextStyle(fontSize: 14)),
              ),
              
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width to adjust layout for mobile vs larger screens
    double screenWidth = MediaQuery.of(context).size.width;

    // Adjust dialog size based on screen width
    double dialogWidth = screenWidth < 600 ? screenWidth * 0.8 : 250; // Smaller dialog width
    double dialogHeight = screenWidth < 600 ? screenWidth * 0.9 : 300; // Smaller dialog height

    return AlertDialog(
      title: const Center(
        child: Text(
          'Order Summary',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.white,
      content: SizedBox(
        width: dialogWidth, // Smaller dialog width
        height: dialogHeight, // Smaller dialog height
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // List the items in the cart
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cart.cartItems.length,
                itemBuilder: (context, index) {
                  final productMap = cart.cartItems[index];
                  final product = productMap.keys.first;
                  final quantity = productMap.values.first;

                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        product.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image,
                                size: 50, color: Colors.red),
                      ),
                    ),
                    title: Text(product.title, style: const TextStyle(fontSize: 14)),
                    subtitle: Text(
                      '₱${(product.price * quantity).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Text('x$quantity', style: const TextStyle(fontSize: 14)),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // Show Prioritize Order or Standard
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Type:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isPrioritizeOrder
                      ? 'Prioritized Order (₱${prioritizeFee.toStringAsFixed(2)})'
                      : 'Normal',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Total price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₱${totalPriceWithFee.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.only(bottom: 10, right: 10, left: 10),
      actions: [
        const SizedBox(height: 10), // Space between buttons
        Center(
          child: SizedBox(
            child: ElevatedButton.icon(
              onPressed: () {
                _confirmOrder(context); // Call confirm order method
              },
              icon: const Icon(Icons.check_circle, size: 16), // Smaller icon
              label: const Text('Confirm Order',
                  style: TextStyle(fontSize: 14)), // Adjusted font size
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 20), // Adjust button size
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20.0), // Reduced border radius
                ),
              ),
            ),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
