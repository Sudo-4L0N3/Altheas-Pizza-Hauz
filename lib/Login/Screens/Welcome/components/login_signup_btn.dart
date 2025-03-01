import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../Login/login_screen.dart';
import '../../Signup/signup_screen.dart';

class LoginAndSignupBtn extends StatelessWidget {
  const LoginAndSignupBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Login Button
        SizedBox(
          width: double.infinity, // Make the button full-width
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor, // Primary color from constants
              foregroundColor: Colors.white, // Text color
              padding: const EdgeInsets.symmetric(vertical: 16.0), // Increased vertical padding
              textStyle: const TextStyle(
                fontSize: 16, // Increased font size for better readability
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
              ),
              elevation: 4, // Slight elevation for a raised effect
            ),
            child: const Text(
              "LOGIN",
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Sign Up Button
        SizedBox(
          width: double.infinity, // Make the button full-width
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignUpScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryLightColor, // Lighter primary color
              foregroundColor: Colors.black, // Text color
              padding: const EdgeInsets.symmetric(vertical: 16.0), // Increased vertical padding
              textStyle: const TextStyle(
                fontSize: 16, // Increased font size for better readability
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
              ),
              elevation: 0, // Flat button with no elevation
              side: const BorderSide(
                color: kPrimaryColor, // Border color matching primary color
                width: 2, // Border width
              ),
            ),
            child: const Text(
              "SIGN UP",
            ),
          ),
        ),
      ],
    );
  }
}
