import 'package:altheas_pizza_hauz/Login/constants.dart';
import 'package:altheas_pizza_hauz/Users/Customers/components/Order%20Screen/OrderPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../../customerResponsive.dart';
import '../../customersScreen.dart';
import '../Cart Components/cart_model.dart';
import '../Cart Components/cart_screen.dart';
import '../History/OrderHistoryPage.dart';
import '../Profile/accountScreen.dart';
import '../Profile/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:altheas_pizza_hauz/Login/Screens/Signup/signup_screen.dart'; // Import SignUpScreen

class Header extends StatelessWidget {
  const Header({
    super.key,
  });

  Future<void> showConfirmationDialog(BuildContext context, String title,
      String content, VoidCallback onConfirm) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
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
          content: Text(
            content,
            style: const TextStyle(
              fontSize: 16, // Standard font size for content
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
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(80, 36), // Reduced size
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14, // Slightly smaller font
                  color: Colors.grey, // Subtle color for Cancel
                ),
              ),
            ),
            // Confirm Button
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                onConfirm(); // Perform the confirmed action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, // Confirm button color
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(80, 36), // Reduced size
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8), // Slightly rounded corners
                ),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(
                  fontSize: 14, // Slightly smaller font
                  color: Colors.white, // White text for contrast
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var cart = context.watch<CartModel>();
    final user = FirebaseAuth.instance.currentUser;

    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu),
            ),
          ),
        if (!Responsive.isMobile(context))
          const Text(
            "Althea's Pizza Hauz",
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.w900,
              color: kPrimaryColor,
            ),
          ),
        const Spacer(),
        const Spacer(),
        const SizedBox(width: 10),
        badges.Badge(
          badgeContent: Text(
            cart.itemCount.toString(),
            style: const TextStyle(color: Colors.white),
          ),
          badgeAnimation: const badges.BadgeAnimation.scale(
            animationDuration: Duration(seconds: 1),
            colorChangeAnimationDuration: Duration(seconds: 1),
            loopAnimation: false,
            curve: Curves.fastOutSlowIn,
            colorChangeAnimationCurve: Curves.easeInCubic,
          ),
          badgeStyle: badges.BadgeStyle(
            shape: badges.BadgeShape.circle,
            badgeColor: kPrimaryColor,
            padding: const EdgeInsets.all(7),
            borderRadius: BorderRadius.circular(4),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.shopping_bag_outlined,
              color: kPrimaryColor,
              size: 35,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 20),
        if (!Responsive.isMobile(context))
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: PopupMenuButton<int>(
              icon: const Icon(
                Icons.person_outline,
                color: Colors.white,
              ),
              color: Colors.white,
              onSelected: (value) {
                switch (value) {
                  case 0:
                    // Navigate to Profile Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileScreen()),
                    );
                    break;
                  case 1:
                    // Navigate to Account Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AccountScreen()),
                    );
                    break;
                  case 2:
                    // Navigate to Order page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OrderPage()),
                    );
                    break;
                  case 3:
                    // Navigate to History Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OrderHistoryPage()),
                    );
                    break;
                  case 4:
                    // Show confirmation dialog for logout
                    showConfirmationDialog(
                      context,
                      'Confirm Logout',
                      'Are you sure you want to logout?',
                      () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushAndRemoveUntil(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CustomersScreen()),
                          (route) => false,
                        );
                      },
                    );
                    break;
                  case 5:
                    // Navigate to SignUpScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                if (user != null)
                  const PopupMenuItem<int>(
                    value: 0,
                    child: Text("Profile"),
                  ),
                if (user != null) // Conditionally show Account button
                  const PopupMenuItem<int>(
                    value: 1,
                    child: Text("Account"),
                  ),
                if (user != null)
                  const PopupMenuItem<int>(
                    value: 2,
                    child: Text("Order"),
                  ),
                if (user != null)
                  const PopupMenuItem<int>(
                    value: 3,
                    child: Text("History"),
                  ),
                if (user == null)
                  const PopupMenuItem<int>(
                    value: 5,
                    child: Text("Register / Login"),
                  ),
                if (user != null)
                  const PopupMenuItem<int>(
                    value: 4,
                    child: Text("Logout"),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
