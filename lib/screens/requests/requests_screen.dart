import 'package:flutter/material.dart';
import 'package:hustle_stay/screens/requests/attendance/attendance_request_screen.dart';
import 'package:hustle_stay/screens/requests/closed_requests_screen.dart';
import 'package:hustle_stay/screens/requests/mess/mess_request_screen.dart';
import 'package:hustle_stay/screens/requests/other/other_request_screen.dart';
import 'package:hustle_stay/screens/requests/vehicle/vehicle_requests_screen.dart';
import 'package:hustle_stay/widgets/requests/student_view.dart';

const requestMainPageElements = <String, Map<String, dynamic>>{
  'Attendance': {
    'color': Colors.red,
    'icon': Icons.calendar_month_rounded,
    'route': AttendanceRequestScreen.routeName,
  },
  'Vehicle': {
    'color': Colors.deepPurpleAccent,
    'icon': Icons.airport_shuttle_rounded,
    'route': VehicleRequestScreen.routeName,
  },
  'Mess': {
    'color': Colors.lightBlueAccent,
    'icon': Icons.restaurant_menu_rounded,
    'route': MessRequestScreen.routeName,
  },
  'Other': {
    'color': Colors.amber,
    'icon': Icons.more_horiz_rounded,
    'route': OtherRequestScreen.routeName,
  },
};

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  @override
  Widget build(BuildContext context) {
    // return Container();
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: RequestsList(),
          ),
          SafeArea(
            child: ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  builder: (context) {
                    return DraggableScrollableSheet(
                      expand: false,
                      builder: (context, scrollController) {
                        return ClosedRequestsScreen(
                          scrollController: scrollController,
                        );
                      },
                    );
                  },
                );
              },
              icon: const Icon(Icons.history_rounded),
              label: const Text('Closed Requests'),
            ),
          ),
        ],
      ),
    );
  }
}
