import 'package:flutter/material.dart';

// CustomButton Widget for reusability and consistent styling
class CustomButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;
  final double fontSize;
  final double paddingVertical;
  final double borderRadius;
  final double elevation;
  final BorderSide? borderSide;
  final Widget? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    this.fontSize = 16,
    this.paddingVertical = 16.0,
    this.borderRadius = 8.0,
    this.elevation = 4.0,
    this.borderSide,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: EdgeInsets.symmetric(vertical: paddingVertical),
        textStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: borderSide ?? BorderSide.none,
        ),
        elevation: elevation,
      ),
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon!,
                const SizedBox(width: 8),
                Text(text.toUpperCase()),
              ],
            )
          : Text(text.toUpperCase()),
    );
  }
}
