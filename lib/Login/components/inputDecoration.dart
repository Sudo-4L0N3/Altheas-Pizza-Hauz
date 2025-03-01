// components/input_decoration.dart

import 'package:flutter/material.dart';
import '../constants.dart';

InputDecoration customInputDecoration({
  required String hintText,
  required IconData prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(fontSize: 12),
    prefixIcon: Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Icon(prefixIcon),
    ),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.grey[200], // Adjust based on your theme
    contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadius),
      borderSide: BorderSide.none, // Remove the border
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadius),
      borderSide: BorderSide.none, // Remove the border
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadius),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadius),
      borderSide: const BorderSide(color: Colors.red),
    ),
  );
}
