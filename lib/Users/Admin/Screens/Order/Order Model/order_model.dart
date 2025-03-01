// order_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FoodItem {
  final String foodName;
  final int quantity;
  final String foodPicture;

  FoodItem({
    required this.foodName,
    required this.quantity,
    required this.foodPicture,
  });

  // Factory method to create FoodItem from Firestore document
  factory FoodItem.fromFirestore(Map<String, dynamic> data) {
    return FoodItem(
      foodName: data['foodName'] ?? '',
      quantity: data['quantity'] ?? 0,
      foodPicture: data['foodPicture'] ?? '',
    );
  }

  // Method to convert FoodItem to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'foodName': foodName,
      'quantity': quantity,
      'foodPicture': foodPicture,
    };
  }
}

class Order {
  final String documentId;
  final String orderNumber;
  final DateTime date;
  final String status;
  final List<FoodItem> foods;
  final double totalPrice;
  final String service;
  final String priority;
  final String fullname;
  final String address;
  final String email;
  final String username;

  Order({
    required this.documentId,
    required this.orderNumber,
    required this.date,
    required this.status,
    required this.foods,
    required this.totalPrice,
    required this.service,
    required this.priority,
    required this.fullname,
    required this.address,
    required this.email,
    required this.username,
  });

  // Factory method to create Order from Firestore document
  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Order(
      documentId: doc.id,
      orderNumber: data['orderNumber'] != null ? data['orderNumber'].toString() : '',
      date: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      status: data['status'] ?? 'Unknown',
      foods: data['items'] != null
          ? (data['items'] as List<dynamic>)
              .map((item) => FoodItem.fromFirestore(item as Map<String, dynamic>))
              .toList()
          : [],
      totalPrice: data['totalPrice'] != null ? (data['totalPrice'] as num).toDouble() : 0.0,
      service: 'Delivery',
      priority: data['priority'] ?? 'No',
      fullname: data['fullname'] ?? '',
      address: data['address'] ?? '',
      email: data['email'] ?? '',
      username: data['username'] ?? '',
    );
  }
}
