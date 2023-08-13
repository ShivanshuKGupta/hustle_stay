import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/models/requests/request.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/screens/chat/chat_screen.dart';
import 'package:hustle_stay/screens/chat/image_preview.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/other/scroll_builder.dart';

// ignore: must_be_immutable
class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  Map<String, DocumentSnapshot> savePoint = {};

  @override
  Widget build(BuildContext context) {
    savePoint.clear();
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: shaderText(
          context,
          title: 'Vehicle',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: vehicleRequestsIntialized,
            builder: (context, value, child) {
              return IconButton(
                icon: value == null
                    ? const Icon(Icons.refresh_rounded)
                    : circularProgressIndicator(),
                onPressed: () async {
                  await initializeVehicleRequests();
                  setState(() {
                    savePoint.clear();
                  });
                },
              );
            },
          ),
        ],
      ),
      body: ScrollBuilder(
        automaticLoading: true,
        loadingWidget: ValueListenableBuilder(
          valueListenable: vehicleRequestsIntialized,
          builder: (context, value, child) {
            if (value == null) return child!;
            return circularProgressIndicator();
          },
          child: Container(),
        ),
        key: UniqueKey(),
        reverse: true,
        loader: (ctx, start, limit) async {
          final requests = await fetchVehicleRequests(
            limit: limit,
            savePoint: savePoint,
          );
          final requestTiles = requests.map(
            (request) => Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              child: ListTile(
                onTap: () async {
                  await navigatorPush(
                    context,
                    ChatScreen(
                      chat: request.chatData,
                      showInfo: () => request.showInfo(context, {}),
                    ),
                  );
                },
                onLongPress: () => request.showInfo(
                  context,
                  {
                    '-': '-',
                    'Date': ddmmyyyy(request.dateTime!),
                    'Time': timeFrom(request.dateTime!),
                  },
                ),
                leading: FittedBox(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        request.dateTime!.day.toString(),
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            // fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        getMonth(request.dateTime!.month),
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              fontSize: 8,
                              // fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                title: Text(request.reason),
                subtitle: UserBuilder(
                  builder: (ctx, userData) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: userData.imgUrl == null
                            ? null
                            : () {
                                navigatorPush(
                                  context,
                                  ImagePreview(
                                    image: Hero(
                                      tag: request.id,
                                      child: CachedNetworkImage(
                                        imageUrl: userData.imgUrl!,
                                      ),
                                    ),
                                  ),
                                );
                              },
                        child: Hero(
                          tag: request.id,
                          child: CircleAvatar(
                            backgroundImage: userData.imgUrl == null
                                ? null
                                : CachedNetworkImageProvider(userData.imgUrl!),
                            radius: 10,
                            child: userData.imgUrl != null
                                ? null
                                : const Icon(
                                    Icons.person_rounded,
                                    size: 10,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        userData.name ?? userData.email!,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                  email: request.requestingUserEmail,
                ),
                trailing: Text(
                  timeFrom(request.dateTime!),
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          );
          List<Widget> widgets = [];
          widgets.addAll(requestTiles);
          final now = DateTime.now();
          bool indicator = false;
          Widget todayIndicator = Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    '${ddmmyyyy(now)} ${timeFrom(now)}',
                    // ignore: use_build_context_synchronously
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          // ignore: use_build_context_synchronously
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
                const Divider(height: 1),
              ],
            ),
          );
          if (requests.isNotEmpty &&
              requests.last.dateTime!.compareTo(now) > 0) {
            widgets.add(todayIndicator);
          } else {
            for (int i = widgets.length; i-- > 0;) {
              if (i - 1 >= 0 &&
                  requests[i - 1].dateTime!.compareTo(now) > 0 &&
                  !indicator) {
                widgets.insert(i, todayIndicator);
                indicator = true;
              }
            }
          }
          return widgets;
        },
      ),
    );
  }
}
