import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/tools.dart';

class IntroComplaints extends StatelessWidget {
  const IntroComplaints({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimateIcon(
            color: Theme.of(context).colorScheme.primary,
            animateIcon: AnimateIcons.chatMessage,
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
                title: "Your Complaints",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "\u2022 Experience hassle-free complaint management with Hustle Stay.\n\u2022 Report any issues.\n\u2022 Stay updated on their status.\n\u2022 And enjoy a seamless resolution process to ensure a comfortable living environment.",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
