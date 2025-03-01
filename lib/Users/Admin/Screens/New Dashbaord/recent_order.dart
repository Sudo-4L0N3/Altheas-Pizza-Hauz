import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Admin Constants/Admin_Constants.dart';
import '../../Admin Constants/responsive_text.dart';

class RecentOrders extends StatelessWidget {
  const RecentOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 700, // Set your desired fixed height
      child: Card(
        color: secondaryColor, // Use fillColor for card background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Menu Avalable',
                    style: TextStyle(
                      fontSize: ResponsiveText.getTitleSize(context),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white70),
              // Orders Table Header
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Food Name',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Quantity',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Date and Time',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Status',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white70),
              // Orders List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Order')
                      .orderBy('timestamp', descending: true)
                      .limit(10)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Error loading orders',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final orders = snapshot.data!.docs;

                    if (orders.isEmpty) {
                      return const Center(
                        child: Text(
                          'No recent orders',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: orders.length,
                      separatorBuilder: (context, index) => const Divider(color: Colors.white54),
                      itemBuilder: (context, index) {
                        final order = orders[index].data() as Map<String, dynamic>;
                        final foodName = order['items'] != null && (order['items'] as List).isNotEmpty
                            ? (order['items'][0]['foodName'] ?? 'No Food Name')
                            : 'No Food Name';
                        final quantity = order['items'] != null && (order['items'] as List).isNotEmpty
                            ? (order['items'][0]['quantity'] ?? 'N/A')
                            : 'N/A';
                        final timestamp = order['timestamp'] != null
                            ? (order['timestamp'] as Timestamp).toDate().toString()
                            : 'No Date';
                        final status = order['status'] ?? 'Pending';

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Food Name
                            Expanded(
                              flex: 2,
                              child: Text(
                                foodName,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            // Quantity
                            Expanded(
                              flex: 1,
                              child: Text(
                                quantity.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            // Date and Time
                            Expanded(
                              flex: 3,
                              child: Text(
                                timestamp,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                            // Status
                            Expanded(
                              flex: 2,
                              child: Text(
                                status,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        );
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
}
