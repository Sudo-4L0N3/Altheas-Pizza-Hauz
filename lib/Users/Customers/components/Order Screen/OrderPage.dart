// OrderPage.dart

import 'package:altheas_pizza_hauz/Users/Customers/components/Order%20Screen/Conponents/OrderReceiptPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart'; // Added import

// Import the OrderReceiptDialog from OrderReceiptPage.dart

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String? userEmail;
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
  }

  @override
  void dispose() {
    countdownTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> fetchUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
      });
    }
  }

  Future<void> updateOrderStatusToPickedUp(String orderId) async {
    try {
      await FirebaseFirestore.instance.collection('Order').doc(orderId).update({
        'status': 'Picked-up',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order marked as Picked-up.'),
          backgroundColor: Colors.green,
          duration: Duration(milliseconds: 800),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  Future<void> updateOrderStatusToComplete(String orderId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Update the Complete field in the order document
      await firestore.collection('Order').doc(orderId).update({
        'Complete': 'Yes',
      });

      // Fetch the updated order document to get its data
      DocumentSnapshot orderSnapshot =
          await firestore.collection('Order').doc(orderId).get();

      if (orderSnapshot.exists) {
        // Copy the order data to the orderHistory collection
        await firestore
            .collection('orderHistory')
            .doc(orderId)
            .set(orderSnapshot.data() as Map<String, dynamic>);

        // Delete the order from the Order collection
        await firestore.collection('Order').doc(orderId).delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order marked as Complete.'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 800),
          ),
        );
      } else {
        // Handle the case where the order document does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Order not found.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to complete order: $e'),
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  Future<void> showConfirmationDialog(BuildContext context, String title,
      String content, VoidCallback onConfirm) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // User must tap a button to dismiss (prevents accidental dismissal)
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18, // Increased font size for better readability
            ),
          ),
          content: Text(
            content,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          actions: <Widget>[
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog on cancel
              },
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(80, 36), // Reduced minimum size
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14, // Reduced font size
                  color: Colors.grey, // Subdued color for Cancel
                ),
              ),
            ),
            // Confirm Button
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog on confirm
                onConfirm(); // Perform the confirmed action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.green, // Confirm button color (can be customized)
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(80, 36), // Reduced minimum size
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8), // Slightly rounded corners
                ),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(
                  fontSize: 14, // Reduced font size
                  color: Colors.white, // White text for contrast
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to create ElevatedButtons with consistent styling
  Widget _buildElevatedButton({
    required String text,
    required VoidCallback onPressed,
    required Color color,
    required double fontSize,
    double verticalPadding = 16,
    double horizontalPadding = 16,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(
            vertical: verticalPadding, horizontal: horizontalPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
        minimumSize: Size(double.infinity, verticalPadding + 8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white, // Assuming all ElevatedButtons have white text
        ),
      ),
    );
  }

  // Helper method to create OutlinedButtons with consistent styling
  Widget _buildOutlinedButton({
    required String text,
    required VoidCallback onPressed,
    required Color borderColor,
    required Color textColor,
    required double fontSize,
    double verticalPadding = 12,
    double horizontalPadding = 16,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: borderColor),
        padding: EdgeInsets.symmetric(
            vertical: verticalPadding, horizontal: horizontalPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
        minimumSize: Size(double.infinity, verticalPadding + 8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 800;
    bool isTablet = screenWidth > 600 && screenWidth <= 800;
    bool isMobile = screenWidth <= 600;

    double fontSize = isDesktop ? 16 : (isTablet ? 14 : 12);
    double iconSize = isDesktop ? 40 : (isTablet ? 35 : 30);
    double svgSize = isDesktop ? 28 : (isTablet ? 24 : 20);
    EdgeInsets margin = isDesktop
        ? const EdgeInsets.symmetric(horizontal: 500)
        : (isTablet
            ? const EdgeInsets.symmetric(horizontal: 100)
            : const EdgeInsets.symmetric(horizontal: 16));

    if (userEmail == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Order')
          .where('email', isEqualTo: userEmail)
          .where('Complete', isEqualTo: 'No')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Scaffold(
            appBar: (isMobile || isTablet)
                ? AppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    title: const Text('Order'),
                  )
                : null,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No order data available"),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    width: isDesktop
                        ? 200
                        : double.infinity, // Limit width on desktop
                    child: _buildElevatedButton(
                      text: "Go Home",
                      onPressed: () {
                        Navigator.of(context).pop(); // Navigate back home
                      },
                      color: Colors.pink,
                      fontSize: fontSize,
                      verticalPadding: isDesktop ? 16 : 14,
                      horizontalPadding: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        var orderData = snapshot.data!.docs.first;
        var data = orderData.data() as Map<String, dynamic>?;
        var status = data?['status'] ?? 'Unknown';
        dynamic orderNumber = data?['orderNumber'] ?? 'Unknown';
        var orderId = orderData.id;
        String orderNumberString = orderNumber.toString();

        return Scaffold(
          appBar: (isMobile || isTablet)
              ? AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  title: const Text('Order Status'),
                )
              : null,
          body: Center(
            child: SingleChildScrollView(
              child: Container(
                margin: margin,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Removed "Order Status" Text
                      Text(
                        "Status: $status",
                        style: TextStyle(
                          fontSize: fontSize + 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Order Number
                      Text(
                        "Order Number: #$orderNumberString",
                        style: TextStyle(fontSize: fontSize + 4),
                      ),
                      const SizedBox(height: 20),
                      // Desktop-specific Estimated Time (if needed)
                      if (isDesktop)
                        _buildDesktopEstimatedTime(status, fontSize),
                      // Order Steps Icons
                      _buildOrderSteps(status, iconSize),
                      const SizedBox(height: 20),
                      // Support Center
                      _buildSupportCenterContainer(
                          svgSize, fontSize, orderNumberString),
                      const SizedBox(height: 20),
                      // Order Status Activities
                      _buildOrderStatusActivities(status, fontSize),
                      const SizedBox(height: 20),
                      // Conditional Button: "Complete Order" or "I Picked-up the order"
                      _buildConditionalOrderActionButton(
                          status, orderId, fontSize),
                      // Bottom Buttons: Order Receipt and Go Home
                      _buildBottomButtons(context, fontSize, orderId),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper widget to create the conditional order action button
  Widget _buildConditionalOrderActionButton(
      String status, String orderId, double fontSize) {
    if (status == "Done") {
      // Show "I Picked-up the order" button
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: _buildElevatedButton(
          text: "I Picked-up the order",
          onPressed: () {
            showConfirmationDialog(
              context,
              "Confirmation",
              "Are you sure you picked up the order?",
              () {
                updateOrderStatusToPickedUp(orderId);
              },
            );
          },
          color: Colors.green,
          fontSize: fontSize,
          verticalPadding: 14,
          horizontalPadding: 16,
        ),
      );
    } else if (status == "Picked-up") {
      // Only show "Complete Order" button
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: _buildElevatedButton(
          text: "Complete Order",
          onPressed: () {
            showConfirmationDialog(
              context,
              "Confirmation",
              "Are you sure you want to complete the order?",
              () {
                updateOrderStatusToComplete(orderId);
              },
            );
          },
          color: Colors.blue, // Use a distinct color for "Complete Order"
          fontSize: fontSize,
          verticalPadding: 14,
          horizontalPadding: 16,
        ),
      );
    } else {
      // For "Pending" and any other statuses, do not show any action button
      return const SizedBox.shrink();
    }
  }

  // Helper widgets for the order status steps, support center, etc.

  Widget _buildDesktopEstimatedTime(String status, double fontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "",
          style: TextStyle(color: Colors.black, fontSize: fontSize),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildOrderSteps(String status, double iconSize) {
    // Determine the asset for the verified step based on the status
    String verifiedAsset = status == "Picked-up"
        ? 'assets/process/verified.gif'
        : 'assets/process/verified.png';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildOrderStepWithConditionalMenuImage(status, iconSize),
        _buildOrderStepWithConditionalFryingPanImage(status, iconSize),
        _buildOrderStepWithConditionalChefImage(status, iconSize),
        _buildStepIcon(verifiedAsset, iconSize), // Updated asset selection
      ],
    );
  }

  Widget _buildOrderStepWithConditionalFryingPanImage(
      String status, double iconSize) {
    String fryingPanAsset;
    double fryingPanSize = iconSize;

    if (status == "Accepted") {
      fryingPanAsset = 'assets/process/frying-pan.gif';
      fryingPanSize = iconSize + 20;
    } else {
      fryingPanAsset = 'assets/process/frying-pan.png';
    }

    return Row(
      children: [
        _buildStepIcon(fryingPanAsset, fryingPanSize),
        _buildDashedLine(horizontal: true),
      ],
    );
  }

  Widget _buildOrderStepWithConditionalChefImage(
      String status, double iconSize) {
    String chefAsset;
    double chefSize = iconSize;

    if (status == "Done") {
      chefAsset = 'assets/process/chef.gif';
      chefSize = iconSize + 20;
    } else {
      chefAsset = 'assets/process/chef.png';
    }

    return Row(
      children: [
        _buildStepIcon(chefAsset, chefSize),
        _buildDashedLine(horizontal: true),
      ],
    );
  }

  Widget _buildOrderStepWithConditionalMenuImage(
      String status, double iconSize) {
    String menuAsset;
    double menuSize = iconSize;

    if (status == "Pending") {
      menuAsset = 'assets/process/menu.gif';
      menuSize = iconSize + 20;
    } else {
      menuAsset = 'assets/process/menu.png';
    }

    return Row(
      children: [
        _buildStepIcon(menuAsset, menuSize),
        _buildDashedLine(horizontal: true),
      ],
    );
  }

  Widget _buildStepIcon(String imageAsset, double iconSize) {
    return Image.asset(
      imageAsset,
      width: iconSize,
      height: iconSize,
    );
  }

  Widget _buildDashedLine({bool horizontal = true}) {
    return SizedBox(
      width: horizontal ? 60 : null,
      height: horizontal ? null : 30,
      child: Dash(
        direction: horizontal ? Axis.horizontal : Axis.vertical,
        length: 60,
        dashLength: 4,
        dashGap: 2,
        dashColor: Colors.black,
        dashThickness: 2,
      ),
    );
  }

  Widget _buildSupportCenterContainer(
      double svgSize, double fontSize, String orderNumberString) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: _buildSupportCenter(svgSize, fontSize, orderNumberString),
    );
  }

  Widget _buildSupportCenter(
      double svgSize, double fontSize, String orderNumberString) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Support center",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
            ),
            Text(
              "Order #$orderNumberString",
              style: TextStyle(color: Colors.grey, fontSize: fontSize - 2),
            ),
          ],
        ),
        Row(
          children: [
            InkWell(
              onTap: _launchMessenger, // Added onTap functionality
              child: SvgPicture.asset(
                'assets/icons/m2.svg',
                width: svgSize,
                height: svgSize,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Method to launch the Messenger link
  Future<void> _launchMessenger() async {
    final Uri messengerUri = Uri.parse(
        'https://web.facebook.com/messages/t/111863811741014?locale=fo_FO');
    if (await canLaunchUrl(messengerUri)) {
      await launchUrl(messengerUri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch Messenger link'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildOrderStatusActivities(String status, double fontSize) {
    return Column(
      children: [
        _buildOrderStatusStep(
            "Your order has been received",
            status == "Accepted" || status == "Done" || status == "Picked-up",
            fontSize,
            isLastStep: false),
        _buildDashedVerticalLine(),
        _buildOrderStatusStep(
            "The restaurant is preparing your food",
            status == "Accepted" || status == "Done" || status == "Picked-up",
            fontSize,
            isLastStep: false),
        _buildDashedVerticalLine(),
        _buildOrderStatusStep("Your order preparation done",
            status == "Done" || status == "Picked-up", fontSize,
            isLastStep: false),
        _buildDashedVerticalLine(),
        _buildOrderStatusStep("Waiting for you to pick up the order",
            status == "Picked-up", fontSize,
            isLastStep: true),
      ],
    );
  }

  Widget _buildOrderStatusStep(String text, bool isComplete, double fontSize,
      {bool isLastStep = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isComplete ? Colors.pink : Colors.grey,
            ),
            if (!isLastStep) const SizedBox(height: 8),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isComplete ? Colors.black : Colors.grey,
              fontSize: fontSize,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashedVerticalLine() {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 11), // Adjusted for alignment
          height: 30,
          child: const Dash(
            direction: Axis.vertical,
            length: 30,
            dashLength: 4,
            dashGap: 2,
            dashColor: Colors.grey,
            dashThickness: 2,
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  // Updated _buildBottomButtons to accept orderId
  Widget _buildBottomButtons(
      BuildContext context, double fontSize, String orderId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildOutlinedButton(
          text: "Order Receipt",
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return OrderReceiptDialog(orderId: orderId);
              },
            );
          },
          borderColor: Colors.pink,
          textColor: Colors.pink,
          fontSize: fontSize,
          verticalPadding: 12,
          horizontalPadding: 16,
        ),
        const SizedBox(height: 10),
        _buildElevatedButton(
          text: "Go Home",
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Colors.pink,
          fontSize: fontSize,
          verticalPadding: 14,
          horizontalPadding: 16,
        ),
      ],
    );
  }
}
