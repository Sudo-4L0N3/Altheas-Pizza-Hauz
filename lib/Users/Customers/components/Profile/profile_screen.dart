// ignore: unused_import
import 'dart:html' as html; // For web file picker
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../customerResponsive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _username;
  String? _fullname;
  String? _address;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Function to generate a random username
  String _generateRandomUsername() {
    const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    return 'user_${List.generate(8, (index) => chars[random.nextInt(chars.length)]).join()}';
  }

  // Function to fetch user data from Firestore
  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final Map<String, dynamic> userData =
            userDoc.data() as Map<String, dynamic>;

        setState(() {
          _username = userData.containsKey('username')
              ? userData['username']
              : 'no data';
          _fullname = userData.containsKey('fullname')
              ? userData['fullname']
              : 'no data';
          _address =
              userData.containsKey('address') ? userData['address'] : 'no data';
          _imageUrl =
              userData.containsKey('imageUrl') ? userData['imageUrl'] : null;
        });
      } else {
        // If document does not exist or has no data, set fields to 'no data'
        setState(() {
          _username = 'no data';
          _fullname = 'no data';
          _address = 'no data';
          _imageUrl = null;
        });
      }
    }
  }

  // Function to update user data in Firestore
  Future<void> _updateUserData(String field, String newValue) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {
            field: newValue,
          },
          SetOptions(
              merge: true)); // Use merge to avoid overwriting other fields

      // Re-fetch the updated user data
      _fetchUserData();
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

        // Upload file
        await FirebaseStorage.instance
            .ref('profile_images/${user.uid}/$fileName')
            .putData(fileBytes);

        // Get download URL
        String downloadURL = await FirebaseStorage.instance
            .ref('profile_images/${user.uid}/$fileName')
            .getDownloadURL();

        // Update Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'imageUrl': downloadURL,
        }, SetOptions(merge: true));

        setState(() {
          _imageUrl = downloadURL;
        });
      }
    }
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
            if (!isDesktop) const Text('Profile'),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            margin: isDesktop
                ? const EdgeInsets.symmetric(horizontal: 200.0, vertical: 100)
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _pickImage();
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            _imageUrl != null ? NetworkImage(_imageUrl!) : null,
                        child: _imageUrl == null
                            ? Image.asset(
                                'assets/images/user.png',
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _username ?? 'No Username Found',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 10),
                      onPressed: () {
                        _showEditDialog(context, 'username', _username ?? '');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _fullname ?? 'No Name Found',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 10),
                      onPressed: () {
                        _showEditDialog(context, 'fullname', _fullname ?? '');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Address:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 10),
                      onPressed: () {
                        _showEditDialog(context, 'address', _address ?? '');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _address ?? '', //address placeholder
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
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
                    child: const Text('Go back'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Dialog to edit user data
  void _showEditDialog(
      BuildContext context, String field, String currentValue) {
    final TextEditingController controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $field', style: const TextStyle(fontSize: 16)),
          backgroundColor: Colors.white,
          content: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              labelText: 'Enter new $field',
              hintStyle: const TextStyle(fontSize: 14),
              focusColor: Colors.white,
              hoverColor: Colors.white,
              labelStyle: const TextStyle(color: Colors.black),
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
          ),
          actions: [
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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateUserData(field, controller.text);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
