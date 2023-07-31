import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/attendance.dart';

import '../../../models/user/user.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Leaves"),
      ),
      body: FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimateIcon(
                      onTap: () {},
                      iconType: IconType.continueAnimation,
                      animateIcon: AnimateIcons.loading1,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const Text('Loading...')
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.error != null) {
            return Center(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimateIcon(
                      onTap: () {},
                      iconType: IconType.continueAnimation,
                      animateIcon: AnimateIcons.error,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const Text('No data available')
                  ],
                ),
              ),
            );
          }
          return leavesWid(snapshot.data!);
        },
        future: fetchLeaves(
            currentUser.readonly.hostelName!, currentUser.email!,
            getAll: true),
      ),
    );
  }

  Widget leavesWid(List<LeaveData> data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        Color cardColor = Colors.cyan;
        if (data[index].leaveType == 'Internship') {
          cardColor = Colors.orange;
        }
        return Card(
          color: cardColor.withOpacity(0.1),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leave Reason: ${data[index].leaveType}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Start Date: ${data[index].startDate}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: 8),
                Text(
                  'End Date: ${data[index].endDate}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
