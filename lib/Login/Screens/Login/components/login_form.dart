import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Users/Admin/adminScreen.dart';
import '../../../../Users/Customers/customersScreen.dart';
import '../../../components/already_have_an_account_acheck.dart';
import '../../../components/inputDecoration.dart'; // Import the customInputDecoration
import '../../../constants.dart';
import '../../Forgot Password/forgot_password_screen.dart';
import '../../Signup/signup_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // Form key and controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // State variables
  bool _isLoading = false;
  bool _passwordVisible = false;

  // Lockout variables
  int _attemptCounter = 0;
  final int _maxAttempts = 3;
  DateTime? _lockoutEndTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadLockoutData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Load lockout data from SharedPreferences
  Future<void> _loadLockoutData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lockoutEndTimeStr = prefs.getString('lockoutEndTime');
    int? attemptCounter = prefs.getInt('attemptCounter');

    DateTime lockoutEndTime = DateTime.parse(lockoutEndTimeStr!);
    if (DateTime.now().isBefore(lockoutEndTime)) {
      setState(() {
        _lockoutEndTime = lockoutEndTime;
        _attemptCounter = attemptCounter ?? 0;
      });
      _startLockoutTimer();
      _showLockoutDialog();
    } else {
      _clearLockoutData();
    }
    }

  // Save lockout data to SharedPreferences
  Future<void> _saveLockoutData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_lockoutEndTime != null) {
      await prefs.setString('lockoutEndTime', _lockoutEndTime!.toIso8601String());
    }
    await prefs.setInt('attemptCounter', _attemptCounter);
  }

  // Clear lockout data from SharedPreferences
  Future<void> _clearLockoutData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('lockoutEndTime');
    await prefs.remove('attemptCounter');
    setState(() {
      _lockoutEndTime = null;
      _attemptCounter = 0;
    });
  }

  // Start the lockout timer
  void _startLockoutTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
        if (_lockoutEndTime == null || DateTime.now().isAfter(_lockoutEndTime!)) {
          timer.cancel();
          _clearLockoutData();
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop(); // Close the dialog when lockout ends
          }
        }
      }
    });
  }

  // Show the lockout dialog
  void _showLockoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // Prevent dialog from closing
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Adjust dialog border radius if needed
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning GIF
                Center(
                  child: Image.asset(
                    'assets/images/warning.gif',
                    height: 60,
                    width: 60,
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                const Text(
                  "Too Many Attempts",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Message
                const Text(
                  "Please wait for the timer to expire before retrying.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Countdown Timer
                StreamBuilder<int>(
                  stream: Stream.periodic(const Duration(seconds: 1), (_) {
                    return _lockoutEndTime != null
                        ? _lockoutEndTime!.difference(DateTime.now()).inSeconds
                        : 0;
                  }),
                  builder: (context, snapshot) {
                    int secondsRemaining = snapshot.data ?? 0;
                    if (secondsRemaining <= 0) {
                      secondsRemaining = 0;
                    }
                    return Text(
                      "$secondsRemaining seconds remaining",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Handle user login
  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Check if user is currently locked out
      if (_lockoutEndTime != null && DateTime.now().isBefore(_lockoutEndTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Please wait until ${_lockoutEndTime!.hour.toString().padLeft(2, '0')}:${_lockoutEndTime!.minute.toString().padLeft(2, '0')}:${_lockoutEndTime!.second.toString().padLeft(2, '0')} to retry'),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Attempt to sign in
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        User? user = userCredential.user;
        if (user != null) {
          // Fetch user document from Firestore
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            String role = userDoc['role'];

            // Save the password in Firestore (Warning: Plain-text storage is not secure)
            await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
              'password': _passwordController.text, // It's highly recommended to use a hashed password
            });

            // Show success SnackBar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login successful!'),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate based on role
            if (role == 'Customer') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomersScreen(),
                ),
              );
            } else if (role == 'Admin') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Adminscreen(),
                ),
              );
            }

            // Clear any existing lockout data upon successful login
            _clearLockoutData();
          } else {
            // User document does not exist
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User role not found. Please contact support.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } on FirebaseAuthException {
        // Handle authentication errors
        _attemptCounter++;
        int attemptsLeft = _maxAttempts - _attemptCounter;

        if (_attemptCounter >= _maxAttempts) {
          // Trigger lockout
          _lockoutEndTime = DateTime.now().add(const Duration(minutes: 1));
          _attemptCounter = 0; // Reset counter after lockout
          await _saveLockoutData();
          _startLockoutTimer();
          _showLockoutDialog();

          // Show lockout SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Too many attempts. Please wait for 1 minute before retrying.'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          // Show attempts left SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Login failed. Please try again.\nYou have $attemptsLeft attempt(s) left.',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Handle other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed. Please try again. Error: $e'),
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

  @override
  Widget build(BuildContext context) {
    // Determine if user is locked out
    bool isLockedOut =
        _lockoutEndTime != null && DateTime.now().isBefore(_lockoutEndTime!);

    return Stack(
      children: [
        AbsorbPointer(
          absorbing: isLockedOut, // Prevent interaction when locked out
          child: Opacity(
            opacity: isLockedOut ? 0.6 : 1.0, // Dim the UI when locked out
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    cursorColor: kPrimaryColor,
                    decoration: customInputDecoration(
                      hintText: "Your email",
                      prefixIcon: Icons.person,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
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
                  const SizedBox(height: defaultPadding / 2),
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
                  const SizedBox(height: defaultPadding / 2),
                  // Forgot Password Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const ForgotPasswordScreen();
                            },
                          ),
                        );
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: kPrimaryColor, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLockedOut ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLockedOut
                            ? Colors.grey
                            : kPrimaryColor, // Change color if locked out
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        "Login".toUpperCase(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  // Already Have an Account Check
                  AlreadyHaveAnAccountCheck(
                    press: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const SignUpScreen();
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        // Loading Indicator
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
