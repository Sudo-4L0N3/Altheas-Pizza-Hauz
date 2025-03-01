import 'package:flutter/material.dart';

import '../../../constants.dart';

class LoginScreenTopImage extends StatelessWidget {
  const LoginScreenTopImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 800;
    bool isMobile = screenWidth <= 600;

    // Adjust image size based on screen size
    double imageSize = isDesktop ? 400 : (isMobile ? 150 : 350);
    // Adjust font size based on screen size
    double fontSize = isDesktop ? 40 : (isMobile ? 23 : 30);

    return Column(
      children: [
        const SizedBox(height: defaultPadding * 2),
        Text(
          "PLEASE LOGIN",
          style: TextStyle(fontSize: fontSize), // Font size adjusted
        ),
        const SizedBox(height: defaultPadding * 1),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: Image.asset(
                "assets/images/foodsv2.png",
                width: imageSize, // Image width adjusted
                height: imageSize, // Image height adjusted
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: defaultPadding * 2),
      ],
    );
  }
}
