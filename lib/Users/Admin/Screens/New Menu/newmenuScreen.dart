import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import '../../../Customers/customerResponsive.dart';
import '../../Admin Constants/Admin_Constants.dart';
import '../../controllers/menu_app_controller.dart';
import '../New Dashbaord/dashboard_screen.dart';
import 'New Menu Components/food_list.dart';

class NewMenuScreen extends StatefulWidget {
  const NewMenuScreen({super.key});

  @override
  _NewMenuScreenState createState() => _NewMenuScreenState();
}

class _NewMenuScreenState extends State<NewMenuScreen> {
  Uint8List? _imageData;
  // ignore: unused_field
  String? _imageUrl;

  // Controllers for capturing form data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Responsive.isDesktop(context);
    final bool isMobile = Responsive.isMobile(context);
    final double headerFontSize = isMobile ? 14.0 : 16.0;
    final double iconSize = isMobile ? 18.0 : 24.0;

    return WillPopScope(
      onWillPop: () async {
        // Close the current screen when back is pressed
        Navigator.pop(context);
        return Future.value(false); // Prevent default behavior
      },
      child: Scaffold(
        backgroundColor: secondaryColor,
        appBar: isDesktop
            ? null
            : AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: Colors.white, size: iconSize),
                  onPressed: () {
                    // Navigate to Adminscreen when back button is pressed
                    context
                        .read<MenuAppController>()
                        .changeScreen(const DashboardScreen());
                  },
                ),
                title: Text(
                  'Add New',
                  style:
                      TextStyle(color: Colors.white, fontSize: headerFontSize),
                ),
                backgroundColor: secondaryColor,
                iconTheme: IconThemeData(color: Colors.white, size: iconSize),
              ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            bool isLargeScreen = constraints.maxWidth > 600;
            double horizontalMargin = isLargeScreen ? 100.0 : 16.0;

            return Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalMargin, vertical: 16.0),
              child: isLargeScreen
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left side: FoodList
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const FoodList(), // Use FoodList here
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Right side: Form Fields
                        Expanded(
                          flex: 3,
                          child: _buildFormFields(),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      // Enable scrolling for small screens
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormFields(), // Form Fields first
                          const SizedBox(height: 16),
                          // Food List below on mobile screens
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const SizedBox(
                              height:
                                  400, // Fixed height for the FoodList in mobile
                              child: FoodList(), // Food List below form fields
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(color: Colors.white),
              fillColor: fillColor,
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select category',
                    labelStyle: TextStyle(color: Colors.white),
                    fillColor: fillColor,
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  dropdownColor: bgColor,
                  items: const [
                    DropdownMenuItem(
                      value: 'Burger',
                      child: Text(
                        'Burger',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Juice',
                      child: Text(
                        'Juice',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Pizza',
                      child: Text(
                        'Pizza',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Short Order',
                      child: Text(
                        'Short Order',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Pasta',
                      child: Text(
                        'Pasta',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Value Meal',
                      child: Text(
                        'Value Meal',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Pica-pica',
                      child: Text(
                        'Pica-pica',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Shake',
                      child: Text(
                        'Shake',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Boodle Fight',
                      child: Text(
                        'Boodle Fight',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _priceController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(color: Colors.white),
                    fillColor: fillColor,
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _quantityController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Quantity',
              labelStyle: TextStyle(color: Colors.white),
              fillColor: fillColor,
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Description',
              labelStyle: TextStyle(color: Colors.white),
              fillColor: fillColor,
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickImage,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DottedBorder(
                color: Colors.blue,
                strokeWidth: 1,
                dashPattern: const [6, 3],
                borderType: BorderType.RRect,
                radius: const Radius.circular(10),
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _imageData != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            _imageData!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              color: Colors.blue,
                              size: 50,
                            ),
                            SizedBox(height: 10),
                            Text.rich(
                              TextSpan(
                                text: 'Drop your image here, or ',
                                style: TextStyle(color: Colors.white),
                                children: [
                                  TextSpan(
                                    text: 'browse',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Supports: JPG, JPEG2000, PNG',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
          if (_imageData != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _clearImage,
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  'Remove Image',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              'Submit',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedCategory == null ||
        _imageData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }

    try {
      // Upload image to Firebase Storage
      String imageUrl = await _uploadImageToStorage();

      // Saving data to Firestore
      await FirebaseFirestore.instance.collection('Menu').add({
        'name': _nameController.text,
        'category': _selectedCategory,
        'price': double.parse(_priceController.text),
        'quantity': int.parse(_quantityController.text),
        'description': _descriptionController.text,
        'image_url': imageUrl, // Storing image URL
        'created_at': Timestamp.now(),
      });

      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Menu item added successfully!'),
          duration: Duration(milliseconds: 800), // Custom duration
          backgroundColor: Colors.green, // Custom background color
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<String> _uploadImageToStorage() async {
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child('menu_images/${DateTime.now()}.png');
    final uploadTask = await imageRef.putData(_imageData!);
    return await uploadTask.ref.getDownloadURL();
  }

  void _clearForm() {
    _nameController.clear();
    _priceController.clear();
    _quantityController.clear();
    _descriptionController.clear();
    _selectedCategory = null;
    _clearImage();
  }

  void _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _imageData = result.files.first.bytes;
      });
    }
  }

  void _clearImage() {
    setState(() {
      _imageData = null;
    });
  }
}
