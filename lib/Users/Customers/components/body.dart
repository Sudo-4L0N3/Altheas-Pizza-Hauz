import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Model/product_model.dart';
import '../customerConstant.dart';
import 'product.dart';
import 'service_card.dart';
import 'Cart Components/cart_model.dart';

class BodyContainer extends StatefulWidget {
  const BodyContainer({super.key});

  @override
  _BodyContainerState createState() => _BodyContainerState();
}

class _BodyContainerState extends State<BodyContainer> {
  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = fetchProductsFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kPadding),
      constraints: const BoxConstraints(maxWidth: kMaxWidth),
      child: Column(
        children: [
          const ServicesCard(),
          FutureBuilder<List<Product>>(
            future: futureProducts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error loading products'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No products found'));
              } else {
                List<Product> products = snapshot.data!;
                // Group products by category
                Map<String, List<Product>> productsByCategory = {};
                for (var product in products) {
                  if (!productsByCategory.containsKey(product.category)) {
                    productsByCategory[product.category] = [];
                  }
                  productsByCategory[product.category]!.add(product);
                }
                return ProductCategoryList(
                    productsByCategory: productsByCategory);
              }
            },
          ),
        ],
      ),
    );
  }
}

class ProductCategoryList extends StatelessWidget {
  final Map<String, List<Product>> productsByCategory;

  const ProductCategoryList({super.key, required this.productsByCategory});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      children: productsByCategory.entries.map((entry) {
        String category = entry.key;
        List<Product> products = entry.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              category,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ProductGrid(products: products),
          ],
        );
      }).toList(),
    );
  }
}

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.products,
  });

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    int crossAxisCount;
    double childAspectRatio;

    // Adjust the number of columns and aspect ratio based on screen size
    if (size.width >= 1200) {
      crossAxisCount = 4;
      childAspectRatio = 1.2;
    } else if (size.width >= 900) {
      crossAxisCount = 3;
      childAspectRatio = 1.1;
    } else if (size.width >= 650) {
      crossAxisCount = 2;
      childAspectRatio = 1.0;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 0.8;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => Products(
        press: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return ProductDetailsDialog(product: products[index]);
            },
          );
        },
        product: products[index],
      ),
      itemCount: products.length,
    );
  }
}

// ProductDetailsDialog widget
class ProductDetailsDialog extends StatelessWidget {
  final Product product;

  const ProductDetailsDialog({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    var cart = context.watch<CartModel>();
    bool isInCart = cart.cartItems.any((item) => item.keys.first.id == product.id);

    // Get screen width to adjust layout for mobile vs larger screens
    double screenWidth = MediaQuery.of(context).size.width;

    // Adjustments for mobile screens
    double dialogWidth = screenWidth < 600 ? 70 : 300; // Smaller width for mobile
    double dialogHeight = screenWidth < 600 ? 150 : 350; // Smaller height for mobile
    double imageHeight = screenWidth < 600 ? 80 : 150; // Smaller image size for mobile
    double titleFontSize = screenWidth < 600 ? 14 : 18; // Smaller title text size for mobile
    double descriptionFontSize = screenWidth < 600 ? 10 : 14; // Smaller description text size
    double priceFontSize = screenWidth < 600 ? 12 : 16; // Smaller price text size
    double buttonFontSize = screenWidth < 600 ? 12 : 14; // Smaller button text size for mobile
    double buttonPadding = screenWidth < 600 ? 2 : 16; // Smaller padding for mobile

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Rounded corners for the dialog
      ),
      title: Text(product.title, style: TextStyle(fontSize: titleFontSize)),
      insetPadding: const EdgeInsets.all(5), // Reduced padding from screen edges
      content: SizedBox(
        width: dialogWidth, // Responsive width
        height: dialogHeight, // Responsive height
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with border radius
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15), // Rounded corners for the image
                  child: Image.network(
                    product.image,
                    height: imageHeight, // Responsive image height
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 50, color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Price
              Text(
                "Price: ₱${product.price.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: priceFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                product.description,
                style: TextStyle(fontSize: descriptionFontSize),
                maxLines: 10, // Limit the description to 3 lines
                overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton.icon(
          icon: Icon(isInCart ? Icons.shopping_cart : Icons.add_shopping_cart),
          style: ElevatedButton.styleFrom(
            backgroundColor: isInCart ? Colors.green : kPrimaryColorButton, // Green if in cart, blue if not
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Reduced border radius
            ),
            padding: EdgeInsets.symmetric(
              horizontal: buttonPadding, // Smaller padding for mobile
              vertical: screenWidth < 600 ? 2 : 12, // Smaller vertical padding for mobile
            ),
          ),
          onPressed: () {
            if (!isInCart) {
              cart.addItem(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.title} added to cart'),
                  duration: const Duration(milliseconds: 700),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.title} is already in the cart'),
                  duration: const Duration(milliseconds: 700),
                ),
              );
            }
          },
          label: Text(
            isInCart ? 'In Cart' : 'Add to Cart',
            style: TextStyle(fontSize: buttonFontSize), // Smaller text size for mobile
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.close),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[600], // Gray color for the Close button
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Reduced border radius
            ),
            padding: EdgeInsets.symmetric(
              horizontal: buttonPadding, // Smaller padding for mobile
              vertical: screenWidth < 600 ? 2 : 12, // Smaller vertical padding for mobile
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          label: Text('Close', style: TextStyle(fontSize: buttonFontSize)), // Smaller text for mobile
        ),
      ],
    );
  }
}
