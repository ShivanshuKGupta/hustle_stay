import 'package:flutter/material.dart';
import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/widgets/complaints/complaint_list_item.dart';
import 'package:hustle_stay/widgets/scroll_builder.dart/scroll_builder.dart';

class ResolvedComplaintsScreen extends StatelessWidget {
  final ScrollController? scrollController;
  const ResolvedComplaintsScreen({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resolved Complaints'),
      ),
      body: ScrollBuilder(
        scrollController: scrollController,
        interval: 20,
        loader: (context, start, interval) async {
          final complaints = await fetchComplaints(
            resolved: true,
            startID: start,
            limit: interval,
          );
          return complaints.map(
            (complaint) => ComplaintListItem(
              complaint: complaint,
            ),
          );
        },
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(title: const Text('Resolved Complaints')),
    //   body: CacheBuilder(
    //     src: Source.cache,
    //     provider: ({src}) => fetchComplaints(resolved: true, src: src),
    //     builder: (ctx, complaints) {
    //       return complaints.isEmpty
    //           ? Center(
    //               child: Text(
    //                 'All clear✨',
    //                 style: Theme.of(context).textTheme.titleLarge,
    //                 textAlign: TextAlign.center,
    //               ),
    //             )
    //           : ListView.builder(
    //               controller: scrollController,
    //               itemBuilder: (ctx, index) {
    //                 final complaint = complaints[index];
    //                 return ComplaintListItem(
    //                   complaint: complaint,
    //                 );
    //               },
    //               itemCount: complaints.length,
    //             );
    //     },
    //   ),
    // );
  }
}
