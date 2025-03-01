import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../customerConstant.dart';

// ignore: must_be_immutable
class Footer extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  var kSecondaryColor;

  Footer({
    super.key,
  });

  // Facebook URL
  final String facebookUrl =
      "https://www.facebook.com/profile.php?id=100088140990088&sk";

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: kPrimaryColor,
      child: Container(
        padding: const EdgeInsets.all(kPadding),
        constraints: const BoxConstraints(maxWidth: kMaxWidth),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        "Althea's Pizza Hauz",
                        style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w900,
                            color: kSecondaryColor),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const MouseRegion(
                            cursor: SystemMouseCursors
                                .click, // Change cursor to clickable
                            child: SocialIcon(
                              icon: "assets/icons/google-icon.svg",
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          // Make Facebook icon clickable and change cursor
                          GestureDetector(
                            onTap: () async {
                              if (await canLaunch(facebookUrl)) {
                                await launch(facebookUrl);
                              } else {
                                throw 'Could not launch $facebookUrl';
                              }
                            },
                            child: const MouseRegion(
                              cursor: SystemMouseCursors
                                  .click, // Change cursor to clickable
                              child: SocialIcon(
                                icon: "assets/icons/facebook-2.svg",
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "Branch 2: Doroluman Arakan North Cotabato, Kidapawan, Philippines, 9400",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SocialIcon extends StatelessWidget {
  const SocialIcon({
    super.key,
    required this.icon,
  });

  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      width: 35,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
        ),
      ),
      child: SvgPicture.asset(icon),
    );
  }
}
