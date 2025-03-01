import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Admin Constants/Admin_Constants.dart';
import '../../Admin Constants/responsive_text.dart';

class TopFoods extends StatelessWidget {
  const TopFoods({super.key});

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
                    'Top Foods',
                    style: TextStyle(
                      fontSize: ResponsiveText.getTitleSize(context),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white70),
              // Foods List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('orderHistory').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Error loading foods',
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
                          'No foods available',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    // Calculate the total quantity ordered for each food
                    final foodMap = <String, Map<String, dynamic>>{}; // Store food name and its details
                    for (var order in orders) {
                      final items = order['items'] as List<dynamic>?;
                      if (items != null) {
                        for (var item in items) {
                          final foodName = item['foodName'] ?? 'Unknown';
                          final quantity = (item['quantity'] as num).toInt(); // Cast to int
                          final foodPicture = item['foodPicture'] ?? '';

                          if (foodMap.containsKey(foodName)) {
                            foodMap[foodName]!['quantity'] += quantity;
                          } else {
                            foodMap[foodName] = {
                              'quantity': quantity,
                              'foodPicture': foodPicture,
                            };
                          }
                        }
                      }
                    }

                    // Convert the map to a sorted list by quantity
                    final sortedFoodList = foodMap.entries.toList()
                      ..sort((a, b) => b.value['quantity'].compareTo(a.value['quantity']));

                    return ListView.separated(
                      itemCount: sortedFoodList.length,
                      separatorBuilder: (context, index) => const Divider(color: Colors.white54),
                      itemBuilder: (context, index) {
                        final food = sortedFoodList[index];
                        final foodName = food.key;
                        final foodPicture = food.value['foodPicture'];
                        final quantity = food.value['quantity'];

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: foodPicture.isNotEmpty
                                ? NetworkImage(foodPicture)
                                : null,
                            backgroundColor: bgColor,
                            child: foodPicture.isEmpty
                                ? const Icon(Icons.fastfood, color: Colors.white)
                                : null,
                          ),
                          title: Text(
                            foodName, // Food name
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: Text(
                            '$quantity orders', // Total quantity
                            style: const TextStyle(color: Colors.white),
                          ),
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