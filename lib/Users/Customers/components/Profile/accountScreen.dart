import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../customerResponsive.dart'; // Assuming you have a similar Responsive class

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String email = "email@example.com"; // Placeholder
  String password = ""; // Placeholder for current password (ideally you'd get this securely)
  
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
    currentPasswordController.text = '';
    newPasswordController.text = '';
  }

  // Fetch the current user's email from FirebaseAuth
  Future<void> _fetchUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        email = user.email ?? 'No email available';
      });
    }
  }

  // Update the password if current password matches
  Future<void> _updatePassword() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && currentPasswordController.text.isNotEmpty) {
      final credentials = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPasswordController.text,
      );

      try {
        // Re-authenticate user with the current password
        await user.reauthenticateWithCredential(credentials);

        // Update the password if re-authentication is successful
        await user.updatePassword(newPasswordController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 800),
            content: Text('Password updated successfully'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            duration: Duration(milliseconds: 800),
            content: Text('Failed to update password. Current password might be incorrect.'),
          ),
        );
      }
    }
  }

  // Show Edit Dialog for Password
  void _showEditDialog(String field) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isPasswordVisible = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                'Update Password',
                style: TextStyle(fontSize: 13),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPasswordController,
                    style: const TextStyle(fontSize: 12),
                    obscureText: !isPasswordVisible,
                    decoration: const InputDecoration(
                      fillColor: Colors.white,
                      hoverColor: Colors.white,
                      labelText: 'Current Password',
                      hintStyle: TextStyle(fontSize: 10),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: newPasswordController,
                    obscureText: !isPasswordVisible,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      fillColor: Colors.white,
                      hoverColor: Colors.white,
                      labelText: 'New Password',
                      hintStyle: TextStyle(fontSize: 10),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: isPasswordVisible,
                        onChanged: (bool? value) {
                          setState(() {
                            isPasswordVisible = value ?? false;
                          });
                        },
                      ),
                      const Text(
                        'Show Passwords',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.grey[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    _updatePassword(); // Call function to update password
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Update',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _maskPassword(String password) {
    return '*' * password.length;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Responsive.isDesktop(context);
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !isDesktop,
        title: Row(
          mainAxisAlignment:
              isDesktop ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            if (!isDesktop) const Text('Account Details'),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            margin: isDesktop
                ? const EdgeInsets.symmetric(horizontal: 500.0, vertical: 250)
                : const EdgeInsets.all(0),
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 600 : double.infinity,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.grey.shade300, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Email:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      email,
                      style: const TextStyle(fontSize: 16),
                    ),
                    // Removed the edit icon from the email section
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Password:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Text(
                          _maskPassword(password),
                          style: const TextStyle(fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditDialog('password');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),

                // Only show "Go back" button if not on mobile screen
                if (!isMobile && !isTablet)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Center(child: Text('Go back')),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
