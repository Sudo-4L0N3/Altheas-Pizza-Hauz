import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // For checking if running on web or desktop

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  // Define a consistent color scheme
  static const Color primaryColor = Colors.black;
  static const Color accentColor = Colors.black;
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardBackgroundColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDesktop = kIsWeb && MediaQuery.of(context).size.width > 800;

    // Get screen width to adjust sizes
    final screenWidth = MediaQuery.of(context).size.width;

    // Define breakpoints for responsiveness
    bool isMobile = screenWidth < 600;
    bool isTablet = screenWidth >= 600 && screenWidth < 1200;
    // Desktop is already defined as width >= 800, adjust as needed

    // Function to scale font size based on screen size
    double getFontSize(double mobile, double tablet, double desktop) {
      if (isMobile) return mobile;
      if (isTablet) return tablet;
      return desktop;
    }

    // Function to scale image size based on screen size
    double getImageSize(double mobile, double tablet, double desktop) {
      if (isMobile) return mobile;
      if (isTablet) return tablet;
      return desktop;
    }

    // Function to scale padding based on screen size
    EdgeInsets getResponsivePadding() {
      if (isMobile) {
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      } else if (isTablet) {
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      } else {
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
      }
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: isDesktop
          ? null
          : AppBar(
              title: Text(
                'Order History',
                style: TextStyle(
                  fontSize: getFontSize(18, 20, 22),
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
            ),
      body: Center(
        child: Container(
          margin: isDesktop
              ? const EdgeInsets.symmetric(horizontal: 200, vertical: 20)
              : EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16, vertical: isMobile ? 8 : 10),
          padding: getResponsivePadding(),
          decoration: BoxDecoration(
            color: cardBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orderHistory')
                .where('email', isEqualTo: user?.email)
                .snapshots(),
            builder: (context, snapshot) {
              // Retain the original data fetching logic

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading order history'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No order history found'));
              }

              final orders = snapshot.data!.docs;

              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final items = order['items'] as List<dynamic>;

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ExpansionTile(
                      initiallyExpanded: false,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order['orderNumber']}',
                            style: TextStyle(
                              fontSize: getFontSize(16, 18, 20),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Status: ${order['status']}',
                                style: TextStyle(
                                  fontSize: getFontSize(12, 14, 16),
                                  color: order['status']
                                              .toString()
                                              .toLowerCase() ==
                                          'delivered'
                                      ? Colors.green
                                      : Colors.green, // Adjust color as needed
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '₱${order['totalPrice']}',
                                style: TextStyle(
                                  fontSize: getFontSize(14, 16, 18),
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      subtitle: Text(
                        'Placed on: ${order['timestamp'].toDate().toLocal().toString().split(' ')[0]}',
                        style: TextStyle(
                          fontSize: getFontSize(10, 12, 14),
                          color: Colors.grey,
                        ),
                      ),
                      children: [
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: items.map((item) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        item['foodPicture'],
                                        width:
                                            getImageSize(40, 50, 60), // Responsive
                                        height:
                                            getImageSize(40, 50, 60), // Responsive
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            width:
                                                getImageSize(40, 50, 60), // Responsive
                                            height:
                                                getImageSize(40, 50, 60), // Responsive
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.broken_image,
                                                color: Colors.grey),
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(width: isMobile ? 8 : 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['foodName'],
                                            style: TextStyle(
                                              fontSize: getFontSize(
                                                  14, 16, 18),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Quantity: ${item['quantity']}',
                                            style: TextStyle(
                                              fontSize: getFontSize(
                                                  12, 14, 16),
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '₱${item['totalPrice']}',
                                      style: TextStyle(
                                        fontSize:
                                            getFontSize(14, 16, 18),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Total: ₱${order['totalPrice']}',
                              style: TextStyle(
                                fontSize: getFontSize(14, 16, 18),
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
