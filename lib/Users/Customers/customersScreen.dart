import 'package:altheas_pizza_hauz/Login/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'components/body.dart';
import 'components/Header and Footer Components/footer.dart';
import 'components/Header and Footer Components/header_container.dart';
import 'components/menu.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  String? _username;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Function to fetch user data from Firestore
  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          _username = userDoc['username'] ?? 'no data';
          _imageUrl = userDoc['imageUrl'] ?? 'assets/images/Sample-picture.jpg'; // Default image if none
        });
      } else {
        // If document does not exist, set fields to default
        setState(() {
          _username = 'no data';
          _imageUrl = 'assets/images/Sample-picture.jpg'; // Default image
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            // Drawer Header with User's Picture and Username
            DrawerHeader(
              decoration: const BoxDecoration(
                color: kPrimaryColor, // Background color for header
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // User Profile Picture
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _imageUrl != null
                        ? (_imageUrl!.startsWith('http')
                            ? NetworkImage(_imageUrl!) // If imageUrl is a network link
                            : AssetImage(_imageUrl!) as ImageProvider) // If it's an asset image
                        : const AssetImage('assets/images/user.png'), // Fallback if no image
                  ),
                  const SizedBox(height: 15),
                  // User's Username
                  Text(
                    _username != null ? '@$_username' : 'No User Found', // Placeholder or fetched username
                    style: const TextStyle(
                      fontSize: 14.0,
                      
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Menu items in the Drawer
            const MobMenu(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              const HeaderContainer(),
              // Body
              const BodyContainer(),
              // Footer
              const SizedBox(
                height: 30,
              ),
              Footer(),
              // Responsive website layout
            ],
          ),
        ),
      ),
    );
  }
}
