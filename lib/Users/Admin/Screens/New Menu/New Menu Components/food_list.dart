import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import '../../../Admin Constants/Admin_Constants.dart';

const textColor = Colors.white; // Define a text color constant

class FoodList extends StatefulWidget {
  const FoodList({super.key});

  @override
  _FoodListState createState() => _FoodListState();
}

class _FoodListState extends State<FoodList> {
  int itemsToShow = 10; // Default number of items to show

  @override
  Widget build(BuildContext context) {
    return Container(
      color: secondaryColor, // Set the background color
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Text
          const Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: Text(
              'List of Food',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          // Dropdown to select number of items to show
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Row(
              children: [
                const Text('Show:', style: TextStyle(color: textColor)),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: itemsToShow,
                  dropdownColor: bgColor,
                  items: [5, 10, 15, 20].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(
                        '$value',
                        style: const TextStyle(color: textColor),
                      ),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      itemsToShow = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Expanded ListView to display food items from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Menu').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('No items found',
                          style: TextStyle(color: textColor)));
                }

                final foodItems = snapshot.data!.docs;

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: defaultPadding),
                  itemCount: itemsToShow.clamp(0, foodItems.length),
                  itemBuilder: (context, index) {
                    final item = foodItems[index];
                    final itemName = item[
                        'name']; // Assuming 'name' is the field in Firestore
                    final itemPrice = item[
                        'price']; // Assuming 'price' is the field in Firestore
                    final itemDescription = item[
                        'description']; // Assuming 'description' is the field in Firestore
                    final imageUrl = item[
                        'image_url']; // Assuming 'image_url' is the field in Firestore

                    return Container(
                      decoration: BoxDecoration(
                        color: index % 2 == 0 ? bgColor : fillColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: FutureBuilder<String>(
                          future: _getImageUrl(imageUrl),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                width: 50,
                                height: 50,
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError ||
                                !snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Icon(Icons.broken_image,
                                  size: 50, color: Colors.red);
                            }
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  5), // Optional: add border radius
                              child: Image.network(
                                snapshot.data!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  return const Icon(Icons.broken_image,
                                      size: 50, color: Colors.red);
                                },
                              ),
                            );
                          },
                        ),
                        title: Text(
                          itemName,
                          style: const TextStyle(color: textColor),
                        ),
                        subtitle: Text(
                          'Price: ₱${itemPrice.toString()}',
                          style: const TextStyle(color: textColor),
                        ),
                        onTap: () {
                          _showFoodDialog(context, itemName, itemPrice,
                              itemDescription, imageUrl);
                        },
                        trailing: IconButton(
                          icon:
                              const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            // Show a confirmation dialog before deleting
                            bool confirmDelete =
                                await _showDeleteConfirmationDialog(context);
                            if (confirmDelete) {
                              // If the user confirms, call delete function
                              await _deleteMenuItem(item.id, imageUrl);
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Delete',
                  style: TextStyle(color: Colors.white)),
              content: const Text('Are you sure you want to delete this item?',
                  style: TextStyle(color: textColor)),
              backgroundColor: secondaryColor,
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context)
                        .pop(false); // Return false if cancel is pressed
                  },
                ),
                TextButton(
                  child: const Text('Delete',
                      style: TextStyle(color: Colors.redAccent)),
                  onPressed: () {
                    Navigator.of(context)
                        .pop(true); // Return true if delete is confirmed
                  },
                ),
              ],
            );
          },
        ) ??
        false; // Return false if the dialog is dismissed
  }

  // Function to show food item details in a dialog
  // Function to show food item details in a dialog
  void _showFoodDialog(BuildContext context, String name, double price,
      String description, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: secondaryColor,
          title: Text(name, style: const TextStyle(color: textColor)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl.isNotEmpty)
                  FutureBuilder<String>(
                    future: _getImageUrl(imageUrl),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return const Center(
                          child: Icon(Icons.broken_image,
                              size: 100, color: Colors.red),
                        );
                      }
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 200, // Limit the height of the image
                            maxWidth: 300, // Limit the width of the image
                          ),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(8.0), // Rounded corners
                            child: Image.network(
                              snapshot.data!,
                              fit: BoxFit.cover,
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace? stackTrace) {
                                return const Icon(Icons.broken_image,
                                    size: 100, color: Colors.red);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 16),
                Text(
                  'Price: ₱${price.toStringAsFixed(2)}',
                  style: const TextStyle(color: textColor),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Description:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(color: textColor),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// Helper function to get the download URL
  Future<String> _getImageUrl(String imageUrl) async {
    try {
      // Check if the imageUrl is already a valid URL
      if (imageUrl.startsWith('http')) {
        return imageUrl;
      }
      // If imageUrl is a storage path, get the download URL
      final ref = FirebaseStorage.instance.ref().child(imageUrl);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error getting download URL: $e');
      return '';
    }
  }

  // Function to delete the menu item from Firestore and delete the image from Firebase Storage
  // Function to delete the menu item from Firestore and delete the image from Firebase Storage
  Future<void> _deleteMenuItem(String docId, String imageUrl) async {
    try {
      // First delete the image from Firebase Storage
      if (imageUrl.isNotEmpty) {
        // Check if imageUrl is a download URL or storage path
        Reference ref;
        if (imageUrl.startsWith('http')) {
          ref = FirebaseStorage.instance.refFromURL(imageUrl);
        } else {
          ref = FirebaseStorage.instance.ref().child(imageUrl);
        }
        await ref.delete();
      }

      // Then delete the Firestore document
      await FirebaseFirestore.instance.collection('Menu').doc(docId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Menu item deleted successfully!'),
          duration: Duration(milliseconds: 700), // Custom duration
          backgroundColor: Colors.red, // Custom background color
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete item: $e')),
      );
    }
  }
}
