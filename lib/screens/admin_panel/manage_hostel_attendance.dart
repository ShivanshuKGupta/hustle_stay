import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/screens/admin_panel/manage_hostel.dart';
import 'package:hustle_stay/screens/hostel/addHostel.dart';

import '../../models/common/operation.dart';
import '../../models/hostel/hostels.dart';

class ManageHostelPage extends StatefulWidget {
  const ManageHostelPage({super.key});

  @override
  State<ManageHostelPage> createState() => _ManageHostelPageState();
}

class _ManageHostelPageState extends State<ManageHostelPage> {
  List<Operations> setCatList(List<Hostels> list) {
    List<Operations> catList = [
      Operations(
          cardColor: Colors.cyan,
          operationName: 'Add New Hostel',
          icon: const Icon(Icons.add_home_outlined)),
    ];
    for (final x in list) {
      if (x.imageUrl == null) {
        catList.add(Operations(
            operationName: 'Manage ${x.hostelName}',
            cardColor: Colors.cyan,
            hostel: x,
            icon: const Icon(Icons.add_home_outlined)));
      } else {
        catList.add(Operations(
            operationName: 'Manage ${x.hostelName}',
            imgUrl: x.imageUrl,
            cardColor: Colors.cyan,
            hostel: x));
      }
    }
    return catList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Hostels & Attendance'),
      ),
      body: FutureBuilder(
        future: fetchHostels(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          List<Operations> list = setCatList(snapshot.data!);
          return HostelOperations(list);
        },
      ),
    );
  }

  Widget HostelOperations(List<Operations> catList) {
    final Brightness brightness = Theme.of(context).brightness;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double gridWidth = (screenWidth) / 2;
    return SafeArea(
      child: GridView.builder(
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
                  if (catList[index].operationName == 'Add New Hostel') {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => AddHostelForm()));
                  } else if (catList[index].hostel != null) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ManageHostel(
                              hostel: catList[index].hostel!,
                            )));
                  }
                },
                child: Container(
                  width: gridWidth,
                  padding:
                      EdgeInsets.all(catList[index].imgUrl != null ? 4 : 1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    gradient: brightness == Brightness.light ? null : gradient,
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
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
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
      ),
    );
  }
}
