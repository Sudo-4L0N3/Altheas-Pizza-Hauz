import 'package:flutter/material.dart';

class OrderDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsDialog({super.key, required this.order});

  @override
  _OrderDetailsDialogState createState() => _OrderDetailsDialogState();
}

class _OrderDetailsDialogState extends State<OrderDetailsDialog> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Get the screen width to adjust the image size based on screen size
    double screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        width: screenWidth > 600
            ? 600
            : screenWidth * 0.9, // Max width 600px on large screens
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order #${widget.order['id']} Details",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Customer Info
              Text(
                "Customer Name: ${widget.order['customerName']}",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Email: ${widget.order['email']}"),
              Text("Address: ${widget.order['address']}"),
              const SizedBox(height: 16),

              // Order Info
              const Text(
                "Order Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Priority: ${widget.order['priority']}"),
              Text("Status: ${widget.order['status']}"),
              Text("Total Amount: ₱${widget.order['totalAmount'].toStringAsFixed(2)}"),
              const SizedBox(height: 16),

              // Items Ordered
              const Text(
                "Items Ordered",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Expandable list of items with food images
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: isExpanded
                    ? (widget.order['items'] as List).length
                    : (widget.order['items'] as List).length.clamp(0, 3),
                itemBuilder: (context, index) {
                  final item = widget.order['items'][index];
                  
                  // Image size adjustment based on screen size
                  double imageSize = screenWidth < 600 ? 40 : 50;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0), // Reduced border radius
                      child: item['foodPicture'] != null
                          ? Image.network(
                              item['foodPicture'],
                              width: imageSize, // Dynamically adjust width
                              height: imageSize, // Dynamically adjust height
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.fastfood), // Placeholder icon if no image is available
                    ),
                    title: Text(item['foodName']),
                    subtitle: Text("Quantity: ${item['quantity']}"),
                    trailing: Text("₱${item['totalPrice'].toStringAsFixed(2)}"),
                  );
                },
              ),
              if ((widget.order['items'] as List).length > 3) ...[
                TextButton(
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5, horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    backgroundColor: Colors.grey[600], // Solid background color
                  ),
                  child: Text(
                    isExpanded ? "Show Less" : "Show More",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Close Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
