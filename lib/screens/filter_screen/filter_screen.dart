import 'package:flutter/material.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Complaints'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Card(
          child: Wrap(
            children: [
              InkWell(
                onTap: () {
                  // TODO: show a dialog to add a new criteria
                },
                child: const Icon(
                  Icons.add_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
