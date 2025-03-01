import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

import '../../Admin Constants/Admin_Constants.dart';
import '../../Admin Constants/Admin_Responsive.dart';
import '../../controllers/menu_app_controller.dart';
import '../New Dashbaord/dashboard_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  _AdminProfileScreenState createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  bool isEditingAddress = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? _fullname;
  String? _role;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (adminDoc.exists && adminDoc.data() != null) {
        final Map<String, dynamic> adminData = adminDoc.data() as Map<String, dynamic>;

        setState(() {
          _fullname = adminData['fullname'] ?? 'Full Name not set';
          _role = adminData['role'] ?? 'Role not set';
          emailController.text = adminData['email'] ?? 'Email not available';
          addressController.text = adminData['address'] ?? 'Address not provided';
          _imageUrl = adminData.containsKey('imageUrl') ? adminData['imageUrl'] : null;
        });
      }
    }
  }

  Future<void> _updateAdminData(String field, String newValue) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        field: newValue,
      }, SetOptions(merge: true));

      _fetchAdminData();
    }
  }

  Future<void> _pickImage() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.bytes != null) {
        Uint8List fileBytes = result.files.single.bytes!;
        String fileName = result.files.single.name;

        await FirebaseStorage.instance
            .ref('admin_profile_images/${user.uid}/$fileName')
            .putData(fileBytes);

        String downloadURL = await FirebaseStorage.instance
            .ref('admin_profile_images/${user.uid}/$fileName')
            .getDownloadURL();

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'imageUrl': downloadURL,
        }, SetOptions(merge: true));

        setState(() {
          _imageUrl = downloadURL;
        });
      }
    }
  }

  Future<void> _changePasswordDialog() async {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    bool isPasswordVisible = false;
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                'Update Password',
                style: TextStyle(fontSize: 13),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: currentPasswordController,
                      style: const TextStyle(fontSize: 12),
                      obscureText: !isPasswordVisible,
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        labelText: 'Current Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your current password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: !isPasswordVisible,
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        labelText: 'New Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a new password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
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
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await _changePassword(
                        currentPasswordController.text,
                        newPasswordController.text,
                      );
                      Navigator.of(context).pop();
                    }
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

  Future<void> _changePassword(String currentPassword, String newPassword) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Re-authenticate the user with current password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      try {
        await user.reauthenticateWithCredential(credential);
        // If successful, update the password
        await user.updatePassword(newPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password changed successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Responsive.isDesktop(context);
    final bool isMobile = Responsive.isMobile(context);

    final double headerFontSize = isMobile ? 14.0 : 16.0;
    final double iconSize = isMobile ? 18.0 : 24.0;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: iconSize),
                onPressed: () {
                  context.read<MenuAppController>().changeScreen(const DashboardScreen());
                },
              ),
              title: Text(
                'Profile',
                style: TextStyle(color: Colors.white, fontSize: headerFontSize),
              ),
              backgroundColor: secondaryColor,
              iconTheme: IconThemeData(color: Colors.white, size: iconSize),
            ),
      backgroundColor: const Color(0xFF1D1E33),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    _pickImage();
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageUrl != null
                        ? NetworkImage(_imageUrl!)
                        : null,
                    child: _imageUrl == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _fullname ?? "Sample Admin",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _role ?? "Administrator",
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 30),
                _buildNonEditableProfileRow(
                  "Email",
                  emailController.text,
                ),
                const Divider(color: Colors.white24),
                _buildProfileInfoRow(
                  "Address",
                  addressController.text,
                  isEditingAddress,
                  () {
                    setState(() {
                      isEditingAddress = !isEditingAddress;
                    });
                    if (!isEditingAddress) {
                      _updateAdminData('address', addressController.text);
                    }
                  },
                  addressController,
                ),
                const Divider(color: Colors.white24),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    _changePasswordDialog();
                  },
                  icon: const Icon(Icons.lock, color: Colors.white),
                  label: const Text(
                    "Change Password",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // New method for non-editable email field
  Widget _buildNonEditableProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoRow(String label, String value, bool isEditing,
      VoidCallback onEditPressed, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          isEditing
              ? Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      fillColor: bgColor,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                )
              : Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
          IconButton(
            icon: Icon(
              isEditing ? Icons.check : Icons.edit,
              color: Colors.white,
              size: 20,
            ),
            onPressed: onEditPressed,
          ),
        ],
      ),
    );
  }
}
