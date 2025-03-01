import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../components/customeButton.dart';
import '../../../components/inputDecoration.dart';
import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../Login/login_screen.dart';
import '../../../../Users/Customers/customersScreen.dart'; // Import Customer screen

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  // Form key and controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController(); // Username controller
  final TextEditingController _addressController = TextEditingController(); // Address controller

  bool _isLoading = false;
  bool _passwordVisible = false;

  // Dispose controllers to free resources
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullnameController.dispose();
    _usernameController.dispose();
    _addressController.dispose(); 
    super.dispose();
  }

  // Handle user sign up with email and password
  Future<void> _signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create user with Firebase Authentication
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        User? user = userCredential.user;

        // Save the fullname, username, address, password, and role to Firestore
        if (user != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'fullname': _fullnameController.text.trim(),
            'email': _emailController.text.trim(),
            'username': _usernameController.text.trim(), // Save username
            'address': _addressController.text.trim(), // Save address
            'password': _passwordController.text.trim(), // Save password
            'role': 'Customer',
          });

          // After successful signup, navigate to the appropriate screen (e.g., CustomerScreen)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CustomersScreen(),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        // Handle specific Firebase sign-up errors
        String errorMessage;
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'This email is already in use.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          case 'weak-password':
            errorMessage = 'The password is too weak.';
            break;
          default:
            errorMessage = 'An unexpected error occurred. Please try again.';
        }

        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up failed. $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        // Handle other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up failed. Please try again. Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Form for sign-up
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Fullname Field
          TextFormField(
            controller: _fullnameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            decoration: customInputDecoration(
              hintText: "Fullname",
              prefixIcon: Icons.person,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your fullname';
              }
              return null;
            },
          ),
          const SizedBox(height: defaultPadding),
          // Username Field
          TextFormField(
            controller: _usernameController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            decoration: customInputDecoration(
              hintText: "Username",
              prefixIcon: Icons.person_outline,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your username';
              }
              return null;
            },
          ),
          const SizedBox(height: defaultPadding),
          // Address Field
          TextFormField(
            controller: _addressController,
            keyboardType: TextInputType.streetAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            decoration: customInputDecoration(
              hintText: "Address",
              prefixIcon: Icons.home,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),
          const SizedBox(height: defaultPadding),
          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            decoration: customInputDecoration(
              hintText: "Your email",
              prefixIcon: Icons.email,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              // Basic email format validation
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                  .hasMatch(value.trim())) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: defaultPadding),
          // Password Field
          TextFormField(
            controller: _passwordController,
            textInputAction: TextInputAction.done,
            obscureText: !_passwordVisible,
            cursorColor: kPrimaryColor,
            decoration: customInputDecoration(
              hintText: "Your password",
              prefixIcon: Icons.lock,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 20,
                    width: 1,
                    color: Colors.grey,
                  ),
                  IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ],
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              // Optional: Add more password validation if needed
              return null;
            },
          ),
          const SizedBox(height: defaultPadding),
          // Sign Up Button.
          _isLoading
              ? const CircularProgressIndicator()
              : CustomButton(
                  text: "Sign Up",
                  backgroundColor: kPrimaryColor,
                  textColor: Colors.white, //  Text Color
                  onPressed: _signUp,
                ),
          const SizedBox(height: defaultPadding),
          // Already Have an Account Check
          AlreadyHaveAnAccountCheck(
            login: false,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}