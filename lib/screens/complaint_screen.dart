import 'package:flutter/material.dart';
import 'package:hustle_stay/models/complaint.dart';
import 'package:hustle_stay/models/hostel.dart';
import 'package:hustle_stay/tools/tools.dart';

import '../models/user.dart';
import '../widgets/add_new_complaint.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  bool _isLoading = true;
  List<Hostel> fetchedHostels = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await fetchAllHostels();
        await fetchAllComplaints();
      } catch (e) {
        showMsg(context, e.toString());
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  _removeComplaint(Complaint complaint) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await removeComplaint(complaint);
      showMsg(context, 'Complaint resolved!');
      await fetchAllComplaints();
    } catch (e) {
      showMsg(context, e.toString());
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.of(context).viewPadding;
    List<Complaint> myComplaints = allComplaints
        .where((comp) => comp.posterID == currentUser.rollNo)
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaints'),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(14))),
                  context: context,
                  builder: (bCtx) {
                    return NewComplaint();
                  });
            },
            icon: Icon(Icons.add_rounded),
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 30,
                  ),
                  Text('Fetching Complaints'),
                ],
              ),
            )
          : myComplaints.isEmpty
              ? Center(
                  child: Text(
                    'No Complaints 😁',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                )
              : ListView.builder(
                  itemCount: myComplaints.length,
                  itemBuilder: (ctx, index) {
                    Complaint complaint = myComplaints[index];
                    return Dismissible(
                      key: Key(complaint.id!),
                      onDismissed: (_) => _removeComplaint(complaint),
                      child: ListTile(
                          title: Text(complaint.heading,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(color: Colors.white)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                complaint.body,
                                textAlign: TextAlign.left,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(color: Colors.white),
                              ),
                              Text(
                                'by ${complaint.posterID}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(color: Colors.white),
                              ),
                            ],
                          )),
                    );
                  },
                ),
    );
  }
}
