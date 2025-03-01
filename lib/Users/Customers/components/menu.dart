import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:altheas_pizza_hauz/Users/Customers/components/History/OrderHistoryPage.dart';
import 'package:altheas_pizza_hauz/Users/Customers/components/Order%20Screen/OrderPage.dart';
import '../customerConstant.dart';
import '../customersScreen.dart';
import 'Profile/accountScreen.dart';
import 'Profile/profile_screen.dart';
import 'package:altheas_pizza_hauz/Login/Screens/Signup/signup_screen.dart'; // Import SignUpScreen

class HeaderMenu extends StatelessWidget {
  const HeaderMenu({
    super.key,
    required this.title,
    required this.press,
  });

  final String title;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class MobMenu extends StatefulWidget {
  const MobMenu({super.key});

  @override
  _MobMenuState createState() => _MobMenuState();
}

class _MobMenuState extends State<MobMenu> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    // Listen to authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _currentUser = user; // Update current user
      });
    });
  }

  // Function to show the confirmation dialog
  Future<void> showConfirmationDialog(
      BuildContext context, String title, String content, VoidCallback onConfirm) async {
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          actions: <Widget>[
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(80, 36), // Reduced size
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Slightly rounded corners
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: kPadding,
          ),
          // Conditionally show the Profile button only if the user is logged in
          if (_currentUser != null)
            HeaderMenu(
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              title: "Profile",
            ),
          const SizedBox(
            height: kPadding,
          ),
          // Conditionally show the Account button only if the user is logged in
          if (_currentUser != null)
            HeaderMenu(
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountScreen()),
                );
              },
              title: "Account",
            ),
          const SizedBox(
            height: kPadding,
          ),
          // Conditionally show the Order button only if the user is logged in
          if (_currentUser != null)
            HeaderMenu(
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrderPage()),
                );
              },
              title: "Order",
            ),
          const SizedBox(
            height: kPadding,
          ),
          // Conditionally show the History button only if the user is logged in
          if (_currentUser != null)
            HeaderMenu(
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrderHistoryPage()),
                );
              },
              title: "History",
            ),
          const SizedBox(
            height: kPadding,
          ),
          // Conditionally show the Logout button only if the user is logged in
          if (_currentUser != null)
            HeaderMenu(
              press: () {
                showConfirmationDialog(
                  context,
                  'Confirm Logout',
                  'Are you sure you want to logout?',
                  () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const CustomersScreen()),
                      (route) => false,
                    );
                  },
                );
              },
              title: "Logout",
            ),
          const SizedBox(
            height: kPadding,
          ),
          // Conditionally show the Register button if no user is logged in
          if (_currentUser == null)
            HeaderMenu(
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen()), // Navigate to SignUpScreen
                );
              },
              title: "Register / Login",
            ),
        ],
      ),
    );
  }
}
