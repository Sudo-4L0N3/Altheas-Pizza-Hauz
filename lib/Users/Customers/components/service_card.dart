import 'package:flutter/material.dart';
import '../customerConstant.dart';

class ServicesCard extends StatelessWidget {
  const ServicesCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Updated service descriptions with more detail
    return const Wrap(
      children: [
        Services(
          image: "assets/images/pick-ups.png",
          
          title: "Order Food Anytime & Anywhere",
          description: "Craving something tasty? Order from anywhere and pick up your meal at your convenience.",
        ),
        Services(
          image: "assets/images/menu.jpg",
          title: "So Much to Choose From",
          description: "A wide variety of dishes to satisfy any craving. There's something for everyone on our menu.",
        ),
        Services(
          image: "assets/images/offer.jpg",
          title: "Best Offer in Town",
          description: "Enjoy great deals with every order, making each meal affordable and satisfying.",
        ),
      ],
    );
  }
}

class Services extends StatelessWidget {
  const Services({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });
  
  final String image, title, description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kPadding),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: const EdgeInsets.all(kPadding / 2),
          // color: Colors.grey[100],
          width: 300,
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      image,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
