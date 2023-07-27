import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/tools.dart';

class IntroAttendance extends StatelessWidget {
  const IntroAttendance({super.key});

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
            animateIcon: AnimateIcons.calendarTear,
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
                title: "Your Hostel Attendance",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "\u2022 Never miss a beat with our smart attendance tracker\n\u2022 Track your campus presence\n\u2022 Calculate your mess refund\n\u2022 Request leaves conveniently\n\u2022 And report your arrivals in a snap",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
