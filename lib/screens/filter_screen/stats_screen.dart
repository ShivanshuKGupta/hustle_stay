import 'package:animated_icon/animated_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/screens/filter_screen/filter_choser_screen.dart';

// ignore: must_be_immutable
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late Map<String, dynamic> filters;

  @override
  void initState() {
    super.initState();
    // TODO: read any saved filter and assign it to filters
    filters = {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                useSafeArea: true,
                builder: (ctx) => FilterChooserScreen(filters: filters),
              );
            },
            icon: const Icon(Icons.filter_alt_rounded),
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                enableDrag: true,
                builder: (ctx) => const Text('Select sorting criteria here'),
              );
            },
            icon: const Icon(Icons.swap_vert_rounded),
          ),
        ],
      ),
      body: ComplaintsBuilder(
        src: Source.cache,
        loadingWidget: AnimateIcon(
          onTap: () {},
          iconType: IconType.continueAnimation,
          animateIcon: AnimateIcons.loading5,
        ),
        builder: ((ctx, complaints) {
          return const Text('The statistics show up here');
        }),
      ),
    );
  }
}
