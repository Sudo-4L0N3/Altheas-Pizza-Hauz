import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class BannerSection extends StatelessWidget {
  const BannerSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          flex: 3,
          child: AboutSection(),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Image.asset(
                "assets/images/logo.png",
                height: 400,
                width: 400,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class MobBanner extends StatefulWidget {
  const MobBanner({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MobBannerState createState() => _MobBannerState();
}

class _MobBannerState extends State<MobBanner> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            Image.asset(
              "assets/images/logo.png",
              height: 200,
              width: 200,
            ),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        const AboutSection(),
      ],
    );
  }
}

class AboutSection extends StatelessWidget {
  const AboutSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      // ignore: prefer_const_literals_to_create_immutables
      children: [
        // ignore: prefer_const_constructors
        //it will adjust its size according to screeen
        AutoSizeText(
          "Eat today",
          maxLines: 1,
          style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 10,
        ),
        AutoSizeText(
          "Live another day",
          maxLines: 1,
          style: TextStyle(
            fontSize: 56,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "Tikman ang pinakamasarap na pizza sa Althea's Pizza Hauz! Masarap, abot-kaya, at laging sariwa ang aming mga sangkap. Mag-order na ngayon at maranasan ang tunay na sarap!",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        // Container(
        //   padding: const EdgeInsets.only(left: 10, right: 10),
        //   height: 50,
        //   decoration: BoxDecoration(
        //     color: Colors.white, // This sets the container's background color
        //     border: Border.all(color: Colors.transparent),
        //   ),
        //   child: TextFormField(
        //     decoration: const InputDecoration(
        //         fillColor: Colors.white, // This sets the fill color to white
        //         filled: true, // This ensures the fill color is applied
        //         suffixIcon: Icon(
        //           Icons.adjust_rounded,
        //           color: kPrimaryColor,
        //         ),
        //         hintText: "Search your favourite food",
        //         focusedBorder:
        //             UnderlineInputBorder(borderSide: BorderSide.none),
        //         enabledBorder:
        //             UnderlineInputBorder(borderSide: BorderSide.none)),
        //   ),
        // ),
        SizedBox(
          height: 20,
        ),
        // Row(
        //   children: [
        //     Expanded(
        //       child: MaterialButton(
        //         height: 55,
        //         color: kPrimaryColor,
        //         onPressed: () {},
        //         child: const Text(
        //           "Delivery",
        //           style: TextStyle(
        //               color: Colors.white,
        //               fontSize: 16,
        //               fontWeight: FontWeight.w600),
        //         ),
        //       ),
        //     ),
        //     const Padding(
        //       padding: EdgeInsets.symmetric(horizontal: 20),
        //       child: Text(
        //         "or",
        //         style: TextStyle(
        //             color: kPrimaryColor,
        //             fontSize: 16,
        //             fontWeight: FontWeight.w600),
        //       ),
        //     ),
        //     Expanded(
        //       child: SizedBox(
        //         height: 50,
        //         child: OutlinedButton(
        //           onPressed: () {},
        //           style: OutlinedButton.styleFrom(
        //               side: const BorderSide(color: kPrimaryColor)),
        //           child: const Text(
        //             "Pick Up",
        //             style: TextStyle(
        //                 color: kPrimaryColor,
        //                 fontSize: 16,
        //                 fontWeight: FontWeight.w600),
        //           ),
        //         ),
        //       ),
        //     )
        //   ],
        // )
      ],
    );
  }
}
