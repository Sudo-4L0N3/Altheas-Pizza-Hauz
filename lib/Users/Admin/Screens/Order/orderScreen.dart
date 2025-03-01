import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'
    hide Order; // Hiding Firestore's Order class
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Import intl package
// For FilteringTextInputFormatter
import '../../Admin Constants/Admin_Constants.dart';
import '../../controllers/menu_app_controller.dart';
import '../New Dashbaord/dashboard_screen.dart';
import 'Order Model/order_model.dart';

class Orderscreen extends StatefulWidget {
  const Orderscreen({super.key});

  @override
  _OrderscreenState createState() => _OrderscreenState();
}

class _OrderscreenState extends State<Orderscreen> {
  int rowsToShow = 10; // Default rows to show
  String searchQuery = ''; // Holds the current search query

  @override
  void initState() {
    super.initState();
  }

  // Reusable Custom Dialog Function
  Future<void> showCustomDialog({
    required BuildContext context,
    required String title,
    required Widget content,
    required List<Widget> actions,
    bool barrierDismissible = false,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18, // Larger font size for title
            ),
          ),
          content: content,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          actions: actions,
        );
      },
    );
  }

  // Stream to fetch orders excluding orders with the status "Picked-up"
  Stream<List<Order>> streamOrders() {
    return FirebaseFirestore.instance.collection('Order').snapshots().map(
      (snapshot) {
        List<Order> orders =
            snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();

        // Sorting the orders based on status and priority
        orders.sort((a, b) {
          // Sort by status: Pending first, then Accepted, then Done
          if (a.status == 'Pending' && b.status != 'Pending') {
            return -1;
          } else if (a.status != 'Pending' && b.status == 'Pending') {
            return 1;
          } else if (a.status == 'Accepted' && b.status == 'Done') {
            return -1;
          } else if (a.status == 'Done' && b.status == 'Accepted') {
            return 1;
          }

          // If both have the same status, sort by priority: Yes first, then No
          if (a.priority == 'Yes' && b.priority == 'No') {
            return -1;
          } else if (a.priority == 'No' && b.priority == 'Yes') {
            return 1;
          }

          // If both have the same status and priority, return 0 (no change in order)
          return 0;
        });

        return orders;
      },
    );
  }

  // Filter orders based on the search query
  List<Order> _filterOrders(List<Order> orders, String query) {
    if (query.isEmpty) {
      return orders;
    }

    return orders.where((order) {
      final orderNumber = order.orderNumber.toString().toLowerCase();
      final status = order.status.toLowerCase();
      final fullname = order.fullname.toLowerCase();
      final priority = order.priority.toLowerCase();
      final username = order.username.toLowerCase();
      final searchLower = query.toLowerCase();

      return orderNumber.contains(searchLower) ||
          status.contains(searchLower) ||
          fullname.contains(searchLower) ||
          priority.contains(searchLower) ||
          username.contains(searchLower);
    }).toList();
  }

  // Handles the Reject action
  void _handleReject(Order order) {
    showCustomDialog(
      context: context,
      title: 'Reject Order #${order.orderNumber}?',
      content: const Text(
        'Are you sure you want to reject this order?',
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        // Cancel Button
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: const Size(80, 36),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
        // Confirm Button
        ElevatedButton(
          onPressed: () async {
            try {
              // Update the order status to 'Rejected'
              await FirebaseFirestore.instance
                  .collection('Order')
                  .doc(order.documentId)
                  .update({
                'status': 'Rejected',
              });

              // Remove the rejected order from Firestore
              await FirebaseFirestore.instance
                  .collection('Order')
                  .doc(order.documentId)
                  .delete();

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order #${order.orderNumber} Rejected and Removed'),
                ),
              );
            } catch (e) {
              print('Error rejecting order: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to reject the order. Please try again.'),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: const Size(80, 36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Confirm',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // Handles the Done action
  void _handleDone(Order order) {
    showCustomDialog(
      context: context,
      title: 'Mark Order #${order.orderNumber} as Done?',
      content: const Text(
        'Are you sure you want to mark this order as Done?',
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        // Cancel Button
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: const Size(80, 36),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
        // Confirm Button
        ElevatedButton(
          onPressed: () async {
            try {
              FirebaseFirestore firestore = FirebaseFirestore.instance;

              // Update the status of the order to 'Done'
              await firestore.collection('Order').doc(order.documentId).update({
                'status': 'Done',
              });

              // If the order's status is "Picked-up", automatically save it to OrderHistory
              if (order.status == 'Picked-up') {
                Map<String, dynamic> orderData = {
                  'orderNumber': order.orderNumber,
                  'fullname': order.fullname,
                  'address': order.address,
                  'email': order.email,
                  'username': order.username,
                  'totalPrice': order.totalPrice,
                  'status': 'Picked-up',
                  'foods': order.foods.map((food) => food.toMap()).toList(),
                  'date': order.date,
                  'priority': order.priority,
                };

                await firestore.collection('OrderHistory').add(orderData);

                await firestore.collection('Order').doc(order.documentId).delete();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Order #${order.orderNumber} moved to Order History and removed'),
                  ),
                );
              }

              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order #${order.orderNumber} marked as Done'),
                ),
              );
            } catch (e) {
              print('Error handling Done action: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to mark the order as Done. Please try again.'),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: const Size(80, 36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Confirm',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // Handles the Overview action
  void _handleOverview(Order order) {
    showCustomDialog(
      context: context,
      title: 'Order Overview #${order.orderNumber}',
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Fullname: ${order.fullname}',
                style: const TextStyle(fontSize: 16)),
            Text('Address: ${order.address}',
                style: const TextStyle(fontSize: 16)),
            Text('Email: ${order.email}', style: const TextStyle(fontSize: 16)),
            Text('Username: ${order.username}',
                style: const TextStyle(fontSize: 16)),
            Text('Total Price: ₱${order.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16)),
            Text('Status: ${order.status}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            const Text('Foods:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ...order.foods.map((food) {
              return Text('${food.foodName} x${food.quantity}',
                  style: const TextStyle(fontSize: 16));
            }),
          ],
        ),
      ),
      actions: [
        // Close Button
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: const Size(80, 36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Close',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // Handles the Accept action
  void _handleAccept(Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              title: Text(
                'Accept Order #${order.orderNumber}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    const Text(
                      'Order Information:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    _buildOrderDetailRow('Fullname:', order.fullname),
                    _buildOrderDetailRow('Address:', order.address),
                    _buildOrderDetailRow('Email:', order.email),
                    _buildOrderDetailRow('Username:', order.username),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              actions: <Widget>[
                // Cancel Button
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: const Size(80, 36),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Accept Button
                ElevatedButton(
                  onPressed: () async {
                    // Update Firestore document
                    try {
                      await FirebaseFirestore.instance
                          .collection('Order')
                          .doc(order.documentId)
                          .update({
                        'status': 'Accepted',
                      });

                      // Close the dialog
                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Order #${order.orderNumber} Accepted',
                          ),
                        ),
                      );
                    } catch (e) {
                      print('Error updating order: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Failed to accept the order. Please try again.'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: const Size(80, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Accept',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildOrderDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    final double fontSize = isDesktop ? 13.0 : 12.0;
    final double headerFontSize = isDesktop ? 16.0 : 14.0;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  context
                      .read<MenuAppController>()
                      .changeScreen(const DashboardScreen());
                },
              ),
              title:
                  const Text('Orders', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.grey[900],
            ),
      backgroundColor: Colors.grey[800],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search bar widget
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search Orders...',
                        fillColor: fillColor,
                        hintStyle: TextStyle(color: Colors.white70),
                        icon: Icon(Icons.search, color: Colors.white70),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (query) {
                        setState(() {
                          searchQuery = query;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<List<Order>>(
                    stream: streamOrders(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No Orders Found');
                      }

                      List<Order> orders =
                          _filterOrders(snapshot.data!, searchQuery);

                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Table Header
                            Container(
                              color: Colors.grey[900],
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  headerCell("Order Number",
                                      flex: 2, fontSize: headerFontSize),
                                  headerCell("Date & Time",
                                      flex: 2, fontSize: headerFontSize),
                                  headerCell("Status",
                                      flex: 2, fontSize: headerFontSize),
                                  headerCell("Priority",
                                      flex: 2, fontSize: headerFontSize),
                                  headerCell("Foods & Quantity",
                                      flex: 3, fontSize: headerFontSize),
                                  headerCell("Total Price",
                                      flex: 2, fontSize: headerFontSize),
                                  headerCell("Action",
                                      flex: 3,
                                      fontSize:
                                          headerFontSize), // Action Column
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: rowsToShow.clamp(0, orders.length),
                                itemBuilder: (context, index) {
                                  final order = orders[index];
                                  String formattedDate =
                                      DateFormat('yyyy-MM-dd hh:mm a')
                                          .format(order.date);

                                  return Container(
                                    color: index % 2 == 0
                                        ? Colors.grey[600]
                                        : Colors.grey[700],
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Row(
                                      children: [
                                        dataCell('#${order.orderNumber}',
                                            flex: 2, fontSize: fontSize),
                                        dataCell(formattedDate,
                                            flex: 2, fontSize: fontSize),
                                        dataCell(order.status,
                                            flex: 2, fontSize: fontSize),
                                        dataCell(order.priority,
                                            flex: 2, fontSize: fontSize),
                                        dataCellWidget(
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: order.foods.map((food) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4.0),
                                                child: Row(
                                                  children: [
                                                    food.foodPicture.isNotEmpty
                                                        ? ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0),
                                                            child:
                                                                Image.network(
                                                              food.foodPicture,
                                                              height: 30,
                                                              width: 30,
                                                              fit: BoxFit.cover,
                                                              errorBuilder:
                                                                  (context,
                                                                      error,
                                                                      stackTrace) {
                                                                return const Icon(
                                                                    Icons
                                                                        .broken_image,
                                                                    size: 30);
                                                              },
                                                            ),
                                                          )
                                                        : const Icon(
                                                            Icons
                                                                .image_not_supported,
                                                            size: 30),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        "${food.foodName} (x${food.quantity})",
                                                        style: TextStyle(
                                                            fontSize: fontSize,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                          flex: 3,
                                        ),
                                        dataCell(
                                            "₱${order.totalPrice.toStringAsFixed(2)}",
                                            flex: 2,
                                            fontSize: fontSize),
                                        dataCellWidget(
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  _handleOverview(order);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.grey,
                                                  minimumSize:
                                                      const Size(60, 30),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Overview',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              ElevatedButton(
                                                onPressed: order.status ==
                                                            'Accepted' ||
                                                        order.status == 'Done'
                                                    ? null
                                                    : () {
                                                        _handleReject(order);
                                                      },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  minimumSize:
                                                      const Size(60, 30),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Reject',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              ElevatedButton(
                                                onPressed: order.status ==
                                                            'Accepted' ||
                                                        order.status == 'Done'
                                                    ? null
                                                    : () {
                                                        _handleAccept(order);
                                                      },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  minimumSize:
                                                      const Size(60, 30),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Accept',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              ElevatedButton(
                                                onPressed: order.status ==
                                                            'Pending' ||
                                                        order.status == 'Done'
                                                    ? null
                                                    : () {
                                                        _handleDone(order);
                                                      },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue,
                                                  minimumSize:
                                                      const Size(60, 30),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Done',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          ),
                                          flex: 3,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget headerCell(String text,
      {required int flex, required double fontSize}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: fontSize,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget dataCell(String text, {required int flex, required double fontSize}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: fontSize),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget dataCellWidget(Widget widget, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: widget,
      ),
    );
  }
}
