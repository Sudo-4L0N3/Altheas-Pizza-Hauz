import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String image, title, category, description;
  final String id;
  final double price;

  Product({
    required this.id,
    required this.image,
    required this.title,
    required this.price,
    required this.category,
    required this.description,
  });

  // Factory method to create a Product instance from Firestore document
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      title: data['name'] ?? '',
      image: data['image_url'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      description: data['description'] ?? '',
    );
  }
}

// Function to fetch products from Firestore
Future<List<Product>> fetchProductsFromFirestore() async {
  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('Menu').get();
  return querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
}
