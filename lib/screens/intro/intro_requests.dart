import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/tools.dart';

class IntroRequests extends StatelessWidget {
  const IntroRequests({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimateIcon(
            animateIcon: AnimateIcons.confused,
            iconType: IconType.continueAnimation,
            onTap: () {},
          ),
          const SizedBox(
            height: 50,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              shaderText(
                context,
                title: "Your Requests",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "\u2022 Say goodbye to emails and streamline your requests with Hustle Stay.\n\u2022 Need to borrow a van for night travel?\n      - Submit a van request\n\u2022 Craving a specific dish for dinner?\n      - Simply place a mess request\n\u2022 And all of that with a few taps.",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
