import 'package:altheas_pizza_hauz/Login/Screens/Login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../Admin Constants/Admin_Constants.dart';
import '../../Admin Constants/Admin_Responsive.dart';
import '../../controllers/menu_app_controller.dart';
import '../New Dashbaord/dashboard_screen.dart';
import '../New Menu/NewMenuScreen.dart';
import '../Order/orderScreen.dart';
import '../Profile/profileScreen.dart';
import '../History/historyScreen.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  String? _fullName;
  String? _role;
  String? _profilePictureUrl;

  // Track back button presses
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _fullName = userData['fullname'] ?? 'Full Name not set';
          _role = userData['role'] ?? 'Role not set';
          _profilePictureUrl = userData['imageUrl'];
        });
      }
    }
  }

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
                  color: Colors.black, // Subtle color for Cancel
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

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();

    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to confirm logout'),
        ),
      );
      return Future.value(false); // Do not exit the app yet
    }

    // Show confirmation dialog if back is pressed twice
    return await showConfirmationDialog(
      context,
      'Confirm Logout',
      'Are you sure you want to logout?',
      () async {
        await FirebaseAuth.instance.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      },
    ).then((value) => false); // Return false to prevent automatic exit
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Capture the back button press
      child: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            color: drawerColor, // Set background color for the entire drawer
          ),
          child: ListView(
            children: [
              DrawerHeader(
                padding: EdgeInsets.zero,
                decoration: const BoxDecoration(color: drawerColor),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80, // Profile picture size
                        height: 80, // Profile picture size
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40.0), // Rounded border
                          child: _profilePictureUrl != null
                              ? Image.network(
                                  _profilePictureUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  "assets/images/user.png", // Fallback image if no profile picture
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _fullName ?? "Sample Admin", // Dynamically loaded full name
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _role ?? "Administrator", // Dynamically loaded role
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              DrawerListTile(
                title: "Dashboard",
                svgSrc: "assets/icons/menu_dashboard.svg",
                press: () {
                  context.read<MenuAppController>().changeScreen(const DashboardScreen());
                },
              ),
              DrawerListTile(
                title: "Profile",
                svgSrc: "assets/icons/menu_profile.svg",
                press: () {
                  context
                      .read<MenuAppController>()
                      .changeScreen(const AdminProfileScreen());
                },
              ),
              DrawerListTile(
                title: "Orders",
                svgSrc: "assets/icons/menu_notification.svg",
                press: () {
                  context
                      .read<MenuAppController>()
                      .changeScreen(const Orderscreen());
                },
              ),
              DrawerListTile(
                title: "New Menu",
                svgSrc: "assets/icons/add-menu.svg",
                press: () {
                  context
                      .read<MenuAppController>()
                      .changeScreen(const NewMenuScreen());
                },
              ),
              DrawerListTile(
                title: "History",
                svgSrc: "assets/icons/menu_doc.svg",
                press: () {
                  context
                      .read<MenuAppController>()
                      .changeScreen(const Historyscreen());
                },
              ),
              DrawerListTile(
                title: "Logout",
                svgSrc: "assets/icons/logout.svg",
                press: () {
                  showConfirmationDialog(
                    context,
                    'Confirm Logout',
                    'Are you sure you want to logout?',
                    () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    super.key,
    required this.title,
    required this.svgSrc,
    required this.press,
  });

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        if (!Responsive.isDesktop(context)) {
          Navigator.of(context).pop(); // Close the drawer first
          await Future.delayed(const Duration(milliseconds: 250)); // Wait for the drawer to close
        }
        press(); // Then execute the press callback
      },
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: const ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white54),
      ),
    );
  }
}
