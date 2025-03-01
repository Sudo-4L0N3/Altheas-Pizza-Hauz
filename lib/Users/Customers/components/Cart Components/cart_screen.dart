import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../customerResponsive.dart';
import 'cart_model.dart';
import 'checkout_dialog.dart';  // Import the new checkout dialog

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isPrioritizeOrder = false; // State for prioritizing order

  @override
  Widget build(BuildContext context) {
    var cart = context.watch<CartModel>(); // Access CartModel using provider

    // Define margin for desktop
    final EdgeInsets desktopMargin = Responsive.isDesktop(context)
        ? const EdgeInsets.symmetric(horizontal: 300.0, vertical: 20.0)
        : EdgeInsets.zero; // No margin for mobile

    // Calculate total including prioritize fee
    final double prioritizeFee = isPrioritizeOrder ? 30.00 : 0.00;
    final double totalPriceWithFee = cart.totalPrice + prioritizeFee;
    final bool isDesktop = Responsive.isDesktop(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:
            !Responsive.isDesktop(context), // Hide back arrow if on desktop
        title: isDesktop
            ? null // Hide title on desktop
            : const Text('Your Food Cart'), // Show title on mobile/tablet
        backgroundColor: Colors.white,
      ),
      body: cart.cartItems.isNotEmpty
          ? Container(
              margin: desktopMargin, // Apply margin for desktop screens
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
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
                                  const Icon(Icons.broken_image, size: 50, color: Colors.red),
                            ),
                          ),
                          title: Text(product.title),
                          subtitle: Text(
                              '₱${(product.price * quantity).toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  if (quantity == 1) {
                                    // Show confirmation dialog if the quantity is 1
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Center(
                                              child: Text(product.title, style: const TextStyle(fontSize: 14))),
                                          backgroundColor: Colors.white,
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(8.0),
                                                child: Image.network(
                                                  product.image,
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) =>
                                                      const Icon(Icons.broken_image, size: 50, color: Colors.red),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              const Center(
                                                child: Text(
                                                  'Are you sure you want to \nremove this item from your cart?',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(fontSize: 12),
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Close the dialog
                                              },
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor: Colors.grey[400],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                              ),
                                              child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                cart.removeItem(product); // Proceed to remove the item
                                                Navigator.of(context).pop(); // Close the dialog
                                              },
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor: Colors.red,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                              ),
                                              child: const Text('Remove', style: TextStyle(fontSize: 12)),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    cart.removeItem(product); // Decrease quantity without confirmation if quantity > 1
                                  }
                                },
                              ),
                              Text('$quantity'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  cart.addItem(product); // Increase quantity
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Checkbox for Prioritize Order
                        Row(
                          children: [
                            Checkbox(
                              value: isPrioritizeOrder,
                              onChanged: (bool? value) {
                                setState(() {
                                  isPrioritizeOrder = value ?? false;
                                });
                              },
                            ),
                            Text(isPrioritizeOrder
                                ? 'Prioritize Order (₱30)'
                                : 'Prioritize Order (₱30)'),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Conditionally display prioritize fee
                        if (isPrioritizeOrder)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Prioritize Fee'),
                              Text('₱${prioritizeFee.toStringAsFixed(2)}'),
                            ],
                          ),

                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal'),
                            Text(
                              '₱${cart.totalPrice.toStringAsFixed(2)}', // Subtotal without prioritize fee
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₱${totalPriceWithFee.toStringAsFixed(2)}', // Total price with prioritize fee if selected
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Show the checkout dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CheckoutDialog(
                                  cart: cart,
                                  isPrioritizeOrder: isPrioritizeOrder,
                                  prioritizeFee: prioritizeFee,
                                  totalPriceWithFee: totalPriceWithFee,
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                          ),
                          child: const Text('Place Order'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Center(
                  child: Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(height: 20),
                // Display "Go Back" button only on desktop
                if (isDesktop)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 200),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.grey[600],
                        
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Center(child: Text('Go Back')),
                    ),
                  ),
              ],
            ),
    );
  }
}
