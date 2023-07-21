import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hustle_stay/screens/hostel/rooms/rooms_screen.dart';

import '../../models/common/operation.dart';
import '../../models/hostel/hostels.dart';
import '../../tools.dart';
import 'rooms/add_rooms.dart';
// import 'package:hustle_stay/models/user.dart';

class HostelScreen extends StatefulWidget {
  const HostelScreen({super.key});

  @override
  State<HostelScreen> createState() => _HostelScreenState();
}

class _HostelScreenState extends State<HostelScreen> {
  List<Operations> setCatList(List<Hostels> list) {
    List<Operations> catList = [];
    for (final x in list) {
      if (x.imageUrl == null) {
        catList.add(Operations(
            operationName: '${x.hostelName} Hostel',
            cardColor: Colors.cyan,
            hostel: x,
            icon: const Icon(Icons.panorama_horizontal_select)));
      } else {
        catList.add(Operations(
            operationName: '${x.hostelName} Hostel',
            imgUrl: x.imageUrl,
            cardColor: Colors.cyan,
            hostel: x));
      }
    }
    return catList;
  }

  final store = FirebaseFirestore.instance;
  bool isRunning = false;
  ValueNotifier<bool> gridView = ValueNotifier(true);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: shaderText(context, title: "Select Hostel"),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  gridView.value = !gridView.value;
                });
              },
              icon: gridView.value
                  ? const Icon(Icons.list)
                  : const Icon(Icons.grid_view))
        ],
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: fetchHostels(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: circularProgressIndicator(
                  height: null,
                  width: null,
                ),
              );
            }

            return HostelList(snapshot.data!);
          },
        ),
      ),
    );
  }

  Widget HostelList(List<Hostels> hostelList) {
    final Brightness brightness = Theme.of(context).brightness;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double gridWidth = (screenWidth) / 2;

    return ValueListenableBuilder(
      valueListenable: gridView,
      builder: (context, value, child) {
        List<Operations> catList = [];
        if (value) {
          catList = setCatList(hostelList);
        }
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: value
              ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final Color cardColor = catList[index].cardColor;
                    LinearGradient? gradient;
                    gradient = LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: brightness == Brightness.light
                          ? [
                              cardColor.withOpacity(0.2),
                              Colors.white,
                            ]
                          : [
                              cardColor.withOpacity(0.7),
                              Colors.black,
                            ],
                    );

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(2, 2, 8, 8),
                      child: GestureDetector(
                          onTap: () {
                            if (catList[index].hostel != null) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => RoomsScreen(
                                      hostelName:
                                          catList[index].hostel!.hostelName)));
                            }
                          },
                          child: Container(
                            width: gridWidth,
                            padding: EdgeInsets.all(
                                catList[index].imgUrl != null ? 4 : 1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              gradient: brightness == Brightness.light
                                  ? null
                                  : gradient,
                              color: brightness == Brightness.light
                                  ? cardColor.withOpacity(0.2)
                                  : null,
                              boxShadow: catList[index].imgUrl != null ||
                                      brightness == Brightness.light
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Column(
                              mainAxisAlignment: catList[index].imgUrl == null
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.end,
                              children: [
                                if (catList[index].imgUrl == null)
                                  Expanded(
                                    child: Icon(
                                      catList[index].icon!.icon,
                                      size: screenWidth * 0.3,
                                    ),
                                  ),
                                if (catList[index].imgUrl != null)
                                  Expanded(
                                      child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: CachedNetworkImage(
                                      imageUrl: catList[index].imgUrl!,
                                      fit: BoxFit.cover,
                                      width: gridWidth - 8,
                                    ),
                                  )),
                                Divider(
                                  color: brightness == Brightness.light
                                      ? Colors.black
                                      : Colors.white,
                                ),
                                Text(
                                  catList[index].operationName,
                                  overflow: TextOverflow.clip,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: brightness == Brightness.light
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                ),
                                Divider(
                                  color: brightness == Brightness.light
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ],
                            ),
                          )),
                    );
                  },
                  itemCount: catList.length,
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      Hostels hostel = hostelList[index];
                      String? imageUrl = hostel.imageUrl;
                      return InkWell(
                        onTap: () => {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => RoomsScreen(
                                    hostelName: hostel.hostelName,
                                  )))
                        },
                        child: Card(
                          elevation: 6,
                          child: Column(
                            children: [
                              CachedNetworkImage(
                                imageUrl: imageUrl,
                                placeholder: (context, url) =>
                                    Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            hostel.hostelName,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            "${hostel.hostelType} Hostel",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            "${hostel.numberOfRooms}",
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton.icon(
                                        onPressed: () => Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (_) => AddRoom(
                                                    hostelName:
                                                        hostel.hostelName))),
                                        icon: Icon(Icons.add),
                                        label: Text("Add Room")),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: hostelList.length,
                  ),
                ),
        );
      },
    );
  }
}
