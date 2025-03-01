import 'package:flutter/material.dart';

import '../../../constants.dart';

class SignUpScreenTopImage extends StatelessWidget {
  const SignUpScreenTopImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 800;
    bool isMobile = screenWidth <= 600;

    // Adjust image size based on screen size
    double imageSize = isDesktop ? 400 : (isMobile ? 150 : 200);
    // Adjust font size based on screen size
    double fontSize = isDesktop ? 40 : (isMobile ? 23 : 30);

    return Column(
      children: [
        Text(
          "PLEASE SIGN UP".toUpperCase(),
          style: TextStyle(fontSize: fontSize), // Font size adjusted
        ),
        const SizedBox(height: defaultPadding),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: Image.asset(
                "assets/images/foods.png",
                width: imageSize, // Image width adjusted
                height: imageSize, // Image height adjusted
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: defaultPadding),
      ],
    );
  }
}
