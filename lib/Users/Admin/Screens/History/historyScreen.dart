import 'package:altheas_pizza_hauz/Users/Admin/Screens/History/OrderDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../Admin Constants/Admin_Constants.dart';
import '../../Admin Constants/Admin_Responsive.dart';
import '../../controllers/menu_app_controller.dart';
import '../New Dashbaord/dashboard_screen.dart';

class Historyscreen extends StatefulWidget {
  const Historyscreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HistoryscreenState createState() => _HistoryscreenState();
}

class _HistoryscreenState extends State<Historyscreen> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.toLowerCase(); // Update search query
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Responsive.isDesktop(context);
    final bool isMobile = Responsive.isMobile(context);
    final double headerFontSize = isMobile ? 14.0 : 16.0;
    final double iconSize = isMobile ? 18.0 : 24.0;

    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: isDesktop
          ? null
          : AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: iconSize),
                onPressed: () {
                  // Navigate to Adminscreen when back button is pressed
                  context.read<MenuAppController>().changeScreen(const DashboardScreen());
                },
              ),
              title: Text(
                'History',
                style: TextStyle(color: Colors.white, fontSize: headerFontSize),
              ),
              backgroundColor: secondaryColor,
              iconTheme: IconThemeData(color: Colors.white, size: iconSize),
            ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header for Completed Orders
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "History of Completed Orders",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              const Divider(color: Colors.white54, thickness: 1),
              
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by customer name or order ID...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: fillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16.0),

              // Fetch and display the list of completed orders with StreamBuilder
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('orderHistory')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final orders = snapshot.data!.docs;

                    // Map Firestore data to local list
                    List<Map<String, dynamic>> allOrders = orders.map((doc) {
                      return {
                        "id": doc['orderNumber'],
                        "customerName": doc['fullname'],
                        "totalAmount": doc['totalPrice'],
                        "date": (doc['timestamp'] as Timestamp).toDate(),
                        "address": doc['address'],
                        "email": doc['email'],
                        "priority": doc['priority'],
                        "status": doc['status'],
                        "items": doc['items'], // list of items
                      };
                    }).toList();

                    // Filter orders based on the search query
                    List<Map<String, dynamic>> filteredOrders = allOrders.where((order) {
                      return order['customerName'].toLowerCase().contains(searchQuery) ||
                             order['id'].toString().contains(searchQuery);
                    }).toList();

                    return ListView.builder(
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return _buildOrderCard(order, context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
    child: Card(
      color: fillColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: ListTile(
        leading: Text(
          '#${order['id'].toString()}',  // Prepend the '#' to the order number
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,  // Make it bold for emphasis
          ),
        ),
        title: Text(
          order['customerName'],
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        subtitle: Text(
          "Total: ₱${order['totalAmount'].toStringAsFixed(2)}\nDate: ${order['date']}",
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: const Text("Completed", style: TextStyle(color: Colors.green)),
        onTap: () {
          _showOrderDetailsDialog(context, order);
        },
      ),
    ),
  );
}


  // Function to show the dialog
  void _showOrderDetailsDialog(BuildContext context, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) {
        return OrderDetailsDialog(order: order);
      },
    );
  }
}
