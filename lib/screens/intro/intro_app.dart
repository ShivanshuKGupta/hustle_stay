import 'package:flutter/material.dart';

class IntroApp extends StatelessWidget {
  const IntroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/transparent.png',
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Welcome to the ultimate solution for hassle-free hostel living!\nIntroducing the Hustle Stay, your one-stop destination to effortlessly manage your hostel experience.\nSay goodbye to endless paperwork and long queues, as we bring you a range of convenient features right at your fingertips.\nFrom tracking your attendance to lodging complaints and making requests, we've got you covered.\nLet's dive into the exciting features awaiting you!",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
