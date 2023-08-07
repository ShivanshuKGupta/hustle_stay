import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustle_stay/models/requests/request.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/providers/settings.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/other/scroll_builder.dart';
import 'package:hustle_stay/widgets/requests/post_request_options.dart';

class RequestsList extends ConsumerStatefulWidget {
  final List<Request> requests;
  final bool showPostRequestOptions;
  const RequestsList({
    super.key,
    this.requests = const [],
    this.showPostRequestOptions = true,
  });

  @override
  ConsumerState<RequestsList> createState() => _RequestsListState();
}

class _RequestsListState extends ConsumerState<RequestsList> {
  Map<String, DocumentSnapshot> savePoint = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final settings = ref.watch(settingsProvider);
    final settingsClass = ref.read(settingsProvider.notifier);
    savePoint.clear();
    return RefreshIndicator(
      onRefresh: () async {
        try {
          await initializeRequests();
          setState(() {
            savePoint.clear();
          });
        } catch (e) {
          showMsg(context, e.toString());
        }
        setState(() {});
      },
      child: ScrollBuilder(
        key: UniqueKey(),
        header: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentUser.permissions.requests.create == true &&
                widget.showPostRequestOptions)
              const PostRequestOptions(),
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 10),
              child: DropdownButton(
                iconSize: 0,
                elevation: 2,
                isDense: true,
                selectedItemBuilder: (context) {
                  return [
                    shaderText(context,
                        title: "All Requests",
                        style: theme.textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold)),
                    shaderText(context,
                        title: "Pending Requests",
                        style: theme.textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold)),
                    shaderText(context,
                        title: "Approved Requests",
                        style: theme.textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold)),
                    shaderText(context,
                        title: "Denied Requests",
                        style: theme.textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold)),
                  ];
                },
                hint: const Text('View Only'),
                underline: Container(),
                borderRadius: BorderRadius.circular(20),
                value: settings.requestViewStatus,
                items: const [
                  DropdownMenuItem(
                    value: null,
                    child: Text('All Requests'),
                  ),
                  DropdownMenuItem(
                    value: RequestStatus.pending,
                    child: Text('Pending Requests'),
                  ),
                  DropdownMenuItem(
                    value: RequestStatus.approved,
                    child: Text('Approved Requests'),
                  ),
                  DropdownMenuItem(
                    value: RequestStatus.denied,
                    child: Text('Denied Requests'),
                  ),
                ],
                onChanged: (value) {
                  settings.requestViewStatus = value;
                  settingsClass.notifyListeners();
                },
              ),
            ),
          ],
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        loader: (ctx, start, interval) async {
          final List<Request> requests = await fetchRequests(
            limit: interval,
            savePoint: savePoint,
            status: settings.requestViewStatus,
          );
          return requests.map(
            (request) {
              return request.widget(context);
            },
          );
        },
      ),
      // child: ListView(
      //   children: [
      //     if (currentUser.permissions.requests.create == true &&
      //         widget.showPostRequestOptions)
      //       const PostRequestOptions(),
      //     CacheBuilder(
      //       loadingWidget: Center(
      //         child: Padding(
      //           padding: const EdgeInsets.all(40.0),
      //           child: circularProgressIndicator(),
      //         ),
      //       ),
      //       builder: (ctx, data) {
      //         data.sort(
      //           (a, b) {
      //             return a.id < b.id ? 1 : 0;
      //           },
      //         );
      //         final children = data.map((e) => e.widget(context)).toList();
      //         if (children.isEmpty && currentUser.type != 'student') {
      //           return SizedBox(
      //             height: mediaQuery.size.height -
      //                 mediaQuery.viewInsets.top -
      //                 mediaQuery.padding.top -
      //                 mediaQuery.padding.bottom -
      //                 mediaQuery.viewInsets.bottom -
      //                 150,
      //             child: Center(
      //               child: Column(
      //                 mainAxisSize: MainAxisSize.min,
      //                 children: [
      //                   AnimateIcon(
      //                     color: Theme.of(context).colorScheme.primary,
      //                     onTap: () {},
      //                     iconType: IconType.continueAnimation,
      //                     animateIcon: AnimateIcons.cool,
      //                   ),
      //                   Text(
      //                     'No requests are pending',
      //                     style: theme.textTheme.titleLarge,
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           );
      //         }
      //         if (children.isNotEmpty) {
      //           children.insert(
      //             0,
      //             Padding(
      //               padding: const EdgeInsets.only(left: 20, top: 10),
      //               child: DropdownButton(
      //                 iconSize: 0,
      //                 elevation: 2,
      //                 enableFeedback: true,
      //                 isDense: false,
      //                 selectedItemBuilder: (context) {
      //                   return [
      //                     shaderText(context,
      //                         title: "All Requests",
      //                         style: theme.textTheme.titleLarge!
      //                             .copyWith(fontWeight: FontWeight.bold)),
      //                     shaderText(context,
      //                         title: "Pending Requests",
      //                         style: theme.textTheme.titleLarge!
      //                             .copyWith(fontWeight: FontWeight.bold)),
      //                     shaderText(context,
      //                         title: "Approved Requests",
      //                         style: theme.textTheme.titleLarge!
      //                             .copyWith(fontWeight: FontWeight.bold)),
      //                     shaderText(context,
      //                         title: "Denied Requests",
      //                         style: theme.textTheme.titleLarge!
      //                             .copyWith(fontWeight: FontWeight.bold)),
      //                   ];
      //                 },
      //                 hint: const Text('View Only'),
      //                 borderRadius: BorderRadius.circular(20),
      //                 underline: Container(),
      //                 // style: theme.textTheme.titleLarge!
      //                 //     .copyWith(fontWeight: FontWeight.bold),
      //                 value: settings.requestViewStatus,
      //                 items: const [
      //                   DropdownMenuItem(
      //                     value: null,
      //                     child: Text('All Requests'),
      //                   ),
      //                   DropdownMenuItem(
      //                     value: RequestStatus.pending,
      //                     child: Text('Pending Requests'),
      //                   ),
      //                   DropdownMenuItem(
      //                     value: RequestStatus.approved,
      //                     child: Text('Approved Requests'),
      //                   ),
      //                   DropdownMenuItem(
      //                     value: RequestStatus.denied,
      //                     child: Text('Denied Requests'),
      //                   ),
      //                 ],
      //                 onChanged: (value) {
      //                   settings.requestViewStatus = value;
      //                   settingsClass.notifyListeners();
      //                 },
      //               ),
      //             ),
      //           );
      //         }
      //         return ListView.separated(
      //           separatorBuilder: (ctx, index) {
      //             return const SizedBox(
      //               height: 10,
      //             );
      //           },
      //           shrinkWrap: true,
      //           physics: const ClampingScrollPhysics(),
      //           itemCount: children.length,
      //           itemBuilder: (ctx, index) {
      //             return children[index];
      //           },
      //         );
      //       },
      //       provider: widget.requests.isEmpty
      //           ? ({src}) => fetchRequests(status: settings.requestViewStatus)
      //           : ({src}) async => widget.requests,
      //     ),
      //     const SizedBox(height: 35),
      //   ],
      // ),
    );
  }
}
